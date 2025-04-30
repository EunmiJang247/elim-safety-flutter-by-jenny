import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/app_color.dart';

class HelpButtonWidget extends StatelessWidget {
  final double currentScale;
  final double scaleStd;
  final VoidCallback onTap;

  const HelpButtonWidget({
    super.key,
    required this.currentScale,
    required this.scaleStd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          margin: EdgeInsets.only(top: 16, right: 16),
          decoration: BoxDecoration(
            color: currentScale < scaleStd ? Colors.white70 : AppColors.c4,
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
              "?",
              style: TextStyle(
                  color: currentScale < scaleStd ? Colors.black : Colors.white,
                  fontFamily: "Pretendard",
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
