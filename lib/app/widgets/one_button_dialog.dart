import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';

class OneButtonDialog extends StatelessWidget {
  const OneButtonDialog({
    super.key,
    required this.content,
    required this.yes,
    required this.onYes,
    this.height = 168,
    this.width = 328,
  });
  final Widget content;
  final String yes;
  final VoidCallback onYes;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Column(
          children: [
            content,
            Gaps.h16,
            Expanded(
              child: InkWell(
                onTap: onYes,
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.c4,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: Offset(1, 1),
                            blurRadius: 1)
                      ]),
                  child: Center(
                    child: Text(
                      yes,
                      style: TextStyle(
                          fontFamily: "Pretendard",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
