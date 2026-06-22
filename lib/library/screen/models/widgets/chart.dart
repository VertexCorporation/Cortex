import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../theme.dart';

class SystemInfoChart extends StatefulWidget {
  final int totalStorage;
  final int usedStorage;
  final int totalMemory;
  final int usedMemory;

  const SystemInfoChart({
    super.key,
    required this.totalStorage,
    required this.usedStorage,
    required this.totalMemory,
    required this.usedMemory,
  });

  @override
  SystemInfoChartState createState() => SystemInfoChartState();
}

class SystemInfoChartState extends State<SystemInfoChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _storageAnimation;
  late Animation<double> _memoryAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _storageAnimation = Tween<double>(begin: 0, end: widget.usedStorage.toDouble())
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _memoryAnimation = Tween<double>(begin: 0, end: widget.usedMemory.toDouble())
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatSize(double megabytes) {
    if (megabytes >= 1024) {
      return '${(megabytes / 1024).toStringAsFixed(1)} GB';
    }
    return '${megabytes.toStringAsFixed(0)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final themeProvider = Provider.of<ThemeProvider>(context);
    AppColors.currentTheme = themeProvider.currentTheme;

    // Soft gradient choices based on theme
    final isDark = AppColors.currentTheme == 'dark';
    
    // Gradient definitions
    final List<Color> storageGradient = [
      AppColors.senaryColor,
      AppColors.senaryColor.withValues(alpha: 0.7),
    ];
    
    final List<Color> memoryGradient = [
      AppColors.premium,
      AppColors.premium.withValues(alpha: 0.7),
    ];

    return Column(
      children: [
        const SizedBox(height: 8.0),
        // Storage Card
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            double animatedUsedStorage = _storageAnimation.value;
            double progress = widget.totalStorage > 0
                ? animatedUsedStorage / widget.totalStorage
                : 0.0;

            return _buildSystemCard(
              title: localizations.usedStorage,
              icon: Icons.storage_rounded,
              usedValue: animatedUsedStorage,
              totalValue: widget.totalStorage.toDouble(),
              progress: progress,
              gradient: storageGradient,
              accentColor: AppColors.senaryColor,
              screenWidth: screenWidth,
              isDark: isDark,
            );
          },
        ),
        const SizedBox(height: 16.0),
        // Memory Card
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            double animatedUsedMemory = _memoryAnimation.value;
            double progress = widget.totalMemory > 0
                ? animatedUsedMemory / widget.totalMemory
                : 0.0;

            return _buildSystemCard(
              title: localizations.usedMemory,
              icon: Icons.memory_rounded,
              usedValue: animatedUsedMemory,
              totalValue: widget.totalMemory.toDouble(),
              progress: progress,
              gradient: memoryGradient,
              accentColor: AppColors.premium,
              screenWidth: screenWidth,
              isDark: isDark,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSystemCard({
    required String title,
    required IconData icon,
    required double usedValue,
    required double totalValue,
    required double progress,
    required List<Color> gradient,
    required Color accentColor,
    required double screenWidth,
    required bool isDark,
  }) {
    final percentage = (progress * 100).clamp(0.0, 100.0);
    final cardBg = AppColors.secondaryColor;
    final progressTrackColor = AppColors.quaternaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Icon, Title, and Percentage Tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          
          // Row 2: Progress Bar
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 10.0,
                decoration: BoxDecoration(
                  color: progressTrackColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 10.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          
          // Row 3: Used | Total Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatSize(usedValue)} / ${_formatSize(totalValue)}',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.tertiaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                percentage > 85 ? 'Yüksek Kullanım' : 'Kararlı',
                style: TextStyle(
                  fontSize: 11.0,
                  color: percentage > 85 ? Colors.orange : AppColors.tertiaryColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
