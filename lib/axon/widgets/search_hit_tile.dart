import "package:cortex/app.dart";
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/theme.dart';

import 'package:cortex/axon/inbox/logic/search_hit.dart';
import 'package:intl/intl.dart';

class SearchHitTile extends StatelessWidget {
  final SearchHit hit;
  final VoidCallback onTap;

  const SearchHitTile({
    super.key,
    required this.hit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // We want to extract a snippet around the match
    String snippet = hit.snippet.replaceAll('\n', ' ');
    int matchIndex = snippet.toLowerCase().indexOf(hit.query.toLowerCase());

    // Safety check if the query is not literally in the snippet (e.g., tokenized search)
    if (matchIndex == -1) matchIndex = 0;

    // Trim the snippet to be around the match
    int startIndex = (matchIndex - 30).clamp(0, snippet.length);
    int endIndex =
        (matchIndex + hit.query.length + 30).clamp(0, snippet.length);
    String displaySnippet = snippet.substring(startIndex, endIndex);
    if (startIndex > 0) displaySnippet = '...$displaySnippet';
    if (endIndex < snippet.length) displaySnippet = '$displaySnippet...';

    // Now format with bold text
    List<TextSpan> spans = _highlightQuery(displaySnippet, hit.query);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.primaryColor.withValues(alpha: 0.1),
      highlightColor: AppColors.primaryColor.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/search.svg',
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                      AppColors.secondaryColor, BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hit.title,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatTimestamp(hit.timestamp),
                  style: TextStyle(
                    color:
                        AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                  fontSize: 13,
                  height: 1.4,
                ),
                children: spans,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _highlightQuery(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];

    final matches = query.toLowerCase().allMatches(text.toLowerCase());
    if (matches.isEmpty) return [TextSpan(text: text)];

    List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          color: AppColors.primaryColor.inverted,
          fontWeight: FontWeight.bold,
        ),
      ));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  String _formatTimestamp(DateTime dt) {
    return DateFormat('MMM d, HH:mm').format(dt);
  }
}
