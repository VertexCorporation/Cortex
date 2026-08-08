// lib/roleplay/screens/discover_screen.dart
//
// Character AI "Keşfet" (Discover) screen — full-featured discover + my bots.

import 'package:cortex/roleplay/screens/character.dart';
import 'package:cortex/roleplay/screens/roleplay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../app.dart';
import '../models/character.dart';
import '../provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final List<CharacterCategory> _categories = CharacterCategory.values;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context
            .read<RoleplayProvider>()
            .setCategory(_categories[_tabController.index]);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleplayProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: -screenWidth * 0.2,
            child: Container(
              width: screenWidth * 0.82,
              height: screenHeight * 0.83,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.senaryColor.withValues(alpha: 0.4),
                    AppColors.background.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildCategoryTabs(),
                Expanded(child: _buildCharacterGrid()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCreateFab(),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keşfet',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.primaryColor.inverted,
                    fontSize: screenWidth * 0.065,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Karakterlerle sohbet et, maceraya dal',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.tertiaryColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _buildMyBotsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBotsButton() {
    return Consumer<RoleplayProvider>(
      builder: (context, rp, _) {
        final count = rp.userCharacters.length;
        return Material(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: _openMyBots,
            splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smart_toy_rounded,
                      size: 18, color: AppColors.primaryColor.inverted),
                  const SizedBox(width: 6),
                  Text(
                    'Botlarım',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.primaryColor.inverted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.senaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.04,
        right: screenWidth * 0.04,
        top: 14,
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isSearching ? AppColors.senaryColor : AppColors.border,
            width: _isSearching ? 1.5 : 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) {
            context.read<RoleplayProvider>().setSearchQuery(v);
            setState(() {});
          },
          onTap: () => setState(() => _isSearching = true),
          onTapOutside: (_) => setState(() => _isSearching = false),
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppColors.primaryColor.inverted,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Karakter ara...',
            hintStyle: TextStyle(color: AppColors.tertiaryColor, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded,
                color: AppColors.tertiaryColor, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      context.read<RoleplayProvider>().setSearchQuery('');
                      setState(() {});
                    },
                    child: Icon(Icons.close_rounded,
                        color: AppColors.tertiaryColor, size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final isSelected = index == _tabController.index;
            return GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
                context.read<RoleplayProvider>().setCategory(cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cat.accentColor.withValues(alpha: 0.2)
                      : AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? cat.accentColor : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  cat.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color:
                        isSelected ? cat.accentColor : AppColors.tertiaryColor,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCharacterGrid() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Consumer<RoleplayProvider>(
      builder: (context, rp, _) {
        if (rp.isLoading) {
          return _buildLoadingGrid();
        }

        final chars = rp.filteredCharacters;

        if (chars.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.04,
            16,
            screenWidth * 0.04,
            100,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: chars.length,
          itemBuilder: (context, index) {
            return _CharacterCard(
              character: chars[index],
              onTap: () => _openCharacter(chars[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        16,
        screenWidth * 0.04,
        100,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _ShimmerCard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded,
              size: 48, color: AppColors.tertiaryColor.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'Karakter bulunamadı',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.primaryColor.inverted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kendi karakterini oluşturmayı dene!',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.tertiaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Material(
            color: AppColors.senaryColor,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: _openCreateCharacter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: const Text(
                  '+ Karakter Oluştur',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateFab() {
    return FloatingActionButton.extended(
      onPressed: _openCreateCharacter,
      backgroundColor: AppColors.senaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Bot Oluştur',
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _openCharacter(RoleplayCharacter character) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoleplayChatScreen(character: character),
      ),
    );
  }

  void _openCreateCharacter() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateCharacterScreen(),
      ),
    );
  }

  void _openMyBots() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MyBotsSheet(),
    );
  }
}

// ─── Character Card ────────────────────────────────────────────────────────

class _CharacterCard extends StatelessWidget {
  final RoleplayCharacter character;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: character.gradientColors,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      character.avatarEmoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Name
                Text(
                  character.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                // Tagline
                Text(
                  character.tagline,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Bottom row
                Row(
                  children: [
                    // Traits
                    if (character.traits.isNotEmpty)
                      Text(
                        character.traits.take(2).map((t) => t.emoji).join(' '),
                        style: const TextStyle(fontSize: 13),
                      ),
                    const Spacer(),
                    // Chat count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 10),
                        const SizedBox(width: 2),
                        Text(
                          _formatCount(character.chatCount),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
}

// ─── Shimmer Loading Card ─────────────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.secondaryColor.withValues(alpha: _anim.value),
        ),
      ),
    );
  }
}

// ─── My Bots Bottom Sheet ─────────────────────────────────────────────────

class _MyBotsSheet extends StatelessWidget {
  const _MyBotsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'Botlarım',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.primaryColor.inverted,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateCharacterScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.senaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '+ Yeni',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Consumer<RoleplayProvider>(
              builder: (context, rp, _) {
                if (rp.userCharacters.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.smart_toy_rounded,
                            size: 48,
                            color:
                                AppColors.tertiaryColor.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'Henüz bot oluşturmadın',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.primaryColor.inverted,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kendi AI karakterini yarat!',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.tertiaryColor,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: rp.userCharacters.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final char = rp.userCharacters[index];
                    return _UserBotTile(character: char);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBotTile extends StatelessWidget {
  final RoleplayCharacter character;

  const _UserBotTile({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: character.gradientColors,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                character.avatarEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.primaryColor.inverted,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  character.tagline,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.tertiaryColor,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RoleplayChatScreen(character: character),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.senaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Sohbet',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.senaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  context
                      .read<RoleplayProvider>()
                      .deleteCharacter(character.id);
                },
                child: Icon(Icons.delete_outline_rounded,
                    color: AppColors.tertiaryColor, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
