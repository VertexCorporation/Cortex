part of 'input.dart';

// --- RAG / Document Chat Status Chip ---
// Shown above the input field while document chat is enabled. Lets the user
// see how many documents are in scope, open the library to manage them, or
// quickly disable the feature.
class _RagStatusChip extends StatelessWidget {
  final double screenWidth;

  const _RagStatusChip({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();
    final documentIds = inputProvider.ragDocumentIds;
    if (!inputProvider.ragEnabled || documentIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final inverted = AppColors.primaryColor.inverted;
    final accent = AppColors.primaryColor;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.02,
        0,
        screenWidth * 0.02,
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/attachment.svg',
                  width: 15,
                  height: 15,
                  colorFilter: ColorFilter.mode(inverted, BlendMode.srcIn),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.ragActiveDocs(documentIds.length),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: inverted,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _openLibrary(context),
                  child: Text(
                    l10n.ragFeatureTitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: accent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => context.read<InputProvider>().clearRag(),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: inverted.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openLibrary(BuildContext context) {
    navigateToScreen(
      const DocumentLibraryScreen(),
      direction: const Offset(1.0, 0.0),
    );
  }
}
