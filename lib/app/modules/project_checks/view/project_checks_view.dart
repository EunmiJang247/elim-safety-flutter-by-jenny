import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/header.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/inspection_cate_dropdown.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/project_checks_info.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/project_checks_result_cards.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';

import '../../project_checks/controllers/project_checks_controller.dart';

class CheckList extends GetView<ProjectChecksController> {
  const CheckList({super.key});

  @override
  Widget build(BuildContext context) {
    print('현재 프로젝트: ${controller.curProject.value}');
    return Scaffold(
      backgroundColor: Colors.black,
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
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 16),
                              child: ProjectChecksInfo(
                                  inspectorName: controller.curProject.value
                                      ?.site_check_form?.inspectorName,
                                  inspectionDate: controller.curProject.value
                                      ?.site_check_form?.inspectionDate,
                                  inspectorNameController:
                                      controller.inspectorNameController,
                                  inspectorNameFocus:
                                      controller.inspectorNameFocus,
                                  onDateChange: controller.onDateChange),
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16, top: 4),
                              child: InspectionCateDropdown(
                                onChanged: controller.takePictureAndSet,
                              ),
                            ),
                          ),
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white, // 배경색 추가 (그림자 보이게)
                              border: Border(
                                bottom:
                                    BorderSide(color: Colors.black87, width: 1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 6,
                                  offset: Offset(0, 4), // 아래로만 그림자
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.grey[50], // 밝은 회색 배경
                              child: Obx(() => ListView.builder(
                                    padding: EdgeInsets.only(top: 16.h),
                                    itemCount: controller.curProject.value
                                            ?.site_check_form?.data.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 16.h,
                                          left: 16,
                                          right: 16,
                                        ),
                                        child: ProjectChecksResultCards(
                                            data: controller.curProject.value
                                                ?.site_check_form?.data[index],
                                            onFixingReasonClick:
                                                controller.onFixingReasonClick),
                                      );
                                    },
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              LeftMenuBar(),
            ],
          ),
        ),
      ),
    );
  }
}
