// tools.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'execution.dart';

/// Factory to build the appropriate widget based on the tool output.
class ToolWidgetFactory {
  static Widget build(String type, Map<String, dynamic> data) {
    try {
      switch (type) {
        case 'code_execution':
          return ToolAnimationWrapper(child: CodeExecutionWidget(data: data));
        case 'weather_card':
          return ToolAnimationWrapper(child: WeatherCard(data: data));
        case 'crypto_card':
          return ToolAnimationWrapper(child: CryptoCard(data: data));
        case 'chart_card':
          return ToolAnimationWrapper(child: ChartCard(data: data));
        default:
          return const WorkInProgressWidget();
      }
    } catch (e) {
      return Text('Error rendering widget: $e',
          style: const TextStyle(color: Colors.red));
    }
  }
}

class ToolAnimationWrapper extends StatelessWidget {
  final Widget child;

  const ToolAnimationWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// A beautiful weather card with gradients and details.
class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const WeatherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final city = data['city'] ?? 'Unknown';
    final current = data['current'] ?? {};
    final units = data['units'] ?? {};
    final temp = current['temperature_2m'];
    final tempUnit = units['temperature_2m'] ?? '°C';
    final conditionCode = (current['weather_code'] as num?)?.toInt() ?? 0;

    // Determine condition description and icon

    IconData icon = FontAwesomeIcons.sun;
    List<Color> gradient = [
      const Color(0xFF56CCF2),
      const Color(0xFF2F80ED)
    ]; // Sunny blue

    if (conditionCode >= 1 && conditionCode <= 3) {
      icon = FontAwesomeIcons.cloud;
      gradient = [const Color(0xFFBDC3C7), const Color(0xFF2C3E50)];
    } else if (conditionCode >= 45 && conditionCode <= 48) {
      icon = FontAwesomeIcons.smog;
      gradient = [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
    } else if (conditionCode >= 51 && conditionCode <= 67) {
      icon = FontAwesomeIcons.cloudRain;
      gradient = [const Color(0xFF4B79A1), const Color(0xFF283E51)];
    } else if (conditionCode >= 71) {
      icon = FontAwesomeIcons.snowflake;
      gradient = [const Color(0xFF83a4d4), const Color(0xFFb6fbff)];
    } else if (conditionCode >= 80 && conditionCode <= 82) {
      icon = FontAwesomeIcons.cloudShowersHeavy;
      gradient = [
        const Color(0xFF4B79A1),
        const Color(0xFF283E51)
      ]; // Rain gradient
    } else if (conditionCode >= 95) {
      icon = FontAwesomeIcons.bolt;
      gradient = [
        const Color(0xFF141E30),
        const Color(0xFF243B55)
      ]; // Stormy dark
    }

    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 8), // Removed margin (redundant)
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                city,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: Colors.white, size: 32),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$temp$tempUnit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w300,
            ),
          ),
          // Removed text condition description for cleaner UI
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(FontAwesomeIcons.wind,
                  '${current['wind_speed_10m']} ${units['wind_speed_10m']}'),
              _buildDetailItem(FontAwesomeIcons.water,
                  '${current['relative_humidity_2m']}${units['relative_humidity_2m']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}

/// A crypto card with price and a sparkline chart.
/// A crypto card with price and a sparkline chart.
class CryptoCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const CryptoCard({super.key, required this.data});

  @override
  State<CryptoCard> createState() => _CryptoCardState();
}

class _CryptoCardState extends State<CryptoCard> {
  @override
  Widget build(BuildContext context) {
    final symbolRaw = widget.data['symbol'] ?? 'CRYPTO';
    // Format symbol: BTC-USD -> Bitcoin | USD if possible, or just clearer format
    // Simple heuristic: replace - with |
    final symbol = symbolRaw.toString().replaceAll('-', ' | ');

    final price = widget.data['price'] ?? 0.0;
    final List<dynamic> rawSparkline = widget.data['sparkline'] ?? [];
    final List<double> sparkline =
    rawSparkline.map((e) => (e as num).toDouble()).toList();

    // Determine trend color
    bool isUp = true;
    if (sparkline.isNotEmpty && sparkline.length > 1) {
      isUp = sparkline.last >= sparkline.first;
    }
    final trendColor = isUp ? const Color(0xFF00C853) : const Color(0xFFFF3D00);
    final bgColor = AppColors.secondaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWithHover(
        trendColor: trendColor,
        child: Container(
          // margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          // Decoration handled by InkWithHover for border/color usually, but here we keep structure
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol, // Updated formatting
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${NumberFormat("#,##0.00").format(price)}',
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: trendColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isUp ? '+' : '-', // Just show sign as requested
                      style: TextStyle(
                          color: trendColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (sparkline.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: LineChart(
                    LineChartData(
                      gridData:
                      const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            // Calculate interval dynamically to prevent duplicates
                            interval: (sparkline.reduce(
                                    (a, b) => a > b ? a : b) -
                                sparkline.reduce(
                                        (a, b) => a < b ? a : b)) /
                                4 >
                                0
                                ? (sparkline.reduce((a, b) => a > b ? a : b) -
                                sparkline
                                    .reduce((a, b) => a < b ? a : b)) /
                                4
                                : 1.0,
                            getTitlesWidget: (value, meta) {
                              if (value == meta.min || value == meta.max) {
                                return const SizedBox
                                    .shrink(); // Hide edge labels if needed
                              }
                              return Text(
                                NumberFormat.compact().format(value),
                                style: TextStyle(
                                    color: AppColors.tertiaryColor,
                                    fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: sparkline
                              .asMap()
                              .entries
                              .map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          color: trendColor,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: trendColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrapper to add hover/touch effect (custom border opacity/color)
class InkWithHover extends StatefulWidget {
  final Widget child;
  final Color trendColor;

  const InkWithHover(
      {super.key, required this.child, required this.trendColor});

  @override
  State<InkWithHover> createState() => _InkWithHoverState();
}

class _InkWithHoverState extends State<InkWithHover> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // We wrap the child which already has decoration.
        // Ideally we should pass decoration down.
        // For now, we wrap with opacity or scale effect?
        // User asked for: "border rengi border olan ve background rengi de appcolors.background olan şekilde gelsin"
        // Actually the child already has background. Let's add a slight overlay or border change?
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: _isHovering
              ? Border.all(
              color: widget.trendColor.withValues(alpha: 0.5), width: 2)
              : null,
          color: _isHovering
              ? widget.trendColor.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: widget.child,
      ),
    );
  }
}

/// A generic chart card using fl_chart.
/// A generic chart card using fl_chart.
class ChartCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const ChartCard({super.key, required this.data});

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  @override
  Widget build(BuildContext context) {
    final type = widget.data['type'] ?? 'bar';
    final List<dynamic> labels = widget.data['labels'] ?? [];
    final List<dynamic> values = widget.data['data'] ?? [];
    final title = widget.data['title'] ?? 'Chart';

    // Basic validation
    if (labels.isEmpty || values.isEmpty) return const SizedBox.shrink();

    final bgColor = AppColors.secondaryColor;
    final primaryColor = AppColors.senaryColor;

    Widget chartWidget;

    if (type == 'pie') {
      chartWidget = PieChart(
        PieChartData(
          sections: List.generate(values.length, (i) {
            final val = (values[i] as num).toDouble();
            final color = Colors.primaries[i % Colors.primaries.length];
            return PieChartSectionData(
              color: color,
              value: val,
              title: '${labels[i]}',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
        ),
      );
    } else if (type == 'line') {
      chartWidget = LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(
                  color: AppColors.border.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compact().format(value),
                    style:
                    TextStyle(color: AppColors.tertiaryColor, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        labels[index].toString(),
                        style: TextStyle(
                            color: AppColors.tertiaryColor, fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(values.length, (i) {
                return FlSpot(i.toDouble(), (values[i] as num).toDouble());
              }),
              isCurved: true,
              color: primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: primaryColor.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      );
    } else {
      // Bar Chart (Default)
      chartWidget = BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compact().format(value),
                    style:
                    TextStyle(color: AppColors.tertiaryColor, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        labels[index].toString(),
                        style: TextStyle(
                            color: AppColors.tertiaryColor, fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          barGroups: List.generate(values.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (values[i] as num).toDouble(),
                  color: primaryColor,
                  width: 16,
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: values
                        .map((e) => e as num)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() *
                        1.1,
                    color: AppColors.border.withValues(alpha: 0.2),
                  ),
                ),
              ],
            );
          }),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                chartWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget indicating that a tool is currently working (loading state).
class WorkInProgressWidget extends StatefulWidget {
  const WorkInProgressWidget({super.key});

  @override
  State<WorkInProgressWidget> createState() => _WorkInProgressWidgetState();
}

class _WorkInProgressWidgetState extends State<WorkInProgressWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Slower, subtle shimmer
    )
      ..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final text = appLocalizations.workInProgress; // Ensure ARB key exists!

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_full_rounded,
                    size: 16, color: AppColors.tertiaryColor),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: AppColors.tertiaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Shimmer Overlay
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: 0.8,
                    alignment: Alignment(_animation.value, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            AppColors.tertiaryColor.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
