import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import '../../messages/codeblocks.dart';

class CodeExecutionWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  const CodeExecutionWidget({super.key, required this.data});

  @override
  State<CodeExecutionWidget> createState() => _CodeExecutionWidgetState();
}

class _CodeExecutionWidgetState extends State<CodeExecutionWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final code = widget.data['code'] ?? '';
    final output = widget.data['output'] ?? '';
    final error = widget.data['error'];
    final bool hasError = error != null && error.toString().isNotEmpty;

    // final themeColors = AppColors.getThemeColors(AppColors.currentTheme);
    // final isDark = themeColors.primaryColor == Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
              ? AppColors.septenaryColor.withValues(alpha: 0.5)
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.terminal_rounded,
                    size: 18,
                    color: hasError
                        ? AppColors.septenaryColor
                        : AppColors.tertiaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Python Code',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasError
                          ? AppColors.septenaryColor
                          : AppColors.primaryColor.inverted,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.tertiaryColor,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            const Divider(height: 1),
            // Code Block
            Padding(
              padding: const EdgeInsets.all(12),
              child: CodeBlockWidget(
                code: code,
                language: 'python',
              ),
            ),
            // Output Section
            if (output.isNotEmpty || hasError) ...[
              const Divider(height: 1),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(
                      0xFF1E1E1E), // Always dark terminal background
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OUTPUT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (hasError)
                      SelectableText(
                        error,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Color(0xFFEF5350), // Soft Red
                        ),
                      ),
                    if (output.isNotEmpty)
                      SelectableText(
                        output,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Color(0xFFE0E0E0), // Off-white
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ]
        ],
      ),
    );
  }
}
