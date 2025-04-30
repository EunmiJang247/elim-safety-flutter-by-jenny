import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';
import 'package:safety_check/app/widgets/selection_dialog/location_selection_dialog.dart';
import 'package:safety_check/app/widgets/photo.dart';

import '../../../constant/constants.dart';
import '../../../constant/gaps.dart';
import '../../../widgets/two_button_dialog.dart';
import '../controllers/check_image_controller.dart';

class CheckImageView extends GetView<CheckImageController> {
  const CheckImageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Obx(() => Stack(
                children: [
                  Container(
                    color: Colors.black,
                    padding:
                        EdgeInsets.only(left: leftBarWidth, top: appBarHeight),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: controller.isCompareMode.value
                              ? (MediaQuery.of(context).size.width -
                                      leftBarWidth) *
                                  0.5
                              : 0,
                          height: MediaQuery.of(context).size.height,
                          child: Stack(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: GestureDetector(
                                  onDoubleTap: () =>
                                      controller.onDoubleTap(false),
                                  child: InteractiveViewer(
                                      transformationController:
                                          controller.transformationController1,
                                      maxScale: 10,
                                      child: Photo(
                                        imageUrl:
                                            controller.compare?.file_path ?? "",
                                        boxFit: BoxFit.contain,
                                      )),
                                ),
                              ),
                              // Visibility(
                              //   visible: controller.isCompareMode.value,
                              //   child: Align(
                              //     alignment: Alignment.bottomRight,
                              //     child: Container(
                              //       padding: const EdgeInsets.all(4.0),
                              //       margin: EdgeInsets.all(12),
                              //       decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(4),
                              //         color: Colors.white.withOpacity(0.4)
                              //       ),
                              //       child: Text(controller.compare?.file_path??"?",
                              //       style: TextStyle(
                              //         fontFamily: "Pretendard",
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.bold
                              //       ),),
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.black12,
                          width: 0,
                        ),
                        Expanded(
                            child: SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: GestureDetector(
                                        onDoubleTap: () =>
                                            controller.onDoubleTap(true),
                                        child: InteractiveViewer(
                                            transformationController: controller
                                                .transformationController2,
                                            maxScale: 10,
                                            child: Photo(
                                              imageUrl: controller
                                                      .original?.file_path ??
                                                  "",
                                              boxFit: BoxFit.contain,
                                            )),
                                      ),
                                    ),
                                    // Align(
                                    //   alignment: Alignment.bottomRight,
                                    //   child: Container(
                                    //     padding: const EdgeInsets.all(4.0),
                                    //     margin: EdgeInsets.all(12),
                                    //     decoration: BoxDecoration(
                                    //         borderRadius: BorderRadius.circular(4),
                                    //         color: Colors.white.withOpacity(0.4)
                                    //     ),
                                    //     child: Text(controller.original?.file_path??"",
                                    //       style: TextStyle(
                                    //           fontFamily: "Pretendard",
                                    //           fontSize: 16,
                                    //           fontWeight: FontWeight.bold
                                    //       ),),
                                    //   ),
                                    // )
                                  ],
                                )))
                      ],
                    ),
                  ),
                  CustomAppBar(
                      leftSide: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.only(left: 48),
                              width: 700,
                              child: Text(
                                "${controller.projectName}${controller.original!.no != null && controller.original!.no!.isNotEmpty ? ' ( ${controller.original!.no} )' : ''}",
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
                          Visibility(
                            visible: controller.original?.kind == "결함" &&
                                controller.compare != null,
                            child: Row(
                              children: [
                                Text(
                                  "비교",
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Gaps.w12,
                                CupertinoSwitch(
                                  value: controller.isCompareMode.value,
                                  onChanged: (value) =>
                                      controller.onClickCompareSwitch(value),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                              visible: controller.original?.kind != "결함",
                              child: Gaps.w16),
                          Visibility(
                            visible: controller.original?.kind != "결함",
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return LocationSelectionDialog(
                                      picture: controller.original,
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 150,
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: AutoSizeText(
                                      controller.curLocation.value.isEmpty
                                          ? "부위"
                                          : controller.curLocation.value,
                                      style: TextStyle(
                                          color: controller
                                                  .curLocation.value.isEmpty
                                              ? Colors.black38
                                              : Colors.black,
                                          fontFamily: "Pretendard",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                    )),
                              ),
                            ),
                          ),
                          Visibility(
                              visible: controller.original?.kind != "결함",
                              child: Gaps.w16),
                          Visibility(
                            visible: controller.original?.kind != "결함",
                            child: Container(
                              width: 80,
                              height: 40,
                              padding: EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: DropdownButton(
                                  value: controller.curKind.value,
                                  selectedItemBuilder: (context) =>
                                      List.generate(
                                    controller.kind.length,
                                    (index) {
                                      return DropdownMenuItem(
                                        value: controller.kind[index],
                                        child: Text(
                                          controller.kind[index],
                                        ),
                                      );
                                    },
                                  ),
                                  items: List.generate(
                                    controller.kind.length,
                                    (index) {
                                      return DropdownMenuItem(
                                        value: controller.kind[index],
                                        child: Text(
                                          controller.kind[index],
                                          style: TextStyle(
                                              color: controller.curKind.value ==
                                                      controller.kind[index]
                                                  ? Colors.redAccent
                                                  : Colors.black),
                                        ),
                                      );
                                    },
                                  ),
                                  onChanged: (value) {
                                    controller.changeKind(value!);
                                  },
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "Pretendard",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                  dropdownColor: Colors.white,
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(8),
                                  underline: Container(),
                                  icon: Icon(Icons.keyboard_arrow_down_rounded),
                                  isDense: true,
                                  isExpanded: true,
                                  menuWidth: 80,
                                ),
                              ),
                            ),
                          ),
                          Gaps.w10,
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return TwoButtonDialog(
                                    height: 200,
                                    content: Column(
                                      children: [
                                        Text(
                                          "사진 삭제",
                                          style: TextStyle(
                                              fontFamily: "Pretendard",
                                              color: AppColors.c1,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22),
                                        ),
                                        Gaps.h16,
                                        Text(
                                          "사진을 삭제하시겠습니까?\n삭제하면 복구 할 수 없습니다.",
                                          style: TextStyle(
                                            fontFamily: "Pretendard",
                                            fontSize: 18,
                                          ),
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                    yes: "삭제",
                                    no: "취소",
                                    onYes: () {
                                      Get.back();
                                      controller.deletePicture();
                                    },
                                    onNo: () {
                                      Get.back();
                                    },
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: SizedBox(
                                width: 32,
                                height: appBarHeight,
                                child: Icon(
                                  Icons.delete,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  LeftMenuBar()
                ],
              ))),
    );
  }
}
