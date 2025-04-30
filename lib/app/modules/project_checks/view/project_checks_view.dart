import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/data/models/01_project.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/inspection_cate_dropdown.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/project_checks_info.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/project_checks_result_cards.dart';
import 'package:safety_check/app/widgets/project_detail_layout.dart';

import '../../project_checks/controllers/project_checks_controller.dart';

class CheckList extends StatefulWidget {
  const CheckList({super.key});
  @override
  State<CheckList> createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {
  final ProjectChecksController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    Project? curProject = controller.appService.curProject?.value;
    return ProjectDetailLayout(
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: Colors.white,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProjectChecksInfo(
                      inspectorName: curProject?.site_check_form?.inspectorName,
                      inspectionDate:
                          curProject?.site_check_form?.inspectionDate,
                      inspectorNameController:
                          controller.inspectorNameController,
                      inspectorNameFocus: controller.inspectorNameFocus,
                      onDateChange: controller.onDateChange),
                  SizedBox(
                    height: 10,
                  ),
                  InspectionCateDropdown(
                    onChanged: controller.takePictureAndSet,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white, // 배경색 추가 (그림자 보이게)
                      border: Border(
                        bottom: BorderSide(
                            color: const Color.fromARGB(31, 77, 77, 77),
                            width: 1),
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
                    child: Obx(() => ListView.builder(
                          padding: EdgeInsets.only(top: 16.h),
                          itemCount: controller.curProject.value
                                  ?.site_check_form?.data.length ??
                              0,
                          itemBuilder: (context, index) {
                            final item = controller
                                .curProject.value?.site_check_form?.data[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: ProjectChecksResultCards(data: item),
                            );
                          },
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
