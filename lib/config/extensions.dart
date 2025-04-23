import 'dart:ui';

extension ColorExtension on Color {
  /// the value is in range of 0.0 ~ 1.0
  Color toOpacity(double value) {
    return withAlpha((value * 255).toInt());
  }
}
