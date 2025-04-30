import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/utils/formatter.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';
import 'package:safety_check/app/widgets/photo.dart';

import '../../../constant/app_color.dart';
import '../controllers/project_list_controller.dart';

class ProjectListView extends GetView<ProjectListController> {
  const ProjectListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              controller.appService.onPop(context);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
                child: Stack(
              children: [
                CustomAppBar(
                    leftSide: Row(
                      children: [
                        Container(
                          width: 228,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    offset: Offset(1, 1),
                                    blurRadius: 1,
                                    spreadRadius: 0)
                              ]),
                          margin: EdgeInsets.symmetric(vertical: 11),
                          padding: EdgeInsets.all(2),
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                  top: 1,
                                  left:
                                      controller.isMyPlace.value == 0 ? 1 : 111,
                                  duration: Duration(milliseconds: 100),
                                  child: Container(
                                    width: 112,
                                    height: 42,
                                    decoration: BoxDecoration(
                                        color: AppColors.c4,
                                        borderRadius:
                                            BorderRadius.circular(21)),
                                  )),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        controller.searchController.text = "";
                                        controller.changePlace(0);
                                        FocusScope.of(context).unfocus();
                                      },
                                      child: Center(
                                          child: Text("전체 현장",
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: controller.isMyPlace
                                                              .value ==
                                                          0
                                                      ? Colors.white
                                                      : AppColors.c1))),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        controller.searchController.text = "";
                                        controller.changePlace(1);
                                        FocusScope.of(context).unfocus();
                                      },
                                      child: Center(
                                          child: Text("나의 현장",
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: controller.isMyPlace
                                                              .value ==
                                                          1
                                                      ? Colors.white
                                                      : AppColors.c1))),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Gaps.w20,
                        Obx(() => Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Visibility(
                                  visible:
                                      controller.searchController.text != "",
                                  child: Row(
                                    children: [
                                      Text(
                                          "'${controller.searchController.text}'",
                                          style: TextStyle(
                                            fontFamily: "Pretendard",
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Text("에 대한 검색결과  ",
                                          style: TextStyle(
                                            fontFamily: "Pretendard",
                                            fontSize: 16,
                                          )),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text("총 ",
                                        style: TextStyle(
                                          fontFamily: "Pretendard",
                                          fontSize: 18,
                                        )),
                                    Text(
                                        "${controller.appService.projectList.length}",
                                        style: TextStyle(
                                            fontFamily: "Pretendard",
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Text("건",
                                        style: TextStyle(
                                          fontFamily: "Pretendard",
                                          fontSize: 18,
                                        )),
                                  ],
                                ),
                                Gaps.w12,
                                InkWell(
                                  onTap: () {
                                    controller.reloadProjects();
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: Icon(
                                    Icons.refresh,
                                    size: 24,
                                  ),
                                )
                              ],
                            ))
                      ],
                    ),
                    rightSide: Container(
                      width: 300,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.grey)
                          // boxShadow: [
                          //   BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(0, 0), blurRadius: 5, spreadRadius: -1),
                          // ]
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: controller.searchFocus,
                              controller: controller.searchController,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  isDense: true),
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontSize: 16,
                              ),
                              onSubmitted: (value) => controller.search(value),
                              cursorColor: Colors.black,
                              // onChanged: (value) => controller.search(value),
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                controller
                                    .search(controller.searchController.text);
                                FocusScope.of(context).unfocus();
                              },
                              child: Icon(Icons.search))
                        ],
                      ),
                    )),
                Container(
                    padding:
                        EdgeInsets.only(left: leftBarWidth, top: appBarHeight),
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(top: 8, left: 16, right: 8),
                      child: Column(
                        children: [
                          Expanded(
                            child: Scrollbar(
                              controller: controller.scrollController,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      controller.appService.projectList.length,
                                  itemBuilder: (context, index) {
                                    String dtInfo = "";
                                    String? fieldStDt = controller.appService
                                        .projectList[index].field_bgn_dt;
                                    String? fieldEndDt = controller.appService
                                        .projectList[index].field_end_dt;
                                    String? bgnDt =
                                        fieldStDt?.split("-").join(". ");
                                    List<String?> temp = [];
                                    if (controller.appService.projectList[index]
                                            .field_end_dt !=
                                        null) {
                                      temp = fieldEndDt!.split('-');
                                      temp.removeAt(0);
                                    }
                                    String? endDt = temp.join(". ");
                                    dtInfo = "$bgnDt ~ $endDt";

                                    List<String>? managers = controller
                                            .appService
                                            .projectList[index]
                                            .engineer_names
                                            ?.split(",") ??
                                        [];

                                    String? floorInfo = "";
                                    if (controller.appService.projectList[index]
                                                .ground_cnt ==
                                            null &&
                                        controller.appService.projectList[index]
                                                .underground_cnt ==
                                            null) {
                                      floorInfo = "층수 정보 없음";
                                    } else if (controller.appService
                                            .projectList[index].ground_cnt !=
                                        null) {
                                      String? upFloor = controller.appService
                                          .projectList[index].ground_cnt;
                                      floorInfo = "지상 $upFloor층";
                                      if (controller
                                              .appService
                                              .projectList[index]
                                              .underground_cnt !=
                                          null) {
                                        String? underFloor = controller
                                            .appService
                                            .projectList[index]
                                            .underground_cnt
                                            ?.replaceFirst("-", "");
                                        floorInfo += ", 지하 $underFloor층";
                                      }
                                    } else if (controller
                                            .appService
                                            .projectList[index]
                                            .underground_cnt !=
                                        null) {
                                      String? underFloor = controller.appService
                                          .projectList[index].underground_cnt
                                          ?.replaceFirst("-", "");
                                      floorInfo = "지하 $underFloor층";
                                    }
                                    return InkWell(
                                      onTap: () {
                                        controller.onTapProject(index);
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.black12))),
                                        // margin: EdgeInsets.symmetric(vertical: 12),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        child: Row(
                                          children: [
                                            Container(
                                                width: 200,
                                                height: 140,
                                                margin:
                                                    EdgeInsets.only(right: 20),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: controller
                                                                    .appService
                                                                    .projectList[
                                                                        index]
                                                                    .picture ==
                                                                null ||
                                                            controller
                                                                .appService
                                                                .projectList[
                                                                    index]
                                                                .picture!
                                                                .isEmpty
                                                        ? Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black12,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4)),
                                                            child: Center(
                                                              child: FaIcon(
                                                                FontAwesomeIcons
                                                                    .image,
                                                                size: 50,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.2),
                                                              ),
                                                            ),
                                                          )
                                                        : Photo(
                                                            imageUrl: controller
                                                                .appService
                                                                .projectList[
                                                                    index]
                                                                .picture,
                                                            width: 200,
                                                            height: 140,
                                                            boxFit:
                                                                BoxFit.cover,
                                                          ))),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(dtInfo,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "Pretendard",
                                                        fontSize: 15,
                                                      )),
                                                  Text(
                                                    controller
                                                            .appService
                                                            .projectList[index]
                                                            .name ??
                                                        "프로젝트명",
                                                    style: TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Gaps.h12,
                                                  Text(
                                                      controller
                                                              .appService
                                                              .projectList[
                                                                  index]
                                                              .place_name ??
                                                          "장소명 정보 없음",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "Pretendard",
                                                        fontSize: 16,
                                                      )),
                                                  Text(
                                                    controller
                                                            .appService
                                                            .projectList[index]
                                                            .addr ??
                                                        "주소 정보 없음",
                                                    style: TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontSize: 16,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        controller
                                                                .appService
                                                                .projectList[
                                                                    index]
                                                                .jong ??
                                                            "",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Pretendard",
                                                          fontSize: 16,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Visibility(
                                                        visible: controller
                                                                    .appService
                                                                    .projectList[
                                                                        index]
                                                                    .jong !=
                                                                null &&
                                                            (floorInfo != "" ||
                                                                controller
                                                                        .appService
                                                                        .projectList[
                                                                            index]
                                                                        .gross_area !=
                                                                    null),
                                                        child: Text(
                                                          "  |  ",
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        floorInfo,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Pretendard",
                                                          fontSize: 16,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        "  |  ",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        controller
                                                                    .appService
                                                                    .projectList[
                                                                        index]
                                                                    .gross_area ==
                                                                null
                                                            ? "연면적 정보 없음"
                                                            : "${formatNumberWithComma(controller.appService.projectList[index].gross_area!)} ㎡",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Pretendard",
                                                          fontSize: 16,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 120,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  // Row(
                                                  //   children: [
                                                  //     Text(controller.appService.projectList[index].field_bgn_dt!,
                                                  //         style: TextStyle(
                                                  //           fontFamily: "Pretendard",
                                                  //           fontSize: 16,
                                                  //         )
                                                  //     ),
                                                  //     Text(" - ",
                                                  //         style: TextStyle(
                                                  //           fontFamily: "Pretendard",
                                                  //           fontSize: 16,
                                                  //         )
                                                  //     ),
                                                  //     Text(controller.appService.projectList[index].field_end_dt!,
                                                  //         style: TextStyle(
                                                  //           fontFamily: "Pretendard",
                                                  //           fontSize: 16,
                                                  //         )
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                  SizedBox(
                                                    height: 24,
                                                    child: IntrinsicWidth(
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.people,
                                                            color: AppColors.c4,
                                                            size: 20,
                                                          ),
                                                          Gaps.w8,
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  managers.isNotEmpty
                                                                      ? managers
                                                                          .first
                                                                      : "담당 인원 없음",
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        "Pretendard",
                                                                    fontSize:
                                                                        16,
                                                                  )),
                                                              Visibility(
                                                                visible: managers
                                                                        .isNotEmpty &&
                                                                    managers.length >
                                                                        1,
                                                                child: Text(
                                                                    " 외 ${managers.length - 1}명",
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          "Pretendard",
                                                                      fontSize:
                                                                          16,
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                LeftMenuBar(),
              ],
            )),
          ),
        ));
  }
}
