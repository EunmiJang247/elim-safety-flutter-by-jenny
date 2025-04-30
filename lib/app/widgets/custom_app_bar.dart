import 'package:flutter/material.dart';

import '../constant/constants.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar(
      {super.key, required this.leftSide, required this.rightSide});
  final Widget leftSide;
  final Widget rightSide;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: appBarHeight,
        decoration: BoxDecoration(
            // color: Colors.black,
            color: Color(0xFFF5F5F5),
            boxShadow: [
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
              // BoxShadow(color: Colors.black, offset: Offset(0, 0), blurRadius: 0, spreadRadius: 0),
              // BoxShadow(color: Colors.black, offset: Offset(0, 0), blurRadius: 0, spreadRadius: 0),
            ]),
        child: Row(
          children: [
            SizedBox(
              width: leftBarWidth,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: widget.leftSide),
                    widget.rightSide
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
