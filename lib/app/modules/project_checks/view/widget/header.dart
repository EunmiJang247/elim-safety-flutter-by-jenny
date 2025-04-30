import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';
import '../../../project_checks/controllers/project_checks_controller.dart';

class ProjectChecksHeader extends GetView<ProjectChecksController> {
  const ProjectChecksHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      leftSide: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(left: 48),
              width: 200.w,
              child: Text(
                controller.appService.curProject!.value.name ?? "",
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              Get.back();
            },
            child: Container(
              margin: EdgeInsets.only(right: 44),
              height: appBarHeight,
              width: 44,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      rightSide: Row(
        children: [
          MaterialButton(
            onPressed: () {
              controller.goDrawingList();
            },
            color: AppColors.button,
            child: Text("도면 목록",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Pretendard",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
