import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/header.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';

class ProjectDetailLayout extends StatelessWidget {
  final Widget child;

  const ProjectDetailLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              const ProjectChecksHeader(),
              Container(
                padding: EdgeInsets.only(
                  left: leftBarWidth,
                  top: appBarHeight,
                ),
                child: child,
              ),
              const LeftMenuBar(),
            ],
          ),
        ),
      ),
    );
  }
}
