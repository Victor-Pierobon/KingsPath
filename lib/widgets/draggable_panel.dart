import 'package:flutter/material.dart';

class DraggablePanel extends StatefulWidget {
  final Widget child;
  final Offset initialOffset;

  const DraggablePanel({
    super.key,
    required this.child,
    required this.initialOffset,
  });

  @override
  State<DraggablePanel> createState() => _DraggablePanelState();
}

class _DraggablePanelState extends State<DraggablePanel> {
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset = Offset(
              (_offset.dx + details.delta.dx).clamp(0.0, size.width - 50),
              (_offset.dy + details.delta.dy).clamp(0.0, size.height - 50),
            );
          });
        },
        child: widget.child,
      ),
    );
  }
}
