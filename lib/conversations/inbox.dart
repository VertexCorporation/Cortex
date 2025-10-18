// inbox.dart

import 'dart:async';
import 'package:cortex/conversations/skeleton.dart';
import 'package:cortex/conversations/tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cache.dart';
import '../chat/services/database.dart';
import '../chat/services/storage.dart';
import '../models/backend/data.dart';
import '../main.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import 'package:cortex/notifications.dart';
import 'manager.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  final Map<String, ConversationManager> _conversationManagers = {};
  static double savedInboxScrollOffset = 0.0;
  late ScrollController _listScrollController = ScrollController(
    initialScrollOffset: savedInboxScrollOffset,
  );

  List<String> _conversationIDsOrder = [];
  List<Map<String, dynamic>> _userModels = [];
  bool _isLoading = true;
  bool hasInternetConnection = false;

  @override
  bool get wantKeepAlive => true;

  final GlobalKey<AnimatedListState> _allChatsListKey =
      GlobalKey<AnimatedListState>();

  final GlobalKey<AnimatedListState> _starredChatsListKey =
      GlobalKey<AnimatedListState>();

  List<String> _starredConversationIDs = [];

  TabController? _tabController;
  int _currentTabIndex = 0;

  late final AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late NotificationService _notificationService;
  late StreamSubscription<InternetStatus> _internetSubscription;

  // --- AAA-QUALITY FIX: Add a flag to ensure one-time initialization ---
  bool _isInitialSetupComplete = false;

  @override
  void initState() {
    super.initState();
    // --- 1. NON-CONTEXT-DEPENDENT INITIALIZATION ---
    // Initialize things that DO NOT need BuildContext.

    _listScrollController = ScrollController(
      initialScrollOffset: savedInboxScrollOffset,
    );

    // Try to load from cache synchronously. This is safe.
    if (CacheService.cachedConversationManagers != null) {
      _conversationManagers.addAll(CacheService.cachedConversationManagers!);
      _conversationIDsOrder.addAll(CacheService.cachedConversationOrder ?? []);
      _starredConversationIDs.addAll(CacheService.cachedStarredIds ?? []);
      _userModels.addAll(CacheService.cachedUserModels ?? []);
      _isLoading = false;
      debugPrint("[MenuScreen] Initialized successfully from cache.");
    }

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController!.indexIsChanging) {
          setState(() => _currentTabIndex = _tabController!.index);
        }
      });

    _internetSubscription =
        InternetConnection().onStatusChange.listen((status) async {
          final hasConnection = status == InternetStatus.connected;
          if (mounted) setState(() => hasInternetConnection = hasConnection);
        });

    _fadeAnimationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // --- 2. CONTEXT-DEPENDENT INITIALIZATION ---
    // This is the safe place for any logic that needs context.
    // The flag ensures this block runs only once.
    if (!_isInitialSetupComplete) {
      debugPrint("[MenuScreen] didChangeDependencies: Running initial context-aware setup.");

      _notificationService = Provider.of<NotificationService>(context, listen: false);

      // If the cache was empty during initState, we trigger the full load now.
      if (CacheService.cachedConversationManagers == null) {
        _loadConversations();
      }

      _isInitialSetupComplete = true;
    }
  }

  @override
  void dispose() {
    if (_listScrollController.hasClients) {
      savedInboxScrollOffset = _listScrollController.offset;
    }
    CacheService.startConversationCacheTimer();
    _listScrollController.dispose();
    _fadeAnimationController.dispose();
    _internetSubscription.cancel();
    super.dispose();
  }

  bool _isCurrentlyLoading = false;

  /// This function now filters conversations based on a single source of truth:
  /// the list of models currently visible to the logged-in user, WITH AN
  /// EXCEPTION FOR DYNAMIC CHATS.
  Future<void> _loadConversations() async {
    if (_isCurrentlyLoading) {
      debugPrint("[MenuScreen] Load already in progress. Skipping.");
      return;
    }
    _isCurrentlyLoading = true;
    if (_conversationManagers.isEmpty && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final langCode = Localizations.localeOf(context).languageCode;
      await ModelData.getModels(langCode: langCode);

      // --- SECURITY GATE STEP 1: Create the definitive "allow list" ---
      final allUserVisibleModels = ModelData.getCachedModelsSync();
      final Set<String> userVisibleModelIds = {};
      for (final model in allUserVisibleModels) {
        userVisibleModelIds.add(model['id'] as String);
        if (model['extensions'] is Map) {
          userVisibleModelIds.addAll((model['extensions'] as Map<String, dynamic>).keys);
        }
      }
      debugPrint("[MenuScreen] Security Gate: User has access to ${userVisibleModelIds.length} total model IDs.");

      final db = await DbHelper().db;
      final rows = await db.query('conversations', orderBy: 'lastMessageDate DESC');

      final newOrder = <String>[];
      final newStarred = <String>[];
      final Set<String> currentVisibleDbIds = {};

      // --- SECURITY GATE STEP 2: Filter all conversations from the database ---
      for (final row in rows) {
        final modelId = row['modelId'] as String? ?? '';
        final convID = row['id'] as String;

        // --- THE PERFECT FIX IS HERE ---
        // A conversation is visible if:
        // 1. Its model ID is in the user's visible set, OR
        // 2. Its model ID is exactly 'dynamic'.
        if (userVisibleModelIds.contains(modelId) || modelId == 'dynamic') {
          currentVisibleDbIds.add(convID);

          if (_conversationManagers.containsKey(convID)) {
            final manager = _conversationManagers[convID]!;
            manager.updateConversationTitle(row['title'] as String? ?? 'No Title');
            manager.setStarred((row['isStarred'] as int? ?? 0) == 1);
            await manager.checkForModelUpdate();
          } else {
            final manager = ConversationManager(
              conversationID: convID,
              conversationTitle: row['title'] as String? ?? 'No Title',
              initialModelId: modelId,
              isStarred: (row['isStarred'] as int? ?? 0) == 1,
              lastMessageDate: DateTime.fromMillisecondsSinceEpoch(row['lastMessageDate'] as int? ?? 0),
            );
            await manager.updateLastMessageTextOnly();
            _conversationManagers[convID] = manager;
          }

          newOrder.add(convID);
          if (_conversationManagers[convID]!.isStarred) {
            newStarred.add(convID);
          }
        } else {
          debugPrint("[MenuScreen] Hiding conversation '$convID'. Its model ('$modelId') is not in the current user's visible set.");
        }
      }

      _conversationManagers.removeWhere((id, _) => !currentVisibleDbIds.contains(id));

      if (mounted) {
        setState(() {
          _conversationIDsOrder = newOrder;
          _starredConversationIDs = newStarred;
          _isLoading = false;
        });
        _updateConversationCache();
      }
    } catch (e, stackTrace) {
      debugPrint("FATAL: Could not load conversations. Error: $e\nStack trace: $stackTrace");
      if (mounted) setState(() => _isLoading = false);
    } finally {
      if(mounted) {
        _isCurrentlyLoading = false;
      }
    }
  }

  Widget _buildConversationList({required bool showStarredOnly}) {
    final localizations = AppLocalizations.of(context)!;

    if (showStarredOnly) {
      if (_isLoading) {
        return SkeletonChatList(key: const ValueKey('skeleton'));
      } else if (_starredConversationIDs.isEmpty) {
        return TweenAnimationBuilder<double>(
          key: const ValueKey('empty'),
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          builder: (context, opacity, child) {
            return Opacity(opacity: opacity, child: child);
          },
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(MediaQuery
                  .of(context)
                  .size
                  .width * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localizations.noStarredChats,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.primaryColor.inverted,
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .width * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.005),
                  Text(
                    localizations.noStarredChatsMessage,
                    style: TextStyle(
                      color: AppColors.tertiaryColor,
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .width * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.01),
                  ElevatedButton(
                    onPressed: () {
                      _tabController?.animateTo(0);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.inverted,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery
                            .of(context)
                            .size
                            .width * 0.08,
                        vertical: MediaQuery
                            .of(context)
                            .size
                            .height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            MediaQuery
                                .of(context)
                                .size
                                .width * 0.02),
                      ),
                    ),
                    child: Text(
                      localizations.goToChats,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: MediaQuery
                            .of(context)
                            .size
                            .width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return Container(
          key: const PageStorageKey('starredChatsList'),
          child: AnimatedList(
            key: _starredChatsListKey,
            controller: _listScrollController,
            initialItemCount: _starredConversationIDs.length,
            itemBuilder: (context, index, animation) {
              if (index >= _starredConversationIDs.length)
                return const SizedBox.shrink();
              final convID = _starredConversationIDs[index];
              return _buildAnimatedStarredListItem(convID, animation);
            },
          ),
        );
      }
    } else {
      // --- THE FIX: Replaced AnimatedSwitcher with a direct if/else block ---
      // This is more robust and prevents GlobalKey conflicts.
      if (_isLoading) {
        return SkeletonChatList(key: const ValueKey('skeleton_all'));
      }

      if (_conversationIDsOrder.isEmpty) {
        return TweenAnimationBuilder<double>(
          key: const ValueKey('empty_all'),
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          builder: (context, opacity, child) {
            return Opacity(opacity: opacity, child: child);
          },
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(MediaQuery
                  .of(context)
                  .size
                  .width * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localizations.noChats,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.primaryColor.inverted,
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .width * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.005),
                  Text(
                    localizations.noConversationsMessage,
                    style: TextStyle(
                      color: AppColors.tertiaryColor,
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .width * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.01),
                  ElevatedButton(
                    onPressed: () {
                      mainScreenKey.currentState?.onItemTapped(0);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.inverted,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery
                            .of(context)
                            .size
                            .width * 0.08,
                        vertical: MediaQuery
                            .of(context)
                            .size
                            .height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            MediaQuery
                                .of(context)
                                .size
                                .width * 0.02),
                      ),
                    ),
                    child: Text(
                      localizations.startChat,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: MediaQuery
                            .of(context)
                            .size
                            .width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // If not loading and not empty, build the list.
      return Container(
        key: const PageStorageKey('allChatsList'),
        child: AnimatedList(
          key: _allChatsListKey,
          controller: _listScrollController,
          initialItemCount: _conversationIDsOrder.length,
          itemBuilder: (context, index, animation) {
            final convID = _conversationIDsOrder[index];
            return _buildAnimatedListItem(convID, animation);
          },
        ),
      );
    }
  }

  void _updateConversationCache() {
    CacheService.touchConversationCache();
    CacheService.cachedConversationManagers = Map.of(_conversationManagers);
    CacheService.cachedConversationOrder = List.of(_conversationIDsOrder);
    CacheService.cachedStarredIds = List.of(_starredConversationIDs);
    CacheService.cachedUserModels = List.of(_userModels);
  }

  /// If we want reload
  Future<void> reloadConversations({bool preserveList = false}) async {
    CacheService.touchConversationCache();

    final oldIds = List<String>.from(_conversationIDsOrder);

    if (!preserveList) setState(() => _isLoading = true);

    _conversationManagers.clear();
    _conversationIDsOrder.clear();
    await _loadConversations();

    if (preserveList && mounted) {
      final newOnes = _conversationIDsOrder.where((id) => !oldIds.contains(id));
      for (final id in newOnes) {
        final idx = _conversationIDsOrder.indexOf(id);
        _allChatsListKey.currentState?.insertItem(
          idx,
          duration: const Duration(milliseconds: 250),
        );
      }
      setState(() {});
    }
  }

  /// Atomically and safely deletes a conversation from the data source and the UI with animation.
  /// Correctly handles the "empty list" state.
  /// Atomically and safely deletes a conversation from the data source and the UI with animation.
  /// Correctly handles the "empty list" state and shows a success notification.
  Future<void> _deleteConversation(String conversationID) async {
    final manager = _conversationManagers[conversationID];
    if (manager == null) {
      debugPrint(
          'Warning: Attempted to delete non-existent manager for ID: $conversationID');
      return;
    }

    // --- PERFECT FIX IS HERE ---
    // 1. Show a success notification immediately.
    // This gives the user instant feedback that their action was registered.
    _notificationService.showNotification(
      message: AppLocalizations.of(context)!.conversationDeleted,
      bottomOffset: 0.12,
      isSuccess: true,
    );

    // 2. Find the item's index in both lists (All & Starred) BEFORE modifying them.
    final int allChatsIndex = _conversationIDsOrder.indexOf(conversationID);
    final int starredChatsIndex = _starredConversationIDs.indexOf(
        conversationID);

    // 3. Remove the item from the in-memory data sources immediately.
    _conversationManagers.remove(conversationID);
    _conversationIDsOrder.remove(conversationID);
    if (starredChatsIndex != -1) {
      _starredConversationIDs.remove(conversationID);
    }

    // 4. Trigger the removal animations on the lists where the item existed.
    if (allChatsIndex != -1) {
      _allChatsListKey.currentState?.removeItem(
        allChatsIndex,
            (context, animation) =>
            _buildAnimatedRemovalItem(manager, animation),
        duration: const Duration(milliseconds: 300),
      );
    }
    if (starredChatsIndex != -1) {
      _starredChatsListKey.currentState?.removeItem(
        starredChatsIndex,
            (context, animation) =>
            _buildAnimatedRemovalItem(manager, animation),
        duration: const Duration(milliseconds: 300),
      );
    }

    // 5. After a delay (to allow animations to play), trigger a final rebuild.
    // This is CRUCIAL for making the "No chats" screen appear if the list is now empty.
    await Future.delayed(const Duration(milliseconds: 310));
    if (mounted) {
      setState(() {
        // This empty call tells Flutter to rebuild, and the `_buildConversationList`
        // widget will now see the empty lists and render the correct empty-state UI.
      });
    }

    // 6. Perform async background tasks (these don't block the UI).
    await ChatStorageService.deleteConversation(conversationID);
    _updateConversationCache();
  }

  // --- NEW HELPER FUNCTION: _buildAnimatedRemovalItem ---
  /// A common builder for the animated removal of a `ConversationTile`.
  Widget _buildAnimatedRemovalItem(ConversationManager manager, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: ConversationTile(
          key: ValueKey("removing_${manager.conversationID}"),
          manager: manager,
          // These callbacks are now irrelevant as the item is being destroyed.
          onDelete: () {},
          onEdit: (_) {},
          onToggleStar: () {},
        ),
      ),
    );
  }

  Future<void> _editConversation(String conversationID, String newTitle) async {
    final manager = _conversationManagers[conversationID];
    if (manager == null) return;

    await ChatStorageService.renameConversation(conversationID, newTitle);
    manager.updateConversationTitle(newTitle);

    _notificationService.showNotification(
      message: AppLocalizations.of(context)!.conversationTitleUpdated,
      isSuccess: true,
    );
  }

  Widget _buildAnimatedStarredRemovalItem(
      String conversationID, Animation<double> animation) {
    final manager = _conversationManagers[conversationID];
    if (manager == null) {
      debugPrint(
          'Warning: ConversationManager for ID $conversationID is null.');
      return const SizedBox.shrink();
    }
    final curvedAnimation =
        CurvedAnimation(parent: animation, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: curvedAnimation,
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
      child: ConversationTile(
        key: ValueKey(conversationID),
        manager: manager,
        hideWhenUnstarred: false,
        onDelete: () => _deleteConversation(conversationID),
        onEdit: (newTitle) => _editConversation(conversationID, newTitle),
        onToggleStar: () => _toggleStarredStatus(conversationID),
      ),
    );
  }

  Future<void> _toggleStarredStatus(String conversationID) async {
    final prefs = await SharedPreferences.getInstance();
    final manager = _conversationManagers[conversationID];
    if (manager == null) return;

    bool newVal = !manager.isStarred;

    // Eğer yıldızlı liste görünümündeysek ve sohbetin yıldızı kaldırılıyorsa:
    if (_currentTabIndex == 1 && !newVal) {
      int starredIndex = _starredConversationIDs.indexOf(conversationID);
      if (starredIndex != -1) {
        // Eğer listedeki öğe sayısı 1 ise (yani son öğe) farklı davranalım:
        bool isLastStarred = _starredConversationIDs.length == 1;
        if (!isLastStarred) {
          // Birden fazla öğe varsa: Önce listeden kaldır, sonra animasyon çalıştır.
          setState(() {
            _starredConversationIDs.removeAt(starredIndex);
          });
          _starredChatsListKey.currentState?.removeItem(
            starredIndex,
            (context, animation) =>
                _buildAnimatedStarredRemovalItem(conversationID, animation),
            duration: const Duration(milliseconds: 300),
          );
        } else {
          // Eğer listede yalnızca bir öğe varsa:
          // 1) AnimatedList üzerinden kaldırma animasyonunu başlatıyoruz.
          _starredChatsListKey.currentState?.removeItem(
            starredIndex,
            (context, animation) =>
                _buildAnimatedStarredRemovalItem(conversationID, animation),
            duration: const Duration(milliseconds: 300),
          );
          // 2) Animasyonun tamamlanması için bekliyoruz, ardından veri kaynağından kaldırıyoruz.
          await Future.delayed(const Duration(milliseconds: 300));
          setState(() {
            _starredConversationIDs.removeAt(starredIndex);
          });
        }
      }
      _updateConversationCache();
    }

    manager.setStarred(newVal);
    await ChatStorageService.setStarred(conversationID, newVal);

    setState(() {
      _starredConversationIDs = _conversationIDsOrder
          .where((id) => _conversationManagers[id]?.isStarred == true)
          .toList();
    });

    if (_currentTabIndex == 1 && newVal) {
      int insertIndex = _starredConversationIDs.indexOf(conversationID);
      if (insertIndex == -1) {
        insertIndex = _starredConversationIDs.length;
      }
      _starredChatsListKey.currentState?.insertItem(
        insertIndex,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Widget _buildAnimatedStarredListItem(
      String conversationID, Animation<double> animation) {
    final manager = _conversationManagers[conversationID];
    if (manager == null) {
      debugPrint(
          'Warning: ConversationManager for ID $conversationID is null.');
      return const SizedBox.shrink();
    }
    final curvedAnimation =
        CurvedAnimation(parent: animation, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: curvedAnimation,
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
      child: ConversationTile(
        key: ValueKey(conversationID),
        manager: manager,
        hideWhenUnstarred: false,
        onDelete: () => _deleteConversation(conversationID),
        onEdit: (newTitle) => _editConversation(conversationID, newTitle),
        onToggleStar: () => _toggleStarredStatus(conversationID),
      ),
    );
  }

  Widget _buildAnimatedListItem(
      String conversationID, Animation<double> animation) {
    final manager = _conversationManagers[conversationID];

    if (manager == null) {
      debugPrint(
          'Warning: ConversationManager for ID $conversationID is null.');
      return SizedBox.shrink();
    }

    return ConversationTile(
      key: ValueKey(conversationID),
      manager: manager,
      hideWhenUnstarred: false,
      onDelete: () => _deleteConversation(conversationID),
      onEdit: (newTitle) => _editConversation(conversationID, newTitle),
      onToggleStar: () => _toggleStarredStatus(conversationID),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Text(
              localizations.conversationsTitle,
              style: TextStyle(
                fontFamily: 'Roboto',
                color: AppColors.primaryColor.inverted,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.background,
            elevation: 0,
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/new.svg',
                  color: AppColors.primaryColor.inverted,
                  width: screenWidth * 0.055,
                  height: screenWidth * 0.055,
                ),
                onPressed: () {
                  mainScreenKey.currentState?.onItemTapped(0);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(screenWidth * 0.12),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: AppColors.quaternaryColor.withOpacity(0.3),
                  highlightColor: AppColors.quaternaryColor.withOpacity(0.1),
                ),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: screenWidth * 0.004,
                        color: AppColors.primaryColor.inverted,
                      ),
                      insets: EdgeInsets.zero,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.primaryColor.inverted,
                    unselectedLabelColor:
                        AppColors.primaryColor.inverted.withOpacity(0.6),
                    labelStyle: TextStyle(fontSize: screenWidth * 0.04),
                    tabs: [
                      Tab(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(localizations.allChats),
                          ),
                        ),
                      ),
                      Tab(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(localizations.starredChats),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          backgroundColor: AppColors.background,
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildConversationList(showStarredOnly: false),
              _buildConversationList(showStarredOnly: true),
            ],
          ),
        ),
      ),
    );
  }
}