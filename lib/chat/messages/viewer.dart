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
import '../../notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as path;
import '../../theme.dart';

class PhotoViewer extends StatefulWidget {
  final File imageFile;
  const PhotoViewer({Key? key, required this.imageFile}) : super(key: key);

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
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  @override
  _PhotoViewerState createState() => _PhotoViewerState();
}

// Add SingleTickerProviderStateMixin for the animation controller
class _PhotoViewerState extends State<PhotoViewer> with SingleTickerProviderStateMixin {
  late Color navBarColor;
  late SystemUiOverlayStyle defaultStyle;

  // Controllers for the elastic zoom effect
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;


  Color darkenWithBlack(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    final r = (color.red * (1.0 - factor)).round();
    final g = (color.green * (1.0 - factor)).round();
    final b = (color.blue * (1.0 - factor)).round();
    return Color.fromARGB(color.alpha, r, g, b);
  }

  @override
  void initState() {
    super.initState();
    final themeSettings = AppColors.getSystemUIOverlayStyleForTheme(AppColors.currentTheme);
    navBarColor = themeSettings['navigationBarColor'] as Color;
    defaultStyle = SystemUiOverlayStyle(
      systemNavigationBarColor: navBarColor,
      systemNavigationBarIconBrightness:
      ThemeData.estimateBrightnessForColor(navBarColor) == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );
    final darkenedNavBarColor = darkenWithBlack(navBarColor, 0.8);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: darkenedNavBarColor,
        systemNavigationBarIconBrightness:
        ThemeData.estimateBrightnessForColor(darkenedNavBarColor) == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    // Initialize the controllers
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Animation duration
    )..addListener(() {
      // Update the transformation controller value during animation
      if (_animation != null) {
        _transformationController.value = _animation!.value;
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(defaultStyle);
    // Dispose controllers to prevent memory leaks
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // This function will be called to animate the view back to its original state
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
    Provider.of<NotificationService>(context, listen: false);
    final Size screenSize = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: darkenWithBlack(navBarColor, 0.8),
        systemNavigationBarIconBrightness:
        ThemeData.estimateBrightnessForColor(darkenWithBlack(navBarColor, 0.8)) ==
            Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.black.withOpacity(0.2)),
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
                        // Pass the controller to manage transformation
                        transformationController: _transformationController,
                        // This is called when the user stops pinching/panning
                        onInteractionEnd: (details) {
                          // Animate back to the original state
                          _animateToIdentity();
                        },
                        panEnabled: true, // Enable panning when zoomed
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
                            Colors.black.withOpacity(0.5),
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
                              await Share.shareXFiles(
                                  [XFile(widget.imageFile.path)]);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/upload.svg',
                                  width: screenSize.width * 0.05,
                                  height: screenSize.width * 0.05,
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                                const extension = '.jpg';
                                int i = 0;
                                late File localFile;
                                while (true) {
                                  final fileName = i == 0
                                      ? '$baseName$extension'
                                      : '$baseName-$i$extension';
                                  localFile =
                                      File(path.join(tempDir.path, fileName));
                                  if (!(await localFile.exists())) {
                                    break;
                                  }
                                  i++;
                                }
                                await widget.imageFile.copy(localFile.path);
                                final bool? success =
                                await GallerySaver.saveImage(localFile.path);
                                if (success == true) {
                                  notificationService.showNotification(
                                    message: localizations.downloadSuccess,
                                    isSuccess: true,
                                    bottomOffset: 0.1,
                                  );
                                } else {
                                  notificationService.showNotification(
                                    message: localizations.downloadFailed,
                                    isSuccess: false,
                                    bottomOffset: 0.1,
                                  );
                                }
                              } catch (e) {
                                notificationService.showNotification(
                                  message: localizations.downloadFailed,
                                  isSuccess: false,
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
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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