import 'package:flutter/material.dart';

/// Returns the appropriate alignment based on the current text direction.
extension RTLAlignment on BuildContext {
  Alignment get startAlignment {
    return Directionality.of(this) == TextDirection.rtl
        ? Alignment.centerRight
        : Alignment.centerLeft;
  }

  Alignment get endAlignment {
    return Directionality.of(this) == TextDirection.rtl
        ? Alignment.centerLeft
        : Alignment.centerRight;
  }

  CrossAxisAlignment get startCrossAxis {
    return Directionality.of(this) == TextDirection.rtl
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
  }

  bool get isRTL => Directionality.of(this) == TextDirection.rtl;
}

/// A widget that flips its icon for RTL layout (e.g. back arrows, chevrons).
class RTLIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const RTLIcon(this.icon, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return Transform.scale(
      scaleX: isRTL ? -1 : 1,
      child: Icon(icon, size: size, color: color),
    );
  }
}

/// Directional padding that flips start/end in RTL
class DirectionalPadding extends StatelessWidget {
  final double start;
  final double end;
  final double top;
  final double bottom;
  final Widget child;

  const DirectionalPadding({
    super.key,
    required this.child,
    this.start = 0,
    this.end = 0,
    this.top = 0,
    this.bottom = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: start,
        end: end,
        top: top,
        bottom: bottom,
      ),
      child: child,
    );
  }
}
