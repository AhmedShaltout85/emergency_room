// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CustomDraggableScrollableSheet extends StatefulWidget {
  final Widget Function(BuildContext, double) builder;
  final double minExtent;
  final double maxExtent;

  const CustomDraggableScrollableSheet({
    super.key,
    required this.builder,
    this.minExtent = 0.2,
    this.maxExtent = 1.0,
  });

  @override
  _CustomDraggableScrollableSheetState createState() =>
      _CustomDraggableScrollableSheetState();
}

class _CustomDraggableScrollableSheetState
    extends State<CustomDraggableScrollableSheet> {
  late double _currentExtent;

  @override
  void initState() {
    super.initState();
    _currentExtent = widget.minExtent;
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    setState(() {
      _currentExtent += details.primaryDelta! / constraints.maxHeight;
      _currentExtent = _currentExtent.clamp(widget.minExtent, widget.maxExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: constraints.maxHeight * _currentExtent,
              child: GestureDetector(
                onVerticalDragUpdate: (details) =>
                    _onDragUpdate(details, constraints),
                child: Material(
                  elevation: 4,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.white,
                  child: widget.builder(context, _currentExtent),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
