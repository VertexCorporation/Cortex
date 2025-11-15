// lib/inbox/screen.dart

import 'package:cortex/inbox/providers/general.dart';
import 'package:cortex/inbox/widgets/appbar.dart';
import 'package:cortex/inbox/widgets/list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

/// The main screen for displaying user conversations.
///
/// This widget acts as a UI coordinator. It assembles the various UI components
/// (`InboxAppBar`, `ConversationListView`) and connects them to the `InboxViewModel`,
/// which handles all the business logic and state management.
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => InboxScreenState();
}

class InboxScreenState extends State<InboxScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // --- UI Controllers and Keys ---
  // These are managed by the State because they are tied to the UI lifecycle.
  late final TabController _tabController;
  late final ScrollController _listScrollController;
  final GlobalKey _allChatsListKey = GlobalKey();
  final GlobalKey _starredChatsListKey = GlobalKey();

  late final AnimationController _fadeAnimationController;
  late final Animation<double> _fadeAnimation;

  // To preserve scroll position across app sessions.
  static double _savedInboxScrollOffset = 0.0;

  @override
  bool get wantKeepAlive => true; // Preserves state when switching main app tabs.

  @override
  void initState() {
    super.initState();

    _listScrollController = ScrollController(
      initialScrollOffset: _savedInboxScrollOffset,
    );

    _tabController = TabController(length: 2, vsync: this);

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    // Save the scroll position before the widget is destroyed.
    if (_listScrollController.hasClients) {
      _savedInboxScrollOffset = _listScrollController.offset;
    }

    _tabController.dispose();
    _listScrollController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Call super.build for AutomaticKeepAliveClientMixin to work.
    super.build(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InboxViewModel>().refreshIfNeeded();
    });

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () {
          // Hide any snackbars when the user taps outside.
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // --- AppBar ---
          // Assembled using our specialized InboxAppBar widget.
          appBar: InboxAppBar(
            tabController: _tabController,
            onNewChatPressed: () {
              mainScreenKey.currentState?.onItemTapped(0);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          // --- Body ---
          // A TabBarView to display the content for each tab.
          body: TabBarView(
            controller: _tabController,
            children: [
              // --- "All Chats" Tab ---
              ConversationListView(
                listKey: _allChatsListKey,
                scrollController: _listScrollController,
                isForStarred: false,
              ),
              // --- "Starred Chats" Tab ---
              ConversationListView(
                listKey: _starredChatsListKey,
                scrollController: _listScrollController,
                isForStarred: true,
                onGoToAllChats: () => _tabController.animateTo(0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}