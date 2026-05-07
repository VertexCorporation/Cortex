part of 'input.dart';

class _WaveformSection extends StatelessWidget {
  const _WaveformSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    final double buttonSize = isTablet ? 40.0 : 36.0;
    final double buttonPadding = isTablet ? screenWidth * 0.02 : 16.0;
    final double rightPadding = buttonPadding + (buttonSize / 2);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(12.0, 24.0, rightPadding, 16.0),
      child: const WaveformVisualizer(origin: WaveOrigin.right),
    );
  }
}
