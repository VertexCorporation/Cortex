import 'dart:typed_data';

import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';

import 'service.dart';

/// Small integration logo renderer shared by the Plugins screen, permission
/// prompts and tool activity UI. [IntegrationService.loadLogo] enforces the
/// 2 MiB network limit before any bytes are handed to Image.memory.
class IntegrationLogo extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final double size;

  const IntegrationLogo({
    super.key,
    required this.name,
    required this.logoUrl,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FutureBuilder<Uint8List?>(
        future: IntegrationService.instance.loadLogo(logoUrl),
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes != null && bytes.isNotEmpty) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.22),
              child: Image.memory(
                bytes,
                width: size,
                height: size,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
              ),
            );
          }

          final letter = name.trim().isEmpty
              ? '•'
              : name.trim().characters.first.toUpperCase();
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(size * 0.22),
              border: Border.all(
                color: AppColors.primaryColor.inverted.withValues(alpha: 0.10),
              ),
            ),
            child: Text(
              letter,
              style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontFamily: 'Inter',
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }
}
