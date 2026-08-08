// lib/roleplay/screens/roleplay_chat_screen.dart
//
// The immersive roleplay chat screen — full RP experience.

import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../models/character.dart';
import '../provider.dart';
import '../service.dart';
import 'screen.dart';

class RoleplayChatScreen extends StatefulWidget {
  final RoleplayCharacter character;

  const RoleplayChatScreen({super.key, required this.character});

  @override
  State<RoleplayChatScreen> createState() => _RoleplayChatScreenState();
}

class _RoleplayChatScreenState extends State<RoleplayChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  final RoleplayService _service = RoleplayService();

  late AnimationController _sendBtnCtrl;
  bool _showOpeners = true;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _sendBtnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _inputController.addListener(() {
      if (_inputController.text.isNotEmpty) {
        _sendBtnCtrl.forward();
      } else {
        _sendBtnCtrl.reverse();
      }
    });
    _initSession();
  }

  Future<void> _initSession() async {
    final rp = context.read<RoleplayProvider>();
    final session = await rp.startSession(widget.character);
    if (mounted) {
      setState(() {
        _showOpeners = session.messages.isEmpty;
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    _sendBtnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final char = widget.character;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(char),
          Expanded(
            child: _isInitializing
                ? const Center(child: CircularProgressIndicator())
                : _buildMessageArea(char),
          ),
          _buildInputBar(char),
        ],
      ),
    );
  }

  Widget _buildAppBar(RoleplayCharacter char) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.paddingOf(context).top + 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryColor.inverted, size: 16),
            ),
          ),
          const SizedBox(width: 12),

          // Character avatar
          GestureDetector(
            onTap: _openProfile,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: char.gradientColors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(char.avatarEmoji,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name + status
          Expanded(
            child: GestureDetector(
              onTap: _openProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    char.name,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Consumer<RoleplayProvider>(
                    builder: (context, rp, _) => Text(
                      rp.isSendingMessage ? 'yazıyor...' : char.tagline,
                      style: TextStyle(
                        color: rp.isSendingMessage
                            ? AppColors.senaryColor
                            : AppColors.tertiaryColor,
                        fontSize: 12,
                        fontStyle: rp.isSendingMessage
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Options
          GestureDetector(
            onTap: _showOptions,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(Icons.more_vert_rounded,
                  color: AppColors.primaryColor.inverted, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageArea(RoleplayCharacter char) {
    return Consumer<RoleplayProvider>(
      builder: (context, rp, _) {
        final session = rp.activeSession;
        if (session == null) return const SizedBox();

        final messages = session.messages;

        if (messages.isEmpty && _showOpeners) {
          return _buildWelcomeView(char);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            return _buildMessageBubble(msg, char);
          },
        );
      },
    );
  }

  Widget _buildWelcomeView(RoleplayCharacter char) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: char.gradientColors),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: char.gradientColors.last.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child:
                  Text(char.avatarEmoji, style: const TextStyle(fontSize: 46)),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            char.name,
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            char.tagline,
            style: TextStyle(color: AppColors.tertiaryColor, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Description card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              char.description,
              style: TextStyle(
                color: AppColors.tertiaryColor,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Opener suggestions
          if (char.exampleOpeners.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sohbete başla:',
                style: TextStyle(
                  color: AppColors.primaryColor.inverted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...char.exampleOpeners.take(3).map(
                  (opener) => GestureDetector(
                    onTap: () => _sendOpener(opener),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Text(char.avatarEmoji,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              opener,
                              style: TextStyle(
                                color: AppColors.tertiaryColor,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          Icon(Icons.send_rounded,
                              color: AppColors.senaryColor, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(RoleplayMessage msg, RoleplayCharacter char) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // Character avatar
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: char.gradientColors),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(char.avatarEmoji,
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],

          // Bubble
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyMessage(msg.text),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? LinearGradient(colors: char.gradientColors)
                      : null,
                  color: isUser ? null : AppColors.secondaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  border: isUser ? null : Border.all(color: AppColors.border),
                ),
                child: msg.isLoading
                    ? _buildLoadingDots()
                    : SelectableText(
                        msg.text,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : AppColors.primaryColor.inverted,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildLoadingDots() {
    return _TypingDots();
  }

  Widget _buildInputBar(RoleplayCharacter char) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.paddingOf(context).bottom + 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Mood/emotion selector
          GestureDetector(
            onTap: _showMoodSelector,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('😊', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                    color: AppColors.primaryColor.inverted, fontSize: 15),
                decoration: InputDecoration(
                  hintText: '${char.name}\'a yaz...',
                  hintStyle:
                      TextStyle(color: AppColors.tertiaryColor, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          Consumer<RoleplayProvider>(
            builder: (context, rp, _) {
              final canSend = !rp.isSendingMessage &&
                  _inputController.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: canSend ? _sendMessage : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: canSend
                        ? LinearGradient(colors: char.gradientColors)
                        : null,
                    color: canSend ? null : AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: canSend ? Colors.transparent : AppColors.border,
                    ),
                  ),
                  child: rp.isSendingMessage
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.tertiaryColor,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color:
                              canSend ? Colors.white : AppColors.tertiaryColor,
                          size: 20,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    setState(() => _showOpeners = false);
    HapticFeedback.lightImpact();

    final sessionProvider = context.read<ChatSessionProvider>();
    final selectedModel = sessionProvider.selectedModel;
    final dio = context.read<Dio>();

    await context.read<RoleplayProvider>().sendMessage(
          text: text,
          aiResponseFn: (history, character) async {
            if (selectedModel == null) {
              return '⚠️ Lütfen bir model seç.';
            }
            return _service.generateResponse(
              history: history,
              character: character,
              model: selectedModel,
              dio: dio,
            );
          },
        );
  }

  void _sendOpener(String opener) {
    // Show the opener as if user sent it
    _inputController.text = opener;
    _sendMessage();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Kopyalandı'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondaryColor,
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterProfileScreen(character: widget.character),
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(
        character: widget.character,
        onClearChat: () {
          Navigator.pop(context);
          _clearChat();
        },
        onViewProfile: () {
          Navigator.pop(context);
          _openProfile();
        },
      ),
    );
  }

  void _clearChat() async {
    final rp = context.read<RoleplayProvider>();
    if (rp.activeSession != null) {
      await rp.deleteSession(rp.activeSession!.id);
      await rp.startSession(widget.character);
    }
    setState(() {
      _showOpeners = true;
    });
  }

  void _showMoodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoodSelector(
        onMoodSelected: (mood) {
          Navigator.pop(context);
          _inputController.text = _inputController.text + mood;
        },
      ),
    );
  }
}

// ─── Typing dots animation ────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value = ((_ctrl.value - delay) % 1.0);
            final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiaryColor
                    .withValues(alpha: opacity.clamp(0.2, 1.0)),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── Options Sheet ─────────────────────────────────────────────────────────

class _OptionsSheet extends StatelessWidget {
  final RoleplayCharacter character;
  final VoidCallback onClearChat;
  final VoidCallback onViewProfile;

  const _OptionsSheet({
    required this.character,
    required this.onClearChat,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: character.gradientColors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(character.avatarEmoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(character.name,
                        style: TextStyle(
                            color: AppColors.primaryColor.inverted,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    Text(character.tagline,
                        style: TextStyle(
                            color: AppColors.tertiaryColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          _OptionTile(
            icon: Icons.person_outline_rounded,
            label: 'Profili Görüntüle',
            onTap: onViewProfile,
          ),
          _OptionTile(
            icon: Icons.delete_sweep_outlined,
            label: 'Sohbeti Temizle',
            color: Colors.red,
            onTap: onClearChat,
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryColor.inverted;
    return ListTile(
      leading: Icon(icon, color: c),
      title:
          Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}

// ─── Mood Selector ─────────────────────────────────────────────────────────

class _MoodSelector extends StatelessWidget {
  final ValueChanged<String> onMoodSelected;

  const _MoodSelector({required this.onMoodSelected});

  static const _moods = [
    ('😊', 'Mutlu'),
    ('😢', 'Üzgün'),
    ('😠', 'Sinirli'),
    ('😍', 'Aşık'),
    ('😱', 'Şaşkın'),
    ('🤔', 'Düşünceli'),
    ('😂', 'Komik'),
    ('😰', 'Gergin'),
    ('🥰', 'Sevgi'),
    ('😎', 'Havalı'),
    ('🤗', 'Sıcak'),
    ('😴', 'Yorgun'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.paddingOf(context).bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Ruh hali ekle',
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _moods.length,
            itemBuilder: (context, index) {
              final mood = _moods[index];
              return GestureDetector(
                onTap: () => onMoodSelected(mood.$1),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mood.$1, style: const TextStyle(fontSize: 22)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
