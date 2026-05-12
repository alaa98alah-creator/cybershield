import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
}

extension HexColor on String {
  Color toColor() {
    final buffer = StringBuffer();
    if (length == 6 || length == 7) buffer.write('ff');
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 32));
  }
}

extension WidgetExtensions on Widget {
  Widget withBottomNav(int currentIndex) {
    return _BottomNavWrapper(currentIndex: currentIndex, child: this);
  }
}

class _BottomNavWrapper extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const _BottomNavWrapper({required this.currentIndex, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
