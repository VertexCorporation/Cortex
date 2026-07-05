class SearchHit {
  final String conversationId;
  final String title;
  final String snippet;
  final DateTime timestamp;
  final String query;

  SearchHit({
    required this.conversationId,
    required this.title,
    required this.snippet,
    required this.timestamp,
    required this.query,
  });
}
