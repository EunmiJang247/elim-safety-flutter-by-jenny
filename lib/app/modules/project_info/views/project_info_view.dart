import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/modules/drawing_detail/views/fault_table.dart';
import 'package:safety_check/app/modules/project_info/views/info_table_row.dart';
import 'package:safety_check/app/utils/formatter.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';
import 'package:safety_check/app/widgets/photo.dart';

import '../../../constant/constants.dart';
import '../controllers/project_info_controller.dart';

class ProjectInfoView extends GetView<ProjectInfoController> {
  const ProjectInfoView({super.key});
  @override
  Widget build(BuildContext context) {
    double infoFontSize = 16;

    // // 포커스 리스너 설정
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!controller.requirementFocus.hasListeners) {

    //   }
    // });

    // dtInfo 계산 로직
    RxString dtInfo = "".obs;
    String? fieldStDt = controller.appService.curProject!.value.field_bgn_dt;
    String? fieldEndDt = controller.appService.curProject!.value.field_end_dt;
    String? bgnDt = fieldStDt?.split("-").join(". ");
    List<String?> temp = [];
    if (controller.appService.curProject!.value.field_end_dt != null) {
      temp = fieldEndDt!.split('-');
      temp.removeAt(0);
    }
    String? endDt = temp.join(". ");
    dtInfo.value = "$bgnDt ~ $endDt";

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.goHome();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
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
                          controller.goHome();
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
                      if (dotenv.env['ENVIRONMENT'] == "development")
                        MaterialButton(
                          onPressed: () {
                            controller.requirementFocus.unfocus();
                            controller.goCheckList();
                          },
                          color: Colors.grey,
                          child: Text("현장점검표",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Pretendard",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      Gaps.w32,
                      MaterialButton(
                        onPressed: () {
                          controller.requirementFocus.unfocus();
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
                      Gaps.w32,
                      Transform.scale(
                        scale: 1.2,
                        child: Obx(
                          () => CupertinoSwitch(
                            // activeTrackColor: AppColors.c4,
                            value: controller.isFaultListAll.value,
                            onChanged: (value) => controller.isFaultListAll
                                .value = !controller.isFaultListAll.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: leftBarWidth, top: appBarHeight),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          // isFaultListAll 에 따라 UI를 변경하는 부분만 Obx로 감싸기
                          child: Obx(
                            () => controller.isFaultListAll.value
                                ? FaultTable(
                                    tableData: controller.tableData,
                                    onTapRow: controller.onTapRow,
                                  ) // Show FaultTable when isDrawingSelected is true
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 왼쪽 - 프로젝트 이미지
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.all(26.r),
                                          child: controller
                                                      .appService
                                                      .curProject!
                                                      .value
                                                      .picture !=
                                                  ""
                                              ? SizedBox(
                                                  height: double.infinity,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.r),
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (controller
                                                            .requirementFocused
                                                            .value) {
                                                          controller
                                                              .requirementFocus
                                                              .unfocus();
                                                        } else {
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          controller
                                                              .showImage();
                                                        }
                                                      },
                                                      child: Photo(
                                                        imageUrl: controller
                                                            .appService
                                                            .curProject!
                                                            .value
                                                            .picture,
                                                        boxFit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.r),
                                                  child: InkWell(
                                                    onTap: () => controller
                                                        .takeProjectPicture(),
                                                    child: Container(
                                                      color: Colors.grey[300],
                                                      height: double.infinity,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons
                                                              .camera_alt_outlined,
                                                          size: 100,
                                                          color:
                                                              Colors.grey[400],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),

                                      // 오른쪽 - 프로젝트 정보
                                      Expanded(
                                        flex: 3,
                                        child: CupertinoScrollbar(
                                          controller:
                                              controller.scrollController,
                                          child: SingleChildScrollView(
                                            controller:
                                                controller.scrollController,
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                left: 5.w,
                                                right: 15.w,
                                                top: 25.h,
                                                bottom: 20.h,
                                              ),
                                              child: Column(
                                                children: [
                                                  // InfoTable(
                                                  //   fontSize: infoFontSize,
                                                  //   label: "시설물종류",
                                                  //   value: controller.curProject
                                                  //           ?.facility_remark ??
                                                  //       "",
                                                  // ),
                                                  // InfoTable(
                                                  //   fontSize: infoFontSize,
                                                  //   label: "시설물구분",
                                                  //   value: controller.curProject
                                                  //           ?.facility_name ??
                                                  //       "",
                                                  //   secondLabel: "연면적",
                                                  //   secondValue: controller
                                                  //               .curProject
                                                  //               ?.gross_area ==
                                                  //           null
                                                  //       ? "정보 없음"
                                                  //       : "${formatNumberWithComma(controller.curProject!.gross_area!)} ㎡",
                                                  // ),
                                                  InfoTable(
                                                    fontSize: infoFontSize,
                                                    label: "종별",
                                                    value: controller
                                                            .appService
                                                            .curProject!
                                                            .value
                                                            .jong ??
                                                        "",
                                                    secondLabel: "준공일",
                                                    secondValue: controller
                                                            .appService
                                                            .curProject!
                                                            .value
                                                            .completion_dt ??
                                                        "",
                                                  ),
                                                  InfoTable(
                                                    fontSize: infoFontSize,
                                                    label: "관리주체명",
                                                    value: controller
                                                            .appService
                                                            .curProject!
                                                            .value
                                                            .manager_name ??
                                                        "",
                                                  ),
                                                  InfoTable(
                                                    fontSize: infoFontSize,
                                                    label: "전화번호",
                                                    value: formatTel(controller
                                                            .appService
                                                            .curProject!
                                                            .value
                                                            .tel ??
                                                        ""),
                                                  ),
                                                  InfoTable(
                                                    fontSize: infoFontSize,
                                                    label: "담당자명",
                                                    value: controller
                                                            .appService
                                                            .curProject!
                                                            .value
                                                            .pic_name ??
                                                        "",
                                                  ),
                                                  InfoTable(
                                                    fontSize: infoFontSize,
                                                    label: "연락처",
                                                    value: controller
                                                            .appService
                                                            .curProject!
                                                            .value
                                                            .pic_tel ??
                                                        "",
                                                  ),
                                                  // InfoTable(
                                                  //   fontSize: infoFontSize,
                                                  //   label: "건축물대장",
                                                  //   value: UrlLinkTo(controller
                                                  //           .curProject
                                                  //           ?.attachment1 ??
                                                  //       ""),
                                                  //   secondLabel: "시설물대장",
                                                  //   secondValue: UrlLinkTo(
                                                  //       controller.curProject
                                                  //               ?.attachment2 ??
                                                  //           ""),
                                                  // ),
                                                  Gaps.h16,
                                                  Container(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          alignment: Alignment
                                                              .centerLeft, // Left align the content
                                                          child: Text('요청사항',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      infoFontSize,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      8.h),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.r),
                                                          ),
                                                          child: TextField(
                                                            focusNode: controller
                                                                .requirementFocus,
                                                            controller: controller
                                                                .requirementTextController,
                                                            maxLines: null,
                                                            minLines: 3,
                                                            // textInputAction:
                                                            //     TextInputAction
                                                            //         .done,

                                                            decoration:
                                                                InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(12),
                                                              hintText:
                                                                  "요청사항을 입력하세요",
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                            ),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    infoFontSize),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
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
      ),
    );
  }
}
