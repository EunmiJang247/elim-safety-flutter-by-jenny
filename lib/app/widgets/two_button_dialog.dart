import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';

class TwoButtonDialog extends StatelessWidget {
  const TwoButtonDialog({
    super.key,
    required this.content,
    required this.yes,
    required this.no,
    required this.onYes,
    required this.onNo,
    this.height = 168,
    this.width = 328,
  });
  final Widget content;
  final String yes;
  final String no;
  final VoidCallback onYes;
  final VoidCallback onNo;
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
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onNo,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  offset: Offset(1, 1),
                                  blurRadius: 1)
                            ]),
                        child: Center(
                          child: Text(
                            no,
                            style: TextStyle(
                                fontFamily: "Pretendard",
                                color: AppColors.c1,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gaps.w16,
                  Expanded(
                    child: InkWell(
                      onTap: onYes,
                      child: Container(
                        decoration: BoxDecoration(
                            color: AppColors.button,
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
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
