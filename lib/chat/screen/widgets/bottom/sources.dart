import "package:cortex/app.dart";
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/chat/messages/parser.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/fog.dart';
import 'package:cortex/l10n/app_localizations.dart';

class WebSearchSourcesWidget extends StatelessWidget {
  final double scale;
  final List<dynamic> sources;

  const WebSearchSourcesWidget({
    super.key,
    required this.scale,
    required this.sources,
  });

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 8 * scale),
        child: GestureDetector(
          onTap: () => _showSourcesBottomSheet(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 14 * scale, vertical: 8 * scale),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/world.svg',
                  width: 14 * scale,
                  height: 14 * scale,
                  colorFilter: ColorFilter.mode(
                    AppColors.primaryColor.inverted,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 6 * scale),
                Text(
                  AppLocalizations.of(context)!.webSearchSources,
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 12 * scale,
                    color: AppColors.primaryColor.inverted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSourcesBottomSheet(BuildContext context) {
    if (sources.isEmpty) return;

    final ScrollController scrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery
                .of(context)
                .size
                .height * 0.8,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(24 * scale)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Padding(
                padding: EdgeInsets.only(top: 12 * scale, bottom: 8 * scale),
                child: Container(
                  width: 40 * scale,
                  height: 4 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(2 * scale),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 20 * scale, vertical: 8 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.webSearchSources,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor.inverted,
                      ),
                    ),
                  ],
                ),
              ),
              // List
              Flexible(
                child: ScrollFog(
                  scrollController: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(
                        horizontal: 16 * scale, vertical: 8 * scale),
                    shrinkWrap: true,
                    itemCount: sources.length,
                    itemBuilder: (context, index) {
                      final item = sources[index];
                      String url = '';
                      String title = '';
                      if (item is String) {
                        url = item;
                      } else if (item is Map) {
                        url = item['url'] ?? item['link'] ?? '';
                        title = item['title'] ?? item['name'] ?? '';
                      } else {
                        // Assuming it could be Source object from parser.dart
                        try {
                          url = item.url;
                          title = item.title ?? '';
                        } catch (e) {
                          /*empty catch block preventer*/
                        }
                      }

                      if (url.isEmpty) return const SizedBox.shrink();

                      try {
                        final uri = Uri.parse(url);
                        final host = uri.host;
                        if (title.isEmpty) {
                          title = host.startsWith('www.')
                              ? host.substring(4)
                              : host;
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4 * scale),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                openLink(context, url);
                              },
                              borderRadius: BorderRadius.circular(12 * scale),
                              splashColor: AppColors.primaryColor.inverted
                                  .withValues(alpha: 0.1),
                              highlightColor: AppColors.primaryColor.inverted
                                  .withValues(alpha: 0.05),
                              child: Container(
                                  padding: EdgeInsets.all(12 * scale),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                        color: AppColors.border
                                            .withValues(alpha: 0.5)),
                                    borderRadius: BorderRadius.circular(
                                        12 * scale),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28 * scale,
                                        height: 28 * scale,
                                        decoration: BoxDecoration(
                                          color: AppColors.quaternaryColor,
                                          borderRadius:
                                          BorderRadius.circular(6 * scale),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontFamily: 'SF Pro Text',
                                            fontSize: 12 * scale,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryColor
                                                .inverted,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12 * scale),
                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(4 * scale),
                                        child: context
                                            .watch<InternetProvider>()
                                            .isConnected
                                            ? Image.network(
                                          'https://www.google.com/s2/favicons?domain=$host&sz=64',
                                          width: 20 * scale,
                                          height: 20 * scale,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                              SvgPicture.asset(
                                                'assets/icons/world.svg',
                                                width: 20 * scale,
                                                height: 20 * scale,
                                                colorFilter: ColorFilter.mode(
                                                    AppColors.primaryColor
                                                        .inverted,
                                                    BlendMode.srcIn),
                                              ),
                                        )
                                            : SvgPicture.asset(
                                          'assets/icons/world.svg',
                                          width: 20 * scale,
                                          height: 20 * scale,
                                          colorFilter: ColorFilter.mode(
                                              AppColors.primaryColor.inverted,
                                              BlendMode.srcIn),
                                        ),
                                      ),
                                      SizedBox(width: 12 * scale),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: TextStyle(
                                                fontFamily: 'SF Pro Text',
                                                fontSize: 15 * scale,
                                                color:
                                                AppColors.primaryColor.inverted,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2 * scale),
                                            Text(
                                              host,
                                              style: TextStyle(
                                                fontFamily: 'SF Pro Text',
                                                fontSize: 12 * scale,
                                                color: AppColors
                                                    .primaryColor.inverted
                                                    .withValues(alpha: 0.6),
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14 * scale,
                                        color: AppColors.primaryColor.inverted
                                            .withValues(alpha: 0.5),
                                      ),
                                    ],)
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                  height: MediaQuery
                      .of(context)
                      .padding
                      .bottom + 8 * scale),
            ],
          ),
        );
      },
    );
  }
}
