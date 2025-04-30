import 'package:flutter/material.dart';

class DragIndicatorWidget extends StatefulWidget {
  final String? message;
  final Color bgColor;
  final Color textColor;
  final bool visible;
  final double top;

  /// 이동 가능함을 나타내는 표시 위젯
  const DragIndicatorWidget({
    super.key,
    this.message,
    this.bgColor = Colors.black,
    this.textColor = Colors.white,
    this.visible = true,
    this.top = 20,
  });

  @override
  State<DragIndicatorWidget> createState() => _DragIndicatorWidgetState();
}

class _DragIndicatorWidgetState extends State<DragIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 200,
        height: 50,
        margin: EdgeInsets.only(top: widget.top + 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 1),
                blurRadius: 2,
                spreadRadius: -1),
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0),
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 4),
                blurRadius: 6,
                spreadRadius: -4),
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 10),
                blurRadius: 15,
                spreadRadius: -3),
          ],
        ),
        child: Center(
          child: Text(
            widget.message ?? "이동하세요",
            style: TextStyle(
                color: Colors.white,
                fontFamily: "Pretendard",
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

/// 화면 상단에 이동 지시자를 표시하는 위젯
class TopDragIndicatorWidget extends StatelessWidget {
  final bool visible;
  final String? message;

  const TopDragIndicatorWidget({
    super.key,
    this.visible = true,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Center(
        child: DragIndicatorWidget(
          visible: visible,
          message: message,
        ),
      ),
    );
  }
}
