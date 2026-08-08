// lib/roleplay/screens/character_profile_screen.dart
//
// Detailed character profile before starting a chat.

import 'package:cortex/roleplay/screens/roleplay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cortex/app.dart';
import '../../theme.dart';
import '../models/character.dart';

class CharacterProfileScreen extends StatefulWidget {
  final RoleplayCharacter character;

  const CharacterProfileScreen({super.key, required this.character});

  @override
  State<CharacterProfileScreen> createState() => _CharacterProfileScreenState();
}

class _CharacterProfileScreenState extends State<CharacterProfileScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final char = widget.character;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(char),
          SliverToBoxAdapter(
            child: _buildBody(char),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(char),
    );
  }

  Widget _buildSliverAppBar(RoleplayCharacter char) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: char.gradientColors,
            ),
          ),
          child: Stack(
            children: [
              // Pattern overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2),
                      ),
                      child: Center(
                        child: Text(
                          char.avatarEmoji,
                          style: const TextStyle(fontSize: 54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      char.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      char.tagline,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(RoleplayCharacter char) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          _buildStatsRow(char),
          const SizedBox(height: 20),

          // Category badge
          _buildCategoryBadge(char),
          const SizedBox(height: 20),

          // Description
          _buildSection('Hakkında', char.description),
          const SizedBox(height: 16),

          // Background story
          if (char.backgroundStory.isNotEmpty) ...[
            _buildSection('Arka Plan Hikayesi', char.backgroundStory),
            const SizedBox(height: 16),
          ],

          // World context
          if (char.worldContext != null) ...[
            _buildSection('Dünya / Evren', char.worldContext!),
            const SizedBox(height: 16),
          ],

          // Traits
          if (char.traits.isNotEmpty) ...[
            _buildTraitsSection(char),
            const SizedBox(height: 16),
          ],

          // Example openers
          if (char.exampleOpeners.isNotEmpty) ...[
            _buildOpenersSection(char),
            const SizedBox(height: 16),
          ],

          // Creator info
          _buildCreatorRow(char),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatsRow(RoleplayCharacter char) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.chat_bubble_outline_rounded,
          label: _formatCount(char.chatCount),
          sublabel: 'Sohbet',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.psychology_outlined,
          label: '${char.traits.length}',
          sublabel: 'Özellik',
        ),
        const SizedBox(width: 10),
        _StatChip(
          emoji: char.avatarEmoji,
          label: char.isOfficial ? 'Resmi' : 'Kullanıcı',
          sublabel: 'Kaynak',
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(RoleplayCharacter char) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: char.category.accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: char.category.accentColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        char.category.label,
        style: TextStyle(
          color: char.category.accentColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    final isLong = content.length > 200;
    final displayText =
        isLong && !_isExpanded ? '${content.substring(0, 200)}...' : content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          displayText,
          style: TextStyle(
            color: AppColors.tertiaryColor,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        if (isLong)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _isExpanded ? 'Daha az göster' : 'Devamını oku',
                style: TextStyle(
                  color: AppColors.senaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTraitsSection(RoleplayCharacter char) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kişilik',
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: char.traits
              .map((t) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '${t.emoji} ${t.name}',
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildOpenersSection(RoleplayCharacter char) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Açılış Cümleleri',
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...char.exampleOpeners.map(
          (opener) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(char.avatarEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    opener,
                    style: TextStyle(
                      color: AppColors.tertiaryColor,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorRow(RoleplayCharacter char) {
    return Row(
      children: [
        Icon(Icons.person_outline_rounded,
            color: AppColors.tertiaryColor, size: 16),
        const SizedBox(width: 6),
        Text(
          'Oluşturan: ${char.creatorName}',
          style: TextStyle(color: AppColors.tertiaryColor, fontSize: 13),
        ),
        const Spacer(),
        Text(
          _formatDate(char.createdAt),
          style: TextStyle(color: AppColors.tertiaryColor, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBottomBar(RoleplayCharacter char) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RoleplayChatScreen(character: char),
            ),
          );
        },
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: char.gradientColors),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'Sohbeti Başlat ✨',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

class _StatChip extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final String label;
  final String sublabel;

  const _StatChip({
    this.icon,
    this.emoji,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            if (icon != null)
              Icon(icon, color: AppColors.senaryColor, size: 20)
            else
              Text(emoji!, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                color: AppColors.tertiaryColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
