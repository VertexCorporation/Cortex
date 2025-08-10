import 'package:flutter/cupertino.dart';

void navigateToScreen(BuildContext context, Widget screen, {required Offset direction}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, animation, __) => screen,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final end = Offset.zero;
        final curve = Curves.ease;
        final tween = Tween(begin: direction, end: end)
            .chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}