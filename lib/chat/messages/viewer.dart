// viewer.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../darkener.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:path/path.dart' as path;
import '../../notifications/introvert.dart';
import '../../theme.dart';

class PhotoViewer extends StatefulWidget {
  final File imageFile;
  const PhotoViewer({super.key, required this.imageFile});

  static Route route(File imageFile) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 50),
      reverseTransitionDuration: const Duration(milliseconds: 50),
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) => PhotoViewer(imageFile: imageFile),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
        final scaleAnim = Tween<double>(begin: 0.90, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(scale: scaleAnim, child: child),
        );
      },
      settings: const RouteSettings(name: 'PhotoViewer'),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  PhotoViewerState createState() => PhotoViewerState();
}

class PhotoViewerState extends State<PhotoViewer>
    with SingleTickerProviderStateMixin {
  late SystemUiOverlayStyle defaultStyle;

  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    final theme = AppColors.currentTheme;
    final currentSettings = AppColors.getSystemUIOverlayStyleForTheme(theme);
    defaultStyle = SystemUiOverlayStyle(
      systemNavigationBarColor: currentSettings['navigationBarColor'] as Color,
      systemNavigationBarIconBrightness:
          currentSettings['navigationBarIconBrightness'] as Brightness,
      statusBarColor: currentSettings['statusBarColor'] as Color,
      statusBarIconBrightness:
          currentSettings['statusBarIconBrightness'] as Brightness,
    );

    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(defaultStyle);
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _animateToIdentity() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final notificationService =
        Provider.of<IntrovertNotificationService>(context, listen: false);
    final Size screenSize = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Darkener.getDarkenedOverlayStyle(factor: 0.8),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.black.withValues(alpha: 0.2)),
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: screenSize.width * 0.05,
                        right: screenSize.width * 0.05,
                        top: screenSize.height * 0.1,
                        bottom: screenSize.height * 0.1,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: screenSize.width * 0.9,
                        maxHeight: screenSize.height * 0.8,
                      ),
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        onInteractionEnd: (details) {
                          _animateToIdentity();
                        },
                        panEnabled: true,
                        scaleEnabled: true,
                        minScale: 1.0,
                        maxScale: 4.0,
                        boundaryMargin: EdgeInsets.all(screenSize.width * 0.1),
                        clipBehavior: Clip.none,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(screenSize.width * 0.02),
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: screenSize.height * 0.2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenSize.height * 0.02,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: screenSize.width * 0.07,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: screenSize.height * 0.02,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final box =
                                  context.findRenderObject() as RenderBox?;
                              await SharePlus.instance.share(
                                ShareParams(
                                  files: [XFile(widget.imageFile.path)],
                                  sharePositionOrigin:
                                      box!.localToGlobal(Offset.zero) &
                                          box.size,
                                ),
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/world.svg',
                                  width: screenSize.width * 0.05,
                                  height: screenSize.width * 0.05,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.white, BlendMode.srcIn),
                                ),
                                SizedBox(height: screenSize.height * 0.005),
                                Text(
                                  localizations.share,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenSize.width * 0.03,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: screenSize.width * 0.002,
                          height: screenSize.height * 0.06,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                final tempDir = await getTemporaryDirectory();
                                final baseName = 'cortex';
                                const variant = '.jpg';
                                int i = 0;
                                late File localFile;
                                while (true) {
                                  final fileName = i == 0
                                      ? '$baseName$variant'
                                      : '$baseName-$i$variant';
                                  localFile =
                                      File(path.join(tempDir.path, fileName));
                                  if (!(await localFile.exists())) {
                                    break;
                                  }
                                  i++;
                                }
                                await widget.imageFile.copy(localFile.path);
                                final bool? success =
                                    await GallerySaver.saveImage(
                                        localFile.path);
                                if (success == true) {
                                  notificationService.showNotification(
                                    message: localizations.downloadSuccess,
                                    type: NotificationType.success,
                                    bottomOffset: 0.1,
                                  );
                                } else {
                                  notificationService.showNotification(
                                    message: localizations.downloadFailed,
                                    type: NotificationType.error,
                                    bottomOffset: 0.1,
                                  );
                                }
                              } catch (e) {
                                notificationService.showNotification(
                                  message: localizations.downloadFailed,
                                  type: NotificationType.error,
                                  bottomOffset: 0.1,
                                );
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/download.svg',
                                  width: screenSize.width * 0.05,
                                  height: screenSize.width * 0.05,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.white, BlendMode.srcIn),
                                ),
                                SizedBox(height: screenSize.height * 0.005),
                                Text(
                                  localizations.download,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenSize.width * 0.03,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
