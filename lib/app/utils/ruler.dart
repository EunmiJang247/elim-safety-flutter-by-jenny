import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RulerWidget extends StatelessWidget {
  final double startValue;
  final double endValue;
  final double value;
  final ScrollController controller;

  const RulerWidget({
    super.key,
    required this.startValue,
    required this.endValue,
    required this.controller,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    double totalWidth = (endValue - startValue) * 10 * 5; // 마디 사이의 길이 2px 적용

    return Center(
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        color: Colors.black.withOpacity(0.1),
        width: double.infinity,
        height: 70,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SingleChildScrollView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(), // 바운스 효과 제거
                child: Padding(
                  padding: EdgeInsets.only(
                    left: Get.width * .5,
                    right: Get.width * .5,
                  ),
                  child: CustomPaint(
                    size: Size(totalWidth, 100),
                    painter: RulerPainter(
                        startValue: startValue, endValue: endValue),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 2,
                  height: 30,
                  color: Colors.yellow,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 20,
                child: Text(
                  "${value}x",
                  style: const TextStyle(
                    color: Colors.yellow,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  final double startValue;
  final double endValue;

  RulerPainter({required this.startValue, required this.endValue});

  bool _isCloseTo(double value, double target, double epsilon) {
    return (value - target).abs() < epsilon;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    final paint2 = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    double xOffset = 0;
    for (double i = startValue; i <= endValue; i += 0.1) {
      double roundedI = double.parse(i.toStringAsFixed(1));

      if (_isCloseTo(roundedI % 1, 0, 0.0001)) {
        // 정수 부분 큰 마디
        canvas.drawLine(Offset(xOffset, 0), Offset(xOffset, 18), paint2);
      } else {
        // 작은 마디
        canvas.drawLine(Offset(xOffset, 0), Offset(xOffset, 10), paint);
      }

      xOffset += 5; // 마디 사이의 간격 5px
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
