import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';
import 'package:safety_check/app/widgets/photo.dart';

import '../../../constant/constants.dart';
import '../controllers/drawing_list_controller.dart';

class DrawingListView extends GetView<DrawingListController> {
  const DrawingListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              controller.goProjectInfo();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  CustomAppBar(
                      leftSide: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.only(left: 48),
                              width: 200.w,
                              child: Text(
                                controller.curProject?.name ?? "",
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
                              controller.goProjectInfo();
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
                      rightSide: Obx(() => Row(
                            children: [
                              Container(
                                width: 110,
                                height: 40,
                                padding: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: DropdownButton(
                                    value: controller.curDate.value,
                                    selectedItemBuilder: (context) {
                                      return List.generate(
                                        controller.dates.length,
                                        (index) => DropdownMenuItem(
                                          value: controller.dates[index] ?? "",
                                          child: Text(
                                            controller.parseDate(
                                                    controller.dates[index]) ??
                                                "",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      );
                                    },
                                    items: List.generate(
                                      controller.dates.length,
                                      (index) => DropdownMenuItem(
                                        value: controller.dates[index] ?? "",
                                        child: Text(
                                          controller.parseDate(
                                                  controller.dates[index]) ??
                                              "",
                                          style: TextStyle(
                                              color: controller.curDate.value ==
                                                      controller.dates[index]
                                                  ? Colors.redAccent
                                                  : Colors.black),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      controller.changeDate(value);
                                    },
                                    style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                                    dropdownColor: Colors.white,
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(8),
                                    underline: Container(),
                                    icon:
                                        Icon(Icons.keyboard_arrow_down_rounded),
                                    isDense: true,
                                    isExpanded: true,
                                    menuWidth: 110,
                                  ),
                                ),
                              ),
                              Gaps.w16,
                              Container(
                                width: 100,
                                height: 40,
                                padding: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: DropdownButton(
                                    value: controller.curDong.value,
                                    selectedItemBuilder: (context) {
                                      return List.generate(
                                        controller.dong.length,
                                        (index) => DropdownMenuItem(
                                          value:
                                              controller.dong[index] == "전체 동"
                                                  ? ""
                                                  : controller.dong[index],
                                          child: Text(
                                            controller.dong[index],
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      );
                                    },
                                    items: List.generate(
                                      controller.dong.length,
                                      (index) => DropdownMenuItem(
                                        value: controller.dong[index] == "전체 동"
                                            ? ""
                                            : controller.dong[index],
                                        child: Text(
                                          controller.dong[index],
                                          style: TextStyle(
                                              color: controller.curDong.value ==
                                                      controller.dong[index]
                                                  ? Colors.redAccent
                                                  : Colors.black),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      controller.curDong.value =
                                          value.toString();
                                      controller.filterDrawing();
                                    },
                                    style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    dropdownColor: Colors.white,
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(8),
                                    underline: Container(),
                                    icon:
                                        Icon(Icons.keyboard_arrow_down_rounded),
                                    isDense: true,
                                    isExpanded: true,
                                    menuWidth: 100,
                                  ),
                                ),
                              ),
                              Gaps.w16,
                              Container(
                                width: 100,
                                height: 40,
                                padding: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: DropdownButton(
                                    value: controller.curLevel.value,
                                    selectedItemBuilder: (context) {
                                      return List.generate(
                                        controller.floor.length,
                                        (index) => DropdownMenuItem(
                                          value:
                                              controller.floor[index] == "전체 층"
                                                  ? ""
                                                  : controller.floor[index],
                                          child: Text(
                                            controller.floor[index],
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      );
                                    },
                                    items: List.generate(
                                      controller.floor.length,
                                      (index) => DropdownMenuItem(
                                        value: controller.floor[index] == "전체 층"
                                            ? ""
                                            : controller.floor[index],
                                        child: Text(
                                          controller.floor[index],
                                          style: TextStyle(
                                              color: controller
                                                          .curLevel.value ==
                                                      controller.floor[index]
                                                  ? Colors.redAccent
                                                  : Colors.black),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      controller.curLevel.value =
                                          value.toString();
                                      controller.filterDrawing();
                                    },
                                    style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                                    dropdownColor: Colors.white,
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(8),
                                    underline: Container(),
                                    icon:
                                        Icon(Icons.keyboard_arrow_down_rounded),
                                    isDense: true,
                                    isExpanded: true,
                                    menuWidth: 100,
                                  ),
                                ),
                              ),
                            ],
                          ))),
                  Container(
                      padding: EdgeInsets.only(
                          left: leftBarWidth, top: appBarHeight),
                      child: Container(
                        color: Color(0xff646D78),
                        padding: EdgeInsets.only(top: 12, left: 24, right: 8),
                        child: Column(
                          children: [
                            Obx(() => Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Visibility(
                                          visible:
                                              controller.curDong.value != "",
                                          child: Text(controller.curDong.value,
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        Visibility(
                                          visible: controller.curDong.value !=
                                                  "" &&
                                              controller.curLevel.value != "",
                                          child: Text(", ",
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        Visibility(
                                          visible:
                                              controller.curLevel.value != "",
                                          child: Text(controller.curLevel.value,
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        Visibility(
                                          visible: controller.curDong.value !=
                                                  "" ||
                                              controller.curLevel.value != "",
                                          child: Text("에 대한 검색결과  ",
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 16,
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Text("총 ",
                                    //         style: TextStyle(
                                    //           fontFamily: "Pretendard",
                                    //           fontSize: 16,
                                    //           color: Colors.white
                                    //         )
                                    //     ),
                                    //     Text("${controller.drawingList.value.length}",
                                    //         style: TextStyle(
                                    //             fontFamily: "Pretendard",
                                    //             fontSize: 16,
                                    //             fontWeight: FontWeight.bold,
                                    //             color: Colors.white
                                    //         )
                                    //     ),
                                    //     Text("건",
                                    //         style: TextStyle(
                                    //           fontFamily: "Pretendard",
                                    //           fontSize: 16,
                                    //             color: Colors.white
                                    //         )
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                )),
                            Expanded(
                              child: Scrollbar(
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, right: 16.0),
                                    child: controller.isLoaded &&
                                            controller.searchList.isEmpty
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.folder_open_outlined,
                                                color: Colors.white,
                                                size: 130,
                                              ),
                                              Text(
                                                "관리시스템에서 도면파일을 업로드하세요",
                                                style: TextStyle(
                                                    fontFamily: "Pretendard",
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          )
                                        : GridView.builder(
                                            padding: EdgeInsets.zero,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        3, // 그리드의 열 개수
                                                    crossAxisSpacing: 22,
                                                    mainAxisExtent: 233),
                                            itemCount:
                                                controller.searchList.length,
                                            itemBuilder: (context, index) {
                                              String dong = controller
                                                      .searchList[index].dong ??
                                                  "이름없음";
                                              if (dong == "이름없음") {
                                                dong = "";
                                              }
                                              String floor = controller
                                                      .searchList[index]
                                                      .floor_name ??
                                                  controller
                                                      .searchList[index].name ??
                                                  "";
                                              var imageDescription =
                                                  "$dong $floor";
                                              if (imageDescription == " ") {
                                                imageDescription = "층이름 없음";
                                              }
                                              return GestureDetector(
                                                onTap: () =>
                                                    controller.selectDrawing(
                                                        controller
                                                            .searchList[index],
                                                        imageDescription),
                                                onLongPress: () =>
                                                    controller.showInfoDialog(
                                                        context,
                                                        controller
                                                            .searchList[index],
                                                        imageDescription),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 185,
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.1),
                                                                offset: Offset(
                                                                    0, 4),
                                                                blurRadius: 6,
                                                                spreadRadius:
                                                                    -4),
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.1),
                                                                offset: Offset(
                                                                    0, 10),
                                                                blurRadius: 15,
                                                                spreadRadius:
                                                                    -3),
                                                            // BoxShadow(color: Colors.black, offset: Offset(0, 0), blurRadius: 0, spreadRadius: 0),
                                                            // BoxShadow(color: Colors.black, offset: Offset(0, 0), blurRadius: 0, spreadRadius: 0),
                                                          ]),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: Photo(
                                                          width: 300,
                                                          boxFit: BoxFit.cover,
                                                          imageUrl: controller
                                                                  .searchList[
                                                                      index]
                                                                  .thumb ??
                                                              "",
                                                          // icon: Icons.image,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                          imageDescription,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Pretendard",
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white)),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          )),
                              ),
                            ),
                          ],
                        ),
                      )),
                  LeftMenuBar(),
                ],
              ),
            ),
          ),
        ));
  }
}
