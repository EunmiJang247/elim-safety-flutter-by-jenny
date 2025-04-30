import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/modules/drawing_detail/views/drawing_view.dart';
import 'package:safety_check/app/modules/drawing_detail/views/fault_drawer.dart';
import 'package:safety_check/app/modules/drawing_detail/views/fault_table.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';
import 'package:safety_check/app/widgets/drag_indicator_widget.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';
import 'package:safety_check/app/widgets/two_button_dialog.dart';

import '../../../constant/constants.dart';
import '../../../constant/gaps.dart';
import '../controllers/drawing_detail_controller.dart';
import 'number_drawer.dart';

class DrawingDetailView extends GetView<DrawingDetailController> {
  const DrawingDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  FocusScope.of(context).unfocus();
                  controller.onTapBack();
                }
              },
              child: Stack(
                children: [
                  // 도면 또는 현황표 출력 영역
                  Container(
                      padding: EdgeInsets.only(
                          left: leftBarWidth, top: appBarHeight),
                      child: Obx(() => controller.isDrawingSelected.value
                          ? DrawingView()
                          : FaultTable(
                              tableData: controller.tableData,
                              onTapRow: controller.onTapRow,
                            ))),

                  Obx(() => Visibility(
                        visible: controller.isMovingNumOrFault.value,
                        child: TopDragIndicatorWidget(
                          message: "이동하세요",
                        ),
                      )),

                  // Visibility(
                  //   visible: !controller.isDrawingSelected.value,
                  //   child: Align(
                  //       alignment: Alignment.bottomRight,
                  //       child: Container(
                  //         padding: EdgeInsets.only(bottom: 16.0, right: 16.0),
                  //         child: InkWell(
                  //           onTap: () {
                  //             controller.addFault();
                  //           },
                  //           child: Container(
                  //             height: 50,
                  //             width: 50,
                  //             decoration: BoxDecoration(
                  //               color: AppColors.c4,
                  //               boxShadow: [
                  //                 BoxShadow(color: Colors.black.withOpacity(0.1), offset: Offset(0, 1), blurRadius: 2, spreadRadius: -1),
                  //                 BoxShadow(color: Colors.black.withOpacity(0.1), offset: Offset(0, 1), blurRadius: 3, spreadRadius: 0),
                  //                 BoxShadow(color: Colors.black.withOpacity(0.1), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -4),
                  //                 BoxShadow(color: Colors.black.withOpacity(0.1), offset: Offset(0, 10), blurRadius: 15, spreadRadius: -3),
                  //               ],
                  //               borderRadius: BorderRadius.circular(24),
                  //             ),
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: [
                  //                 Icon(CupertinoIcons.plus,
                  //                   color: Colors.white,
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //         ),
                  //       ),
                  // ),

                  // 속성창 닫는 검은 영역
                  Visibility(
                    visible: controller.appService.isFaultSelected.value ||
                        controller.isNumberSelected.value,
                    child: GestureDetector(
                      child: Container(
                        color: Colors.black38,
                      ),
                      onTap: () {
                        if (controller.isKeyboardVisible(context)) {
                          FocusScope.of(context).unfocus();
                        } else {
                          controller.closeFaultDrawer(context);
                          controller.closeNumberDrawer(context);
                        }
                      },
                    ),
                  ),

                  // 상단바
                  CustomAppBar(
                      leftSide: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.only(left: 48),
                              width: 200.w,
                              child: Text(
                                controller.projectName,
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
                              controller.onTapBack();
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
                          InkWell(
                              onTap: () {
                                // controller.memoView("1");
                                if (!controller.addMemoMode.value) {
                                  EasyLoading.showInfo("메모를 원하는 곳을 클릭하세요",
                                      duration: Duration(milliseconds: 500));
                                } else {
                                  EasyLoading.showInfo("메모 쓰기를 종료합니다",
                                      duration: Duration(milliseconds: 500));
                                }
                                controller.addMemoMode.value =
                                    !controller.addMemoMode.value;
                              },
                              child: Icon(
                                FontAwesomeIcons.penToSquare,
                                size: 24,
                                color: controller.addMemoMode.value
                                    ? Colors.red
                                    : Colors.black,
                              )),
                          Gaps.w24,
                          InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return TwoButtonDialog(
                                      height: 180,
                                      content: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "알림",
                                            style: TextStyle(
                                                fontFamily: "Pretendard",
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Gaps.h16,
                                          Text(
                                            "번호를 재정렬 하시겠습니까?",
                                            style: TextStyle(
                                              fontFamily: "Pretendard",
                                              fontSize: 18,
                                            ),
                                          ),
                                          Gaps.h4
                                        ],
                                      ),
                                      yes: "재정렬",
                                      no: "취소",
                                      onYes: () {
                                        controller.sortMarker();
                                        Get.back();
                                      },
                                      onNo: () => Get.back(),
                                    );
                                  },
                                );
                              },
                              child: Icon(
                                FontAwesomeIcons.arrowDownShortWide,
                                size: 24,
                              )),
                          Gaps.w24,
                          Text(
                            controller.imageDescription,
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Gaps.w20,
                          Transform.scale(
                            scale: 1.2,
                            child: CupertinoSwitch(
                              // activeTrackColor: AppColors.c4,
                              value: !controller.isDrawingSelected.value,
                              onChanged: (value) =>
                                  controller.isDrawingSelected.value = !value,
                            ),
                          ),
                        ],
                      )),

                  // 번호 속성창
                  Align(alignment: Alignment.topRight, child: NumberDrawer()),

                  // 결함 속성창
                  Align(alignment: Alignment.topRight, child: FaultDrawer()),

                  // 왼쪽바
                  LeftMenuBar()
                ],
              ),
            ),
          ),
        ));
  }
}
