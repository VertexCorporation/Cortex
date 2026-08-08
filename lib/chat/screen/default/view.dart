// lib/chat/screen/default/view.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/library/providers/catalog.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/main.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/login/upgrade.dart';
import 'package:cortex/app.dart';

class ChatEmptyState extends StatefulWidget {
  final double bottomPadding;

  const ChatEmptyState({super.key, this.bottomPadding = 0});

  @override
  State<ChatEmptyState> createState() => _ChatEmptyStateState();
}

class _ChatEmptyStateState extends State<ChatEmptyState>
    with TickerProviderStateMixin {
  // 1. Breathing Animation (Continuous)
  late AnimationController _breathingController;
  late Animation<double> _breathingScaleAnimation;

  // 2. Entrance Animation (On Load)
  late AnimationController _entranceController;

  // 2.5 Timed sequence (description <-> buttons)
  late final AnimationController _swapController;
  int _sequenceToken = 0;

  // 2.6 Bounce Animation (Cortex Icon Tap)
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // 2.7 Rainbow Border Animation
  late AnimationController _rainbowController;

  // 3. Mode Transition Animation (Standard <-> Flux)
  late AnimationController _modeController;
  late Animation<double> _modeAnimation;

  // State tracking to trigger animations
  bool? _wasFluxMode;
  int _subtitleIndex = 0;
  bool _offlinePromptShown = false;

  @override
  void initState() {
    super.initState();

    // --- Breathing Setup ---
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _breathingScaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutQuad,
      ),
    );

    // --- Entrance Setup ---
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entranceController.forward();

    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // --- Bounce Setup (for Cortex icon tap) ---
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    // --- Rainbow Setup ---
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // --- Mode Transition Setup ---
    _modeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _modeAnimation = CurvedAnimation(
      parent: _modeController,
      curve: Curves.easeInOutCubic,
    );

    _subtitleIndex = math.Random().nextInt(1000);
    _startStandardDefaultSequence();
  }

  bool _isVisible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // TickerMode Visibility Handling
    final bool isAnimationEnabled = TickerMode.of(context);
    if (_isVisible != isAnimationEnabled) {
      _isVisible = isAnimationEnabled;
      if (!isAnimationEnabled) {
        // Stop async sequence loop when hidden
        _sequenceToken++;
      } else {
        // Resume sequence when visible
        _startStandardDefaultSequence();
      }
    }

    // Flux Mode State Handling
    final isFlux = context.read<ChatSessionProvider>().isFluxMode;

    // Initialize state on first run
    if (_wasFluxMode == null) {
      _wasFluxMode = isFlux;
      if (isFlux) {
        _modeController.value = 1.0;
        _sequenceToken++;
      }
      return;
    }

    if (!_offlinePromptShown) {
      _offlinePromptShown = true;
      final internet = context.read<InternetProvider>();
      if (!internet.isConnected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showOfflinePrompt(context);
        });
      }
    }

    // Handle subsequent mode changes
    if (_wasFluxMode != isFlux) {
      _wasFluxMode = isFlux;
      if (isFlux) {
        _sequenceToken++; // Cancel text cycle
        _modeController.forward();
      } else {
        _modeController.reverse();
        _startStandardDefaultSequence();
      }
    }
  }

  Timer? _sequenceTimer;

  void _startStandardDefaultSequence([bool? startingWithButtonsOverride]) {
    _sequenceTimer?.cancel();
    final int token = ++_sequenceToken;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sequenceToken != token) return;
      setState(() {});
    });

    final bool startWithButtons =
        startingWithButtonsOverride ?? (_swapController.value > 0.5);

    void tick() {
      if (!mounted || _sequenceToken != token) {
        _sequenceTimer?.cancel();
        _sequenceTimer = null;
        return;
      }
      final isTextMode = _swapController.value <= 0.5;
      if (isTextMode) {
        _swapController.forward(from: 0.0).catchError((_) {});
        _sequenceTimer = Timer(const Duration(seconds: 8), tick);
      } else {
        _swapController.reverse(from: 1.0).catchError((_) {});
        _sequenceTimer = Timer(const Duration(seconds: 4), tick);
      }
    }

    if (startWithButtons) {
      _swapController.reverse(from: 1.0).catchError((_) {});
      _sequenceTimer = Timer(const Duration(seconds: 4), tick);
    } else {
      _sequenceTimer = Timer(const Duration(seconds: 4), tick);
    }
  }

  void _handleIconTap() {
    HapticFeedback.lightImpact();

    // 1. Play bounce animation
    _bounceController.forward(from: 0.0);

    bool targetAsButtons;
    // 2. Toggle current mode (let animation complete naturally)
    if (_swapController.value > 0.5) {
      // Currently showing buttons -> switch to text
      _swapController.reverse();
      targetAsButtons = false;
    } else {
      // Currently showing text -> switch to buttons
      _swapController.forward();
      targetAsButtons = true;
    }

    // 3. Restart the timer loop for the new mode
    _startStandardDefaultSequence(targetAsButtons);
  }

  Widget _buildFeatureButtons(
    BuildContext context,
    AppLocalizations l10n, {
    required double buttonHeight,
    required double buttonSpacing,
    required double rowSpacing,
    required double iconSize,
    required double fontSize,
    required double borderRadius,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final horizontalPadding = screenWidth * 0.02;

    final catalog = context.read<ModelCatalogProvider>();

    final hasImage = catalog.allModels
        .any((m) => m.outputs['image'] == true || m.category == 'image');
    final hasVideo = catalog.allModels
        .any((m) => m.outputs['video'] == true || m.category == 'video');
    final hasAudio = catalog.allModels
        .any((m) => m.outputs['audio'] == true || m.category == 'audio');

    final userProvider = context.read<UserProvider>();
    final int subLevel = userProvider.activeSubscriptionLevel;
    // Lifetime or Ultra
    final bool isUltra = subLevel >= 3;

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: buttonHeight * 0.15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBoxButton(
                  context,
                  width: null,
                  height: buttonHeight,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  borderRadius: borderRadius,
                  buttonSpacing: buttonSpacing,
                  iconPath: 'assets/icons/make.svg',
                  title: l10n.featureCreateImageTitle,
                  iconColor:
                      AppColors.background.inverted.withValues(alpha: 0.2),
                  isDisabled: !hasImage,
                  onTap: () => _handleGeneration(context, 'image'),
                ),
              ),
              SizedBox(width: buttonSpacing),
              Expanded(
                child: _buildBoxButton(
                  context,
                  width: null,
                  height: buttonHeight,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  borderRadius: borderRadius,
                  buttonSpacing: buttonSpacing,
                  iconPath: 'assets/icons/transition.svg',
                  title: l10n.featureCreateVideoTitle,
                  iconColor:
                      AppColors.background.inverted.withValues(alpha: 0.2),
                  isDisabled: !hasVideo,
                  isAnimatedRainbowBorder: !isUltra,
                  onTap: () => _handleGeneration(context, 'video'),
                ),
              ),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            children: [
              Expanded(
                child: _buildBoxButton(
                  context,
                  width: null,
                  height: buttonHeight,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  borderRadius: borderRadius,
                  buttonSpacing: buttonSpacing,
                  iconPath: 'assets/icons/voice.svg',
                  title: l10n.featureCreateAudioTitle,
                  iconColor:
                      AppColors.background.inverted.withValues(alpha: 0.2),
                  isDisabled: !hasAudio,
                  onTap: () => _handleGeneration(context, 'audio'),
                ),
              ),
              SizedBox(width: buttonSpacing),
              Expanded(
                child: _buildBoxButton(
                  context,
                  width: null,
                  height: buttonHeight,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  borderRadius: borderRadius,
                  buttonSpacing: buttonSpacing,
                  iconPath: 'assets/icons/world.svg',
                  title: l10n.offlineUse,
                  iconColor:
                      AppColors.background.inverted.withValues(alpha: 0.2),
                  isDisabled: false,
                  onTap: () {
                    final inputProvider = context.read<InputProvider>();
                    inputProvider.toggleWebSearch();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoxButton(
    BuildContext context, {
    double? width,
    required double height,
    required double iconSize,
    required double fontSize,
    required double borderRadius,
    required double buttonSpacing,
    required String iconPath,
    required String title,
    required Color iconColor,
    required bool isDisabled,
    required VoidCallback onTap,
    bool isPremiumFeature = false,
    bool isAnimatedRainbowBorder = false,
  }) {
    final horizontalPadding = MediaQuery.sizeOf(context).width * 0.018;

    final border = BorderRadius.circular(borderRadius);
    final innerBorder = BorderRadius.circular(borderRadius - 1.5);

    final innerContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          iconPath,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: buttonSpacing * 0.35),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isPremiumFeature) ...[
                  SizedBox(width: buttonSpacing * 0.2),
                  SvgPicture.asset(
                    'assets/icons/sparkle.svg',
                    width: fontSize * 0.9,
                    height: fontSize * 0.9,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );

    final innerContainer = Ink(
      width: isAnimatedRainbowBorder ? null : width,
      height: isAnimatedRainbowBorder ? null : height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: isAnimatedRainbowBorder
            ? AppColors.background
            : AppColors.background.withValues(alpha: 0.4),
        border: isAnimatedRainbowBorder
            ? null
            : Border.all(
                color: AppColors.border,
                width: 0.5,
              ),
        borderRadius: isAnimatedRainbowBorder ? innerBorder : border,
      ),
      child: innerContent,
    );

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: border,
        child: InkWell(
          borderRadius: border,
          onTap: isDisabled ? null : onTap,
          splashColor: iconColor.withValues(alpha: 0.14),
          highlightColor: iconColor.withValues(alpha: 0.06),
          child: isAnimatedRainbowBorder
              ? AnimatedBuilder(
                  animation: _rainbowController,
                  builder: (context, child) {
                    return Ink(
                      width: width,
                      height: height,
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        borderRadius: border,
                        gradient: SweepGradient(
                          transform: GradientRotation(
                              _rainbowController.value * 2 * math.pi),
                          colors: const [
                            Color(0xFFFF0080), // Pink
                            Color(0xFFFF4D4D), // Red
                            Color(0xFFFFAA00), // Orange
                            Color(0xFFFFDD00), // Yellow
                            Color(0xFF00CC76), // Green
                            Color(0xFF00AAFF), // Cyan
                            Color(0xFF7B61FF), // Purple
                            Color(0xFFFF0080), // Pink
                          ],
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: innerContainer,
                )
              : innerContainer,
        ),
      ),
    );
  }

  void _handleGeneration(BuildContext context, String targetType) {
    if (targetType == 'video') {
      final userProvider = context.read<UserProvider>();
      if (userProvider.isAnonymous) {
        navigateToScreen(const UpgradeAccountScreen(showLoginFirst: true),
            direction: const Offset(0, 1));
        return;
      }
    }

    final catalog = context.read<ModelCatalogProvider>();
    final session = context.read<ChatSessionProvider>();
    final inputProvider = context.read<InputProvider>();
    final selectionService = context.read<SelectionService>();

    final candidates = catalog.allModels
        .where((m) => m.outputs[targetType] == true || m.category == targetType)
        .toList();

    if (candidates.isEmpty) return;

    final currentModel = session.selectedModel;
    final bool currentSupportsTarget = currentModel != null &&
        (currentModel.outputs[targetType] == true ||
            currentModel.category == targetType);

    inputProvider.clearFeatureMode();
    inputProvider.clearWebSearch();

    final targetModel = candidates.firstWhere(
      (m) => !m.isPremium,
      orElse: () => candidates.first,
    );

    // Select only if current model does not already support this generation type.
    if (!currentSupportsTarget) {
      selectionService.switchActiveModel(targetModel, context: context);
    }
  }

  void _showOfflinePrompt(BuildContext context) {
    final local = context.read<ModelLocalStateProvider>();
    final catalog = context.read<ModelCatalogProvider>();
    final l10n = AppLocalizations.of(context)!;

    final hasOfflineModels = catalog.allModels.any((m) {
      final path = local.getFilePathById(m.id);
      return m.type == 'offline' && local.isModelOnDisk(path);
    });

    if (!hasOfflineModels) return;

    showAdaptiveDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(l10n.noInternetConnection),
        content: Text(l10n.useOfflineDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleOfflineAction(context);
            },
            child: Text(l10n.useOffline),
          ),
        ],
      ),
    );
  }

  void _handleOfflineAction(BuildContext context) {
    final catalog = context.read<ModelCatalogProvider>();
    final local = context.read<ModelLocalStateProvider>();
    final selectionService = context.read<SelectionService>();
    final inputProvider = context.read<InputProvider>();

    final offlineModels = catalog.allModels.where((m) => m.type == 'offline');
    final downloadedModels = offlineModels.where((m) {
      final path = local.getFilePathById(m.id);
      return local.isModelOnDisk(path);
    }).toList();

    if (downloadedModels.isNotEmpty) {
      inputProvider.clearWebSearch();
      inputProvider.setFeatureMode(ChatInputMode.offline);
      selectionService.switchActiveModel(downloadedModels.first,
          context: context);
    } else {
      mainScreenKey.currentState?.switchToLibrary(pulse: true);
    }
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _breathingController.dispose();
    _entranceController.dispose();
    _swapController.dispose();
    _bounceController.dispose();
    _rainbowController.dispose();
    _modeController.dispose();
    super.dispose();
  }

  // --- Animation Helper for Initial Entrance ---
  Widget _buildEntranceItem({
    required Widget child,
    required double startTime,
    required double endTime,
  }) {
    final Animation<double> fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(startTime, endTime, curve: Curves.easeOut),
      ),
    );

    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(startTime, endTime, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }

  String _getSubtitleText(BuildContext context) {
    final int hour = DateTime.now().hour;
    final locale = Localizations.localeOf(context);
    final String lang = locale.languageCode;
    final bool isMorning = hour >= 5 && hour < 12;
    final bool isAfternoon = hour >= 12 && hour < 17;
    final bool isEvening = hour >= 17 && hour < 22;
    final i = _subtitleIndex;

    String from(List<String> pool) => pool[i % pool.length];

    switch (lang) {
      case 'tr':
        if (isMorning) {
          return from([
            'Bugün harika şeyler yapmaya hazır mısın? ☕',
            'Yeni bir gün, yeni bir başlangıç! Nasıl yardımcı olabilirim? 🌅',
            'Güne harika başlamak için ne yapabilirim? ✨',
            'Kahven hazır, ben de buradayım. Nereden başlayalım? ☕',
            'Bugün seni neler bekliyor? Hadi plan yapalım! 📋',
            'Sabah sabah aklında ne var? Anlat bakalım! 🌞',
            'Günaydın! Bugünün verimli geçmesi için ne yapabilirim? ⚡',
            'Uyandın mı? Harika! Nerelerdeyiz bugün? 🚀',
            'Bugün birlikte neler başaracağız? Haydi! 💪',
          ]);
        } else if (isAfternoon) {
          return from([
            'Günün nasıl geçiyor? Yardımcı olabilirim. 🚀',
            'Öğlen oldu bile! Bugün neler yaptın? ⏰',
            'Mola zamanı! Sana kahve söylesem mi? ☕',
            'Gün ortasında enerjini tazelemek için ne yapabilirim? ⚡',
            'Öğle arasında aklında bir şey var mı? 🍝',
            'Günün koşturmacası nasıl? Biraz yardım ister misin? 🏃',
            'Şu ana kadar neler yaptın, neler kaldı? Hadi planlayalım! 📊',
            'Merhaba! Öğleden sonran nasıl geçiyor? 😊',
            'Yarım gün bitti, kalan yarıda neler yapacağız? 🎯',
          ]);
        } else if (isEvening) {
          return from([
            'Bugünü nasıl tamamladık? Planlarımız neler? 🌟',
            'Akşam oldu, günün yorgunluğunu atmak ister misin? 🌆',
            'Bugün neler yaptın, neler öğrendin? Anlat bakalım! 📖',
            'Akşam keyfi için ne yapalım? Film, müzik, sohbet? 🎬',
            'Gün batarken aklında kalanlar neler? 🌅',
            'Akşam akşam kafanı dağıtmak ister misin? Sohbet edelim! 🌙',
            'Bugünün en iyi anısı neydi? Hadi paylaş! ✨',
            'Yemeğini yedin mi? Afiyet olsun! 🍽️',
            'Akşam planın var mı yoksa birlikte bir şeyler mi yapsak? 🎯',
          ]);
        } else {
          return from([
            'Uykudan önce son bir soru? 🥱',
            'Gecenin sessizliğinde ne düşünüyorsun? 🌙',
            'Yatmadan önce kafanı kurcalayan bir şey var mı? 🌌',
            'Uykun geldiyse son bir şey sormak ister misin? 😴',
            'Rüyalarında ne görmek istersin? Tatlı rüyalar! 🌠',
            'Gece gece aklında ne var? Anlat, sonra uykuya dal! ✨',
            'Günü değerlendirmek ister misin? Nasıl geçti bugün? 📝',
            'Yarın için bir planın var mı? Hazırlık yapalım! 📋',
            'Birazdan uyuyacaksın, son bir şey sorsana? 🛌',
            'Yastığa başını koymadan önce anlatmak istediğin bir şey? 🌜',
          ]);
        }
      case 'az':
        if (isMorning) {
          return from([
            'Bu gün gözəl işlər görməyə hazırsınız? ☕',
            'Yeni bir gün başlayır! Sizə necə kömək edə bilərəm? 🌅',
            'Sabahınız xeyir! Bu gün nə planlayırsınız? ✨',
            'Günə enerjili başlamaq üçün nə edək? 🚀',
          ]);
        } else if (isAfternoon) {
          return from([
            'Gününüz necə keçir? Kömək edə bilərəm. 🚀',
            'Gün ortasıdır, enerjiniz necə? ☕',
            'Nahar fasiləsi verək? 🍝',
          ]);
        } else if (isEvening) {
          return from([
            'Günü necə tamamladıq? 🌟',
            'Axşamınız xeyir! Bu gün nələr etdiniz? 🌆',
            'Günün yekununu birlikdə edək! 📝',
          ]);
        } else {
          return from([
            'Yatmazdan əvvəl son bir sual? 🥱',
            'Gecəniz xeyirə! Rüyalarınız gözəl olsun. 🌙',
            'Yatmazdan qabaq nə düşünürsünüz? 🌌',
            'Son bir şey sorun, sonra yatın! 😴',
          ]);
        }
      case 'de':
        if (isMorning) {
          return from([
            'Bereit, heute Großes zu tun? ☕',
            'Guten Morgen! Wie kann ich dir helfen? 🌅',
            'Ein neuer Tag voller Möglichkeiten! Wo fangen wir an? ✨',
            'Dein Kaffee wartet, ich auch! Was heute los? ☕',
            'Heute wird großartig! Was hast du vor? 🚀',
          ]);
        } else if (isAfternoon) {
          return from([
            'Wie läuft dein Tag? Kann ich helfen? 🚀',
            'Schon Mittag! Wie war dein Morgen? ⏰',
            'Zeit für eine Pause? Kaffee? ☕',
            'Wie ist der Tag bisher gelaufen? 📊',
          ]);
        } else if (isEvening) {
          return from([
            'Wie war dein Tag? Was steht an? 🌟',
            'Feierabend! Wie war\'s heute? 🌆',
            'Abendplanung: Was machen wir heute? 🎬',
            'Zeit zum Entspannen. Erzähl mir von deinem Tag! ✨',
          ]);
        } else {
          return from([
            'Eine letzte Frage vor dem Schlafen? 🥱',
            'Bevor du ins Bett gehst, noch etwas? 🌙',
            'Was beschäftigt dich heute Nacht? 🌌',
            'Träum was Schönes! Noch eine letzte Frage? 😴',
            'Schlaf gut! Noch irgendwas? 🌠',
          ]);
        }
      case 'es':
        if (isMorning) {
          return from([
            '¿Listo para hacer grandes cosas hoy? ☕',
            '¡Buenos días! ¿Cómo puedo ayudarte hoy? 🌅',
            'Un nuevo día, una nueva oportunidad. ¿Por dónde empezamos? ✨',
            '¡Arriba! ¿Qué tenemos hoy en la agenda? 📋',
            '¿Café y charla? ¡Dime todo! ☕',
          ]);
        } else if (isAfternoon) {
          return from([
            '¿Cómo va tu día? Puedo ayudarte. 🚀',
            '¡Ya es mediodía! ¿Cómo va todo? ⏰',
            '¿Hora de comer? ¡Aprovecha y cuéntame! 🍝',
          ]);
        } else if (isEvening) {
          return from([
            '¿Cómo terminamos el día hoy? 🌟',
            '¡Buenas tardes! ¿Qué tal te fue hoy? 🌆',
            'Hora de relajarse. ¿Vemos algo o charlamos? 🎬',
          ]);
        } else {
          return from([
            '¿Una última pregunta antes de dormir? 🥱',
            'Antes de dormir, ¿algo en mente? 🌙',
            '¿En qué piensas esta noche? 🌌',
            '¡Dulces sueños! ¿Una última cosa? 😴',
          ]);
        }
      case 'fr':
        if (isMorning) {
          return from([
            'Prêt à accomplir de belles choses aujourd\'hui ? ☕',
            'Bonjour ! Comment puis-je t\'aider aujourd\'hui ? 🌅',
            'Nouveau jour, nouvelle aventure ! On commence par quoi ? ✨',
            'Café ? Je suis là. Raconte-moi tout ! ☕',
            'Bien dormi ? Prêt pour une journée productive ? 🚀',
          ]);
        } else if (isAfternoon) {
          return from([
            'Comment se passe votre journée ? Je peux aider. 🚀',
            'Déjà midi ! Comment s\'est passée ta matinée ? ⏰',
            'Pause déjeuner ? Bon appétit ! 🍝',
            'Comment avance la journée ? 📊',
          ]);
        } else if (isEvening) {
          return from([
            'Comment s\'est passée votre journée ? 🌟',
            'Bonsoir ! Une bonne journée ? 🌆',
            'Soirée détente. On regarde un film ou on discute ? 🎬',
            'Raconte-moi ta journée ! ✨',
          ]);
        } else {
          return from([
            'Une dernière question avant de dormir ? 🥱',
            'Avant de te coucher, quelque chose en tête ? 🌙',
            'À quoi penses-tu cette nuit ? 🌌',
            'Fais de beaux rêves ! Une dernière chose ? 😴',
            'Bonne nuit ! Un dernier mot ? 🌠',
          ]);
        }
      default:
        if (isMorning) {
          return from([
            'Ready to do great things today? ☕',
            'Good morning! What can I do for you? 🌅',
            'Fresh day, fresh start! Where do we begin? ✨',
            'Coffee\'s ready, so am I. What\'s on your mind? ☕',
            'Morning! Got big plans today? 🚀',
            'Rise and shine! Let\'s make today count! 💪',
            'What\'s the first thing on your list today? 📋',
            'New day, new possibilities! How can I help? ⚡',
            'Good to see you! What are we tackling today? 🎯',
          ]);
        } else if (isAfternoon) {
          return from([
            'How is your day going? I can help. 🚀',
            'Almost halfway through! How\'s it going? ⏰',
            'Lunch break already? Enjoy! 🍝',
            'How\'s the day treating you? Need a hand? 📊',
            'Afternoon vibes! What are we up to? ☀️',
            'Time for a mental refresh? I\'m here! ⚡',
            'Day still young! What\'s next on the agenda? 📋',
          ]);
        } else if (isEvening) {
          return from([
            'How did we wrap up today? What\'s the plan? 🌟',
            'Evening wind-down time! How was your day? 🌆',
            'Good evening! Ready to relax? 🎬',
            'Tell me about your day — the good, the bad, the funny! 📖',
            'Evening plans? Or just hanging out? 🎯',
            'Time to unwind. Movie, music, or deep chat? ✨',
          ]);
        } else {
          return from([
            'One last question before sleep? 🥱',
            'Late night thoughts? I\'m all ears. 🌙',
            'Can\'t sleep? Let\'s talk about it. 🌌',
            'Before you drift off, anything on your mind? 🌠',
            'Sweet dreams ahead! One final thing? 😴',
            'Night owl! What\'s keeping you up? 🦉',
            'Ready for bed? Let\'s finish the day right. 🛌',
            'The night is quiet. What do you want to talk about? ✨',
            'Sleep well! Anything before you go? 🌜',
          ]);
        }
    }
  }

  String _getGreetingText(BuildContext context, String username) {
    final int hour = DateTime.now().hour;
    final locale = Localizations.localeOf(context);
    final String lang = locale.languageCode;

    String greeting;
    switch (lang) {
      case 'tr':
        if (hour >= 5 && hour < 12) {
          greeting = 'Günaydın';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'İyi günler';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'İyi akşamlar';
        } else {
          greeting = 'İyi geceler';
        }
        break;
      case 'az':
        if (hour >= 5 && hour < 12) {
          greeting = 'Sabahın xeyir';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'Hər vaxtın xeyir';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'Axşamın xeyir';
        } else {
          greeting = 'Gecən xeyirə';
        }
        break;
      case 'de':
        if (hour >= 5 && hour < 12) {
          greeting = 'Guten Morgen';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'Guten Tag';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'Guten Abend';
        } else {
          greeting = 'Gute Nacht';
        }
        break;
      case 'es':
        if (hour >= 5 && hour < 12) {
          greeting = 'Buenos días';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'Buenas tardes';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'Buenas noches';
        } else {
          greeting = 'Buenas noches';
        }
        break;
      case 'fr':
        if (hour >= 5 && hour < 12) {
          greeting = 'Bonjour';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'Bonjour';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'Bonsoir';
        } else {
          greeting = 'Bonne nuit';
        }
        break;
      case 'hi':
        if (hour >= 5 && hour < 12) {
          greeting = 'नमस्ते';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'नमस्ते';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'नमस्ते';
        } else {
          greeting = 'शुभ रात्रि';
        }
        break;
      case 'id':
        if (hour >= 5 && hour < 12) {
          greeting = 'Pagi';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'Siang';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'Sore';
        } else {
          greeting = 'Malam';
        }
        break;
      case 'it':
        if (hour >= 5 && hour < 12) {
          greeting = 'Buongiorno';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'Buongiorno';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'Buonasera';
        } else {
          greeting = 'Buonanotte';
        }
        break;
      case 'ja':
        if (hour >= 5 && hour < 12) {
          greeting = 'おはよう';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'こんにちは';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'こんばんは';
        } else {
          greeting = 'おやすみ';
        }
        break;
      case 'ko':
        if (hour >= 5 && hour < 12) {
          greeting = '좋은 아침';
        } else if (hour >= 12 && hour < 17) {
          greeting = '안녕하세요';
        } else if (hour >= 17 && hour < 22) {
          greeting = '좋은 저녁';
        } else {
          greeting = '잘 자요';
        }
        break;
      case 'nl':
        if (hour >= 5 && hour < 12) {
          greeting = 'Goedemorgen';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'Goedemiddag';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'Goedenavond';
        } else {
          greeting = 'Welterusten';
        }
        break;
      case 'pt':
        if (hour >= 5 && hour < 12) {
          greeting = 'Bom dia';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'Boa tarde';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'Boa noite';
        } else {
          greeting = 'Boa noite';
        }
        break;
      case 'ru':
        if (hour >= 5 && hour < 12) {
          greeting = 'Доброе утро';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'Добрый день';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'Добрый вечер';
        } else {
          greeting = 'Спокойной ночи';
        }
        break;
      case 'zh':
        if (hour >= 5 && hour < 12) {
          greeting = '早安';
        } else if (hour >= 12 && hour < 17) {
          greeting = '你好';
        } else if (hour >= 17 && hour < 22) {
          greeting = '晚上好';
        } else {
          greeting = '晚安';
        }
        break;
      case 'ar':
        if (hour >= 5 && hour < 12) {
          greeting = 'صباح الخير';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'مساء الخير';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'مساء الخير';
        } else {
          greeting = 'تصبح على خير';
        }
        break;
      default:
        if (hour >= 5 && hour < 12) {
          greeting = 'Morning';
        } else if (hour >= 12 && hour < 17) {
          greeting = 'Afternoon';
        } else if (hour >= 17 && hour < 22) {
          greeting = 'Evening';
        } else {
          greeting = 'Night';
        }
    }

    if (username.isNotEmpty && username.toLowerCase() != 'guest') {
      if (lang == 'ar') {
        return '$greeting، $username!';
      }
      return '$greeting, $username!';
    }
    return '$greeting!';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    context.watch<ChatSessionProvider>();
    final userProvider = context.watch<UserProvider>();
    final String username = userProvider.username;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final bool isDesktop = screenWidth >= 800;

    // Colors
    final Color contentColor = AppColors.primaryColor.inverted;

    final double logoSize = isDesktop
        ? 96.0
        : (isTablet ? screenWidth * 0.15 : screenWidth * 0.125);

    final double verticalSpacing = screenHeight * 0.022;

    final double titleSize =
        isDesktop ? 36.0 : (isTablet ? screenWidth * 0.04 : screenWidth * 0.06);
    final double bodyFontSize = isDesktop
        ? 16.0
        : (isTablet ? screenWidth * 0.025 : screenWidth * 0.04);

    final double buttonHeight = isDesktop
        ? 34.0
        : (isTablet ? screenHeight * 0.035 : screenHeight * 0.036);
    final double buttonSpacing =
        isDesktop ? 10.0 : (isTablet ? screenWidth * 0.02 : screenWidth * 0.02);
    final double rowSpacing = isDesktop
        ? 8.0
        : (isTablet ? screenHeight * 0.008 : screenHeight * 0.006);
    final double iconSize = isDesktop
        ? 16.0
        : (isTablet ? screenWidth * 0.035 : screenWidth * 0.035);
    final double fontSize = isDesktop
        ? 12.0
        : (isTablet ? screenWidth * 0.02 : screenWidth * 0.022);
    final double borderRadius =
        isDesktop ? 16.0 : (isTablet ? screenWidth * 0.06 : screenWidth * 0.07);

    final double buttonsAreaHeight =
        buttonHeight * 2 + rowSpacing + (buttonHeight * 0.15) + 16.0;

    final double contentMaxWidth =
        isDesktop ? 600.0 : (isTablet ? screenWidth * 0.6 : screenWidth);
    final double horizontalPadding =
        isDesktop ? 0 : (isTablet ? 0 : screenWidth * 0.12);
    final double topPadding = MediaQuery.paddingOf(context).top;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _modeAnimation,
          builder: (context, child) {
            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(bottom: widget.bottomPadding),
                    child: Column(
                      children: [
                        const Spacer(),
                        Container(
                          width: contentMaxWidth,
                          padding: EdgeInsets.only(
                              top: topPadding,
                              right: horizontalPadding,
                              left: horizontalPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // --- 1. LOGO AREA (Swapping) ---
                              Center(
                                child: SizedBox(
                                  height: logoSize,
                                  width: logoSize,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // CORTEX Logo
                                      Opacity(
                                        opacity: (1.0 - _modeAnimation.value)
                                            .clamp(0.0, 1.0),
                                        child: Transform.scale(
                                          scale: 1.0 -
                                              (_modeAnimation.value * 0.2),
                                          child: ScaleTransition(
                                            scale: _breathingScaleAnimation,
                                            child: AnimatedBuilder(
                                              animation: _bounceAnimation,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: _bounceAnimation.value,
                                                  child: child,
                                                );
                                              },
                                              child: IconButton(
                                                onPressed:
                                                    _modeAnimation.value < 0.5
                                                        ? _handleIconTap
                                                        : null,
                                                iconSize: logoSize,
                                                padding: EdgeInsets.zero,
                                                icon: SvgPicture.asset(
                                                  'assets/cortex.svg',
                                                  width: logoSize,
                                                  height: logoSize,
                                                  fit: BoxFit.fitWidth,
                                                  colorFilter: ColorFilter.mode(
                                                    AppColors
                                                        .primaryColor.inverted,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // FLUX (GHOST) Logo
                                      IgnorePointer(
                                        child: Opacity(
                                          opacity: _modeAnimation.value
                                              .clamp(0.0, 1.0),
                                          child: Transform.scale(
                                            scale: 0.8 +
                                                (_modeAnimation.value * 0.2),
                                            child: ScaleTransition(
                                              scale: _breathingScaleAnimation,
                                              child: SvgPicture.asset(
                                                'assets/icons/on/ghost.svg',
                                                width: logoSize,
                                                height: logoSize,
                                                fit: BoxFit.contain,
                                                colorFilter: ColorFilter.mode(
                                                    contentColor,
                                                    BlendMode.srcIn),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Fixed gap
                              SizedBox(height: verticalSpacing * 0.5),

                              // --- 2. CONTENT AREA (Sliding & Fading) ---
                              Stack(
                                children: [
                                  // STANDARD CONTENT
                                  IgnorePointer(
                                    ignoring: _modeAnimation.value > 0.1,
                                    child: Opacity(
                                      opacity: (1.0 - _modeAnimation.value * 2)
                                          .clamp(0.0, 1.0),
                                      child: Transform.translate(
                                        offset: Offset(
                                            0, -30.0 * _modeAnimation.value),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            // Title (Standard)
                                            _buildEntranceItem(
                                                startTime: 0.0,
                                                endTime: 0.5,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ShaderMask(
                                                      shaderCallback: (bounds) =>
                                                          LinearGradient(
                                                        colors: [
                                                          contentColor
                                                              .withValues(
                                                                  alpha: 0.55),
                                                          contentColor,
                                                          contentColor
                                                              .withValues(
                                                                  alpha: 0.55),
                                                        ],
                                                        stops:
                                                            const [0.0, 0.5, 1.0],
                                                      ).createShader(bounds),
                                                      blendMode:
                                                          BlendMode.srcIn,
                                                      child: Text(
                                                        _getGreetingText(
                                                            context, username),
                                                        style: TextStyle(
                                                          fontSize: titleSize,
                                                          letterSpacing: 0.5,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            verticalSpacing *
                                                                0.25),
                                                    Text(
                                                      _getSubtitleText(context),
                                                      style: TextStyle(
                                                        fontSize:
                                                            titleSize * 0.55,
                                                        color: contentColor
                                                            .withValues(
                                                                alpha: 0.65),
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                )),
                                            SizedBox(
                                                height: verticalSpacing * 0.3),

                                            // Description <-> Buttons (Timed, smooth crossfade, same position)
                                            SizedBox(
                                              height: buttonsAreaHeight,
                                              child: AnimatedBuilder(
                                                animation: _swapController,
                                                builder: (context, _) {
                                                  final t =
                                                      _swapController.value;
                                                  final descOpacity =
                                                      (1.0 - t).clamp(0.0, 1.0);
                                                  final btnOpacity =
                                                      t.clamp(0.0, 1.0);

                                                  // Adding smooth sliding transition similar to a cube effect
                                                  final descOffset =
                                                      Offset(0, 30.0 * t);
                                                  final btnOffset = Offset(
                                                      0, -30.0 * (1 - t));

                                                  return Stack(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    children: [
                                                      IgnorePointer(
                                                        ignoring:
                                                            descOpacity < 0.05,
                                                        child: RepaintBoundary(
                                                          child: Transform
                                                              .translate(
                                                            offset: descOffset,
                                                            child: Opacity(
                                                              opacity:
                                                                  descOpacity,
                                                              child:
                                                                  _buildEntranceItem(
                                                                startTime: 0.1,
                                                                endTime: 0.6,
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        logoSize *
                                                                            0.1,
                                                                  ),
                                                                  child: Text(
                                                                    l10n.defaultViewDescription,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          bodyFontSize,
                                                                      color: contentColor.withValues(
                                                                          alpha:
                                                                              0.8),
                                                                      height:
                                                                          1.5,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      IgnorePointer(
                                                        ignoring:
                                                            btnOpacity < 0.05,
                                                        child: RepaintBoundary(
                                                          child: Transform
                                                              .translate(
                                                            offset: btnOffset,
                                                            child: Opacity(
                                                              opacity:
                                                                  btnOpacity,
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  horizontal:
                                                                      logoSize *
                                                                          0.1,
                                                                ),
                                                                child:
                                                                    _buildFeatureButtons(
                                                                  context,
                                                                  l10n,
                                                                  buttonHeight:
                                                                      buttonHeight,
                                                                  buttonSpacing:
                                                                      buttonSpacing,
                                                                  rowSpacing:
                                                                      rowSpacing,
                                                                  iconSize:
                                                                      iconSize,
                                                                  fontSize:
                                                                      fontSize,
                                                                  borderRadius:
                                                                      borderRadius,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // FLUX CONTENT
                                  IgnorePointer(
                                    ignoring: _modeAnimation.value < 0.9,
                                    child: Opacity(
                                      opacity:
                                          ((_modeAnimation.value - 0.5) * 2)
                                              .clamp(0.0, 1.0),
                                      child: Transform.translate(
                                        offset: Offset(
                                            0,
                                            30.0 *
                                                (1.0 - _modeAnimation.value)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            SizedBox(
                                                height: verticalSpacing * 0.2),
                                            Text(
                                              l10n.fluxChatTitle,
                                              style: TextStyle(
                                                fontSize: titleSize,
                                                letterSpacing: 0.5,
                                                color: contentColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                                height: verticalSpacing * 0.6),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: logoSize * 0.1),
                                              child: Text(
                                                l10n.fluxChatDescription,
                                                style: TextStyle(
                                                  fontSize: bodyFontSize,
                                                  color: contentColor
                                                      .withValues(alpha: 0.8),
                                                  height: 1.5,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
