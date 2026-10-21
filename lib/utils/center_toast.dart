// lib/utils/center_toast.dart
//
// A toast that is really shown in the CENTER of the screen (web + mobile).
// fluttertoast cannot do this on Flutter web: the web implementation only
// supports top / bottom vertically, so ToastGravity.CENTER is ignored there.

import 'package:flutter/material.dart';

void showCenterToast(
  BuildContext context,
  String message, {
  Color color = Colors.red,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: IgnorePointer(
        child: _CenterToast(message: message, color: color, duration: duration),
      ),
    ),
  );
  overlay.insert(entry);

  Future.delayed(duration, () {
    if (entry.mounted) entry.remove();
  });
}

class _CenterToast extends StatefulWidget {
  const _CenterToast({
    required this.message,
    required this.color,
    required this.duration,
  });

  final String message;
  final Color color;
  final Duration duration;

  @override
  State<_CenterToast> createState() => _CenterToastState();
}

class _CenterToastState extends State<_CenterToast> {
  static const _fade = Duration(milliseconds: 250);
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // fade in on the next frame, fade out just before the entry is removed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
    Future.delayed(widget.duration - _fade, () {
      if (mounted) setState(() => _opacity = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: _fade,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
