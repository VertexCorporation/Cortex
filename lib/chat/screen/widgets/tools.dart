import 'package:cortex/app.dart';
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
          return const SizedBox.shrink();
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
    final conditionCode = current['weather_code'] ?? 0;

    // Determine condition description and icon
    String condition = 'Clear';
    IconData icon = FontAwesomeIcons.sun;
    List<Color> gradient = [
      const Color(0xFF56CCF2),
      const Color(0xFF2F80ED)
    ]; // Sunny blue

    if (conditionCode >= 1 && conditionCode <= 3) {
      condition = 'Cloudy';
      icon = FontAwesomeIcons.cloud;
      gradient = [const Color(0xFFBDC3C7), const Color(0xFF2C3E50)];
    } else if (conditionCode >= 45 && conditionCode <= 48) {
      condition = 'Foggy';
      icon = FontAwesomeIcons.smog;
      gradient = [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
    } else if (conditionCode >= 51 && conditionCode <= 67) {
      condition = 'Rainy';
      icon = FontAwesomeIcons.cloudRain;
      gradient = [const Color(0xFF4B79A1), const Color(0xFF283E51)];
    } else if (conditionCode >= 71) {
      condition = 'Snowy';
      icon = FontAwesomeIcons.snowflake;
      gradient = [const Color(0xFF83a4d4), const Color(0xFFb6fbff)];
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
          Text(
            condition,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
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
class CryptoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const CryptoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final symbol = data['symbol'] ?? 'CRYPTO';
    final price = data['price'] ?? 0.0;
    final List<dynamic> rawSparkline = data['sparkline'] ?? [];
    final List<double> sparkline =
    rawSparkline.map((e) => (e as num).toDouble()).toList();

    // Determine trend color
    bool isUp = true;
    if (sparkline.isNotEmpty && sparkline.length > 1) {
      isUp = sparkline.last >= sparkline.first;
    }
    final trendColor = isUp ? const Color(0xFF00C853) : const Color(0xFFFF3D00);
    final bgColor = AppColors.background;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
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
                    symbol,
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
                  isUp ? '+ Trend' : '- Trend',
                  style:
                  TextStyle(color: trendColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sparkline.isNotEmpty)
            SizedBox(
              height: 60,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
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
    );
  }
}

/// A generic chart card using fl_chart.
class ChartCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final type = data['type'] ?? 'bar';
    final List<dynamic> labels = data['labels'] ?? [];
    final List<dynamic> values = data['data'] ?? [];
    final title = data['title'] ?? 'Chart';

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
            child: chartWidget,
          ),
        ],
      ),
    );
  }
}
