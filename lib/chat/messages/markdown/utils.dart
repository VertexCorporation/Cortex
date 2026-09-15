import 'dart:typed_data';

import 'package:cortex/design.dart';
import 'package:cortex/app.dart';
import 'package:cortex/fog.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/notifications/introvert.dart';

double baseFs(BuildContext context) {
  final view = View.of(context);
  final physicalWidth = view.physicalSize.width;
  final devicePixelRatio = view.devicePixelRatio;
  return (physicalWidth / devicePixelRatio) * 0.044;
}

final RegExp _multlineOpen = RegExp(r'\\begin\{multline');
final RegExp _multlinePair =
    RegExp(r'\\begin\{(multline\*?)\}([\s\S]*?)(?:\\end\{\1\}|$)');
final RegExp _trailingRowBreak = RegExp(r'(?:\s*\\\\)+\s*$');

const String _generatedFileOrigin =
    'https://executetool-o5h7dmtija-ew.a.run.app';
const int _maxGeneratedFileBytes = 64 * 1024 * 1024;

bool isGeneratedFileLink(String rawUrl) {
  final value = rawUrl.trim();
  if (value.startsWith('/file/') ||
      value.startsWith('file/') ||
      value.startsWith('/files/') ||
      value.startsWith('files/')) {
    return true;
  }

  final uri = Uri.tryParse(value);
  if (uri == null) return false;
  return uri.scheme == 'https' &&
      uri.host == 'executetool-o5h7dmtija-ew.a.run.app' &&
      (uri.path.startsWith('/file/') || uri.path.startsWith('/files/'));
}

Uri? _resolveGeneratedFileUri(String rawUrl) {
  final value = rawUrl.trim();
  if (!isGeneratedFileLink(value)) return null;

  final direct = Uri.tryParse(value);
  if (direct != null && direct.hasScheme) return direct;

  final normalized = value.startsWith('/') ? value : '/$value';
  return Uri.parse(_generatedFileOrigin).resolve(normalized);
}

String generatedFileDownloadLabel(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return switch (code) {
    'tr' => 'İndir',
    'de' => 'Herunterladen',
    'es' => 'Descargar',
    'fr' => 'Télécharger',
    'it' => 'Scarica',
    'pt' => 'Baixar',
    'ru' => 'Скачать',
    'ar' => 'تنزيل',
    'zh' => '下载',
    'ja' => 'ダウンロード',
    'ko' => '다운로드',
    'nl' => 'Downloaden',
    'sv' => 'Ladda ner',
    'no' => 'Last ned',
    'id' => 'Unduh',
    'hi' => 'डाउनलोड',
    'hu' => 'Letöltés',
    'cs' => 'Stáhnout',
    'az' => 'Endir',
    _ => 'Download',
  };
}

String _generatedFileName(Uri uri) {
  if (uri.pathSegments.isEmpty) return 'cortex_file';
  final decoded = Uri.decodeComponent(uri.pathSegments.last).trim();
  if (decoded.isEmpty) return 'cortex_file';
  return decoded.replaceAll(RegExp(r'[^A-Za-z0-9._()\- ]'), '_');
}

String _downloadDialogTitle(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'tr'
      ? 'Dosyayı indir'
      : 'Download file';
}

String _downloadedMessage(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'tr'
      ? 'Dosya indirildi'
      : 'File downloaded';
}

Future<void> downloadGeneratedFile(
  BuildContext context,
  String rawUrl,
) async {
  final uri = _resolveGeneratedFileUri(rawUrl);
  if (uri == null) return;

  try {
    final headers = <String, dynamic>{};
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final client = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(minutes: 2),
        followRedirects: true,
        maxRedirects: 4,
      ),
    );

    final response = await client.get<ResponseBody>(
      uri.toString(),
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );

    final declared =
        int.tryParse(response.headers.value(Headers.contentLengthHeader) ?? '');
    if (declared != null && declared > _maxGeneratedFileBytes) {
      throw StateError('Generated file is too large.');
    }

    final body = response.data;
    if (body == null) throw StateError('Empty generated file response.');

    final builder = BytesBuilder(copy: false);
    var total = 0;
    await for (final chunk in body.stream) {
      total += chunk.length;
      if (total > _maxGeneratedFileBytes) {
        throw StateError('Generated file is too large.');
      }
      builder.add(chunk);
    }

    final bytes = builder.takeBytes();
    if (bytes.isEmpty) throw StateError('Generated file is empty.');

    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: _downloadDialogTitle(context),
      fileName: _generatedFileName(uri),
      bytes: bytes,
    );

    if (savedPath != null && context.mounted) {
      Provider.of<IntrovertNotificationService>(context, listen: false)
          .showNotification(
        message: _downloadedMessage(context),
        type: NotificationType.success,
        bottomOffset: 0.22,
      );
    }
  } catch (_) {
    if (!context.mounted) return;
    Provider.of<IntrovertNotificationService>(context, listen: false)
        .showNotification(
      message: AppLocalizations.of(context)!.anErrorOccurred,
      type: NotificationType.error,
      bottomOffset: 0.22,
    );
  }
}

/// Normalizes the amsmath `multline` environment (and its starred form) to
/// something flutter_math_fork 0.7.4 can actually render.
String normalizeMultiline(String latex) {
  if (!_multlineOpen.hasMatch(latex)) return latex;
  return latex.replaceAllMapped(_multlinePair, (m) {
    var body = m.group(2) ?? '';
    body = body.replaceFirst(_trailingRowBreak, '');
    return '\\begin{aligned}$body\\end{aligned}';
  });
}

class SafeMathTex extends StatefulWidget {
  final String latex;
  final TextStyle textStyle;
  final bool display;

  const SafeMathTex({
    required this.latex,
    required this.textStyle,
    this.display = false,
    super.key,
  });

  @override
  State<SafeMathTex> createState() => _SafeMathTexState();
}

class _SafeMathTexState extends State<SafeMathTex> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    try {
      content = Math.tex(
        normalizeMultiline(widget.latex),
        textStyle: widget.textStyle,
        onErrorFallback: (_) => Text(widget.latex, style: widget.textStyle),
      );
    } catch (_) {
      content = Text(widget.latex, style: widget.textStyle);
    }

    if (!widget.display) return content;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
          child: ScrollFogHorizontal(
            scrollController: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: content,
            ),
          ),
        );
      }),
    );
  }
}

class MatchRange {
  final int start, end;
  final String text, type;

  MatchRange(
      {required this.start,
      required this.end,
      required this.text,
      required this.type});
}

void openLink(BuildContext context, String urlString) async {
  if (isGeneratedFileLink(urlString)) {
    await downloadGeneratedFile(context, urlString);
    return;
  }

  final uri = Uri.tryParse(urlString);
  if (uri == null) return;
  final l10n = AppLocalizations.of(context)!;
  final warningMessage =
      l10n.openLinkWarningMessage(urlString).replaceAll(r'\n', '\n');

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        width: 1.0,
      ),
    ),
    builder: (BuildContext sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/world.svg',
                  width: CortexDesign.icon,
                  height: CortexDesign.icon,
                  colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted, BlendMode.srcIn),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.openLinkWarningTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor.inverted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              warningMessage,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryColor.inverted,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(
                    l10n.openLinkCancel,
                    style: TextStyle(
                        color: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor.inverted,
                    foregroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    final success = await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                    if (!success && context.mounted) {
                      Provider.of<IntrovertNotificationService>(context,
                              listen: false)
                          .showNotification(
                        message: AppLocalizations.of(context)!.anErrorOccurred,
                        type: NotificationType.error,
                        bottomOffset: 0.22,
                      );
                    }
                  },
                  child: Text(l10n.openLinkConfirm),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
