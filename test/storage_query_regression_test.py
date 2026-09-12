"""Run the actual Dart inbox SQL with Python's standard-library SQLite.

This tests query semantics without requiring Flutter or Firebase.
Run: python -m unittest discover -s test -p storage_query_regression_test.py
"""
from pathlib import Path
import re
import sqlite3
import unittest


class InboxQueryTest(unittest.TestCase):
    def setUp(self):
        source = (Path(__file__).resolve().parents[1] /
                  'lib/chat/services/storage.dart').read_text()
        section = source.split('getConversationsWithLastMessage() async', 1)[1]
        self.query = re.search(r"rawQuery\('''(.*?)'''\)", section, re.S).group(1)
        self.db = sqlite3.connect(':memory:')
        self.addCleanup(self.db.close)
        self.db.row_factory = sqlite3.Row
        self.db.executescript('''
          CREATE TABLE conversations (
            id TEXT PRIMARY KEY, title TEXT, modelId TEXT, modelTitle TEXT,
            modelImagePath TEXT, isStarred INTEGER, starredDate INTEGER,
            lastMessageDate INTEGER);
          CREATE TABLE messages (
            conversationId TEXT, idx INTEGER, text TEXT, photoPath TEXT,
            ts INTEGER);
          CREATE UNIQUE INDEX messages_conv_idx ON messages(conversationId, idx);
        ''')

    def conversation(self, identifier):
        self.db.execute('INSERT INTO conversations(id) VALUES (?)', (identifier,))

    def message(self, identifier, idx, text='', photo=None):
        self.db.execute('INSERT INTO messages VALUES (?, ?, ?, ?, ?)',
                        (identifier, idx, text, photo, idx))

    def test_matching_indices_do_not_cross_conversations(self):
        for name in ['a', 'b']:
            self.conversation(name)
            self.message(name, 0, name + ' first')
            self.message(name, 1, name + ' last')
        rows = self.db.execute(self.query).fetchall()
        self.assertEqual(len(rows), 2)
        self.assertEqual({r['id']: r['lastMessageText'] for r in rows},
                         {'a': 'a last', 'b': 'b last'})

    def test_empty_conversation_and_trailing_placeholder(self):
        self.conversation('empty')
        self.conversation('active')
        self.message('active', 0, 'visible')
        self.message('active', 1)
        rows = {r['id']: r for r in self.db.execute(self.query)}
        self.assertIsNone(rows['empty']['lastMessageText'])
        self.assertEqual(rows['active']['lastMessageText'], 'visible')

    def test_attachment_only_message_remains_visible(self):
        self.conversation('media')
        self.message('media', 0, 'earlier')
        self.message('media', 1, photo='["image.jpg"]')
        row = self.db.execute(self.query).fetchone()
        self.assertEqual(row['lastMessagePhoto'], '["image.jpg"]')

    def test_result_count_does_not_grow_quadratically(self):
        for number in range(100):
            identifier = str(number)
            self.conversation(identifier)
            self.message(identifier, 0, identifier)
        rows = self.db.execute(self.query).fetchall()
        self.assertEqual(len(rows), 100)
        plan = ' '.join(str(tuple(row)) for row in self.db.execute(
            'EXPLAIN QUERY PLAN ' + self.query))
        self.assertIn('messages_conv_idx', plan)


if __name__ == '__main__':
    unittest.main()
