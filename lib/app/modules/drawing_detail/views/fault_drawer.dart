import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';
import 'package:safety_check/app/modules/drawing_detail/controllers/drawing_detail_controller.dart';
import 'package:safety_check/app/utils/formatter.dart';
import 'package:safety_check/app/widgets/selection_dialog/cause_selection_dialog.dart';
import 'package:safety_check/app/widgets/fault_field.dart';
import 'package:safety_check/app/widgets/selection_dialog/location_selection_dialog.dart';
import 'package:safety_check/app/widgets/number_input_dialog.dart';
import 'package:safety_check/app/widgets/number_input_dialog2.dart';
import 'package:safety_check/app/widgets/photo.dart';
import 'package:safety_check/app/widgets/selection_dialog/status_selection_dialog.dart';
import 'package:safety_check/app/widgets/two_button_dialog.dart';
import 'package:safety_check/app/widgets/selection_dialog/type_selection_dialog.dart';

import '../../../constant/app_color.dart';
import '../../../constant/constants.dart';
import '../../../data/models/03_marker.dart';
import '../../../data/models/04_fault.dart';
import '../../../data/models/05_picture.dart';
import '../../../widgets/custom_color_picker.dart';
import '../../../widgets/selection_dialog/element_selection_dialog.dart';

// TODO Jenny 뒤로가기 작업 시작

class FaultDrawer extends StatefulWidget {
  const FaultDrawer({super.key});

  @override
  State<FaultDrawer> createState() => _FaultDrawerState();
}

class _FaultDrawerState extends State<FaultDrawer> {
  AppService appService = Get.find();
  LocalGalleryDataService localGalleryDataService = Get.find();
  DrawingDetailController drawingDetailController = Get.find();
  final CarouselSliderController carouselController =
      CarouselSliderController();
  FocusNode focusNode = FocusNode();
  List<GlobalKey> globalKeys = List.generate(
    4,
    (index) => GlobalKey(),
  );
  TextEditingController noteController = TextEditingController();
  late Fault curFaultData;
  bool isStructure = false;
  bool isProcessing = false;
  bool isRepairDone = false;

  List<CustomPicture>? images = [];
  int carouselIndex = 0;

  updateConditions() {
    isStructure = curFaultData.structure == "구조";
    isProcessing = curFaultData.status == "Y";
    noteController.text = curFaultData.note ?? "";
    images =
        drawingDetailController.loadGallery(curFaultData.fid ?? "-1") ?? [];
  }

  @override
  void initState() {
    curFaultData = appService.selectedFault.value.copyWith();
    updateConditions();

    noteController.addListener(
        () => appService.selectedFault.value.note = noteController.text);
    // print(noteController.text);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!appService.selectedFault.value
          .isSame(curFaultData, isEditingFault: true)) {
        drawingDetailController.editFault(appService.selectedFault.value);
        curFaultData = appService.selectedFault.value.copyWith();
        updateConditions();
      }
      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            focusNode.unfocus();
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                  visible: appService.isFaultSelected.value &&
                      drawingDetailController.clrPickerOpened.value,
                  child: CustomColorPicker()),
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeIn,
                decoration: BoxDecoration(
                  color: Color(0xffD9D9D9),
                  // border: Border(left: BorderSide(color: Colors.black, width: 1))
                ),
                margin: EdgeInsets.only(top: appBarHeight),
                width: appService.isFaultSelected.value ? 136.w : 0,
                height: MediaQuery.of(context).size.height - appBarHeight,
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      color: AppColors.c4,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 136.w - 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () async {
                                  drawingDetailController
                                      .closeFaultDrawer(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 10.0),
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  CustomPicture? newImage =
                                      await drawingDetailController.takePicture(
                                          appService.selectedFault.value);
                                  if (newImage != null) {
                                    setState(() {
                                      appService
                                          .selectedFault.value.picture_list
                                          ?.add(newImage);

                                      images = drawingDetailController
                                          .loadGallery(curFaultData.fid!);
                                      carouselController.animateToPage(0);
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 10.0),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  List<CustomPicture>? newPictures;
                                  newPictures = await drawingDetailController
                                      .takeFromGallery(
                                          appService.selectedFault.value);
                                  if (newPictures != null) {
                                    setState(() {
                                      appService
                                          .selectedFault.value.picture_list
                                          ?.addAll(newPictures!);
                                      images = localGalleryDataService
                                          .loadGallery(curFaultData.fid!);
                                      carouselController.animateToPage(0);
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 10.0),
                                  child: Icon(
                                    Icons.photo_library,
                                    color: Colors.white,
                                    size: 23,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: drawingDetailController.selectedMarker
                                            .value.live_tour_url !=
                                        null &&
                                    drawingDetailController.selectedMarker.value
                                        .live_tour_url!.isNotEmpty,
                                child: InkWell(
                                    onTap: () {
                                      drawingDetailController.openUrl(
                                          context,
                                          drawingDetailController.selectedMarker
                                              .value.live_tour_url);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 10.0),
                                      child: Center(
                                          child: Text(
                                        "3D",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      )),
                                    )),
                              ),
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
                                              "결함 복제",
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  color: AppColors.c1,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22),
                                            ),
                                            Gaps.h16,
                                            Text(
                                              "동일한 위치에 동일한 내용으로\n결함을 복제하시겠습니까?",
                                              style: TextStyle(
                                                fontFamily: "Pretendard",
                                                fontSize: 18,
                                              ),
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                        ),
                                        yes: "복제",
                                        no: "취소",
                                        onYes: () {
                                          Get.back();
                                          drawingDetailController.cloneFault();
                                          focusNode.unfocus();
                                        },
                                        onNo: () {
                                          Get.back();
                                          focusNode.unfocus();
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 10.0),
                                  child: Icon(
                                    Icons.copy,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => drawingDetailController
                                    .onClrBtnClicked(true, true),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 10.0),
                                  decoration: BoxDecoration(
                                      color: AppColors.c4,
                                      border: Border.all(
                                        color: drawingDetailController
                                                .markerList.isEmpty
                                            ? Colors.red
                                            : Color(
                                                int.parse(
                                                  "0xFF${drawingDetailController.markerList.firstWhere(
                                                        (element) =>
                                                            element.no ==
                                                            drawingDetailController
                                                                .selectedMarker
                                                                .value
                                                                .no,
                                                        orElse: () => Marker(
                                                            outline_color:
                                                                "ff0000"), // 기본값 제공
                                                      ).outline_color ?? "ff0000"}",
                                                ),
                                              ),
                                      ),
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              InkWell(
                                onTap: () => drawingDetailController
                                    .onClrBtnClicked(false, false),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 10.0),
                                  decoration: BoxDecoration(
                                      color: Color(int.parse(
                                          "0xFF${appService.selectedFault.value.color ?? "ff0000"}")),
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
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
                                              "내용 초기화",
                                              style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  color: AppColors.c1,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22),
                                            ),
                                            Gaps.h16,
                                            Text(
                                              "결함을 내용을 초기화하시겠습니까?\n초기화하면 복구 할 수 없습니다.",
                                              style: TextStyle(
                                                fontFamily: "Pretendard",
                                                fontSize: 18,
                                              ),
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                        ),
                                        yes: "초기화",
                                        no: "취소",
                                        onYes: () {
                                          Get.back();
                                          drawingDetailController.clearFault();
                                          focusNode.unfocus();
                                        },
                                        onNo: () {
                                          Get.back();
                                          focusNode.unfocus();
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 10.0),
                                  child: FaIcon(
                                    FontAwesomeIcons.eraser,
                                    color: Colors.white,
                                    size: 23,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => showDialog(
                                    context: context,
                                    builder: (context) => TwoButtonDialog(
                                          height: 200,
                                          content: Column(
                                            children: [
                                              Text(
                                                "결함 삭제",
                                                style: TextStyle(
                                                    fontFamily: "Pretendard",
                                                    color: AppColors.c1,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22),
                                              ),
                                              Gaps.h16,
                                              Text(
                                                "'${appService.selectedFault.value.marker_no}' 결함을 삭제하시겠습니까?\n삭제하면 복구 할 수 없습니다.",
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
                                            drawingDetailController.delFault();
                                          },
                                          onNo: () => Get.back(),
                                        )),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14.0, horizontal: 10.0),
                                  child: Icon(
                                    FontAwesomeIcons.trashCan,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    drawingDetailController
                                        .closeFaultDrawer(context);
                                    drawingDetailController
                                        .closeNumberDrawer(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 10.0),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: CupertinoScrollbar(
                      controller: drawingDetailController.cScrollController,
                      child: KeyboardVisibilityBuilder(
                          builder: (context, isKeyboardVisible) {
                        return SingleChildScrollView(
                          reverse: isKeyboardVisible,
                          controller: drawingDetailController.cScrollController,
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                                bottom: 16 +
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 130.h,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: Stack(
                                          children: [
                                            (images != null && images!.isEmpty)
                                                ? InkWell(
                                                    onTap: () async {
                                                      CustomPicture? newImage =
                                                          await drawingDetailController
                                                              .takePicture(
                                                                  appService
                                                                      .selectedFault
                                                                      .value);
                                                      if (newImage != null) {
                                                        setState(() {
                                                          appService
                                                              .selectedFault
                                                              .value
                                                              .picture_list
                                                              ?.add(newImage);
                                                          images =
                                                              localGalleryDataService
                                                                  .loadGallery(
                                                                      curFaultData
                                                                          .fid!);
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.black12,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4)),
                                                      child: Center(
                                                        child: FaIcon(
                                                          FontAwesomeIcons
                                                              .image,
                                                          size: 50,
                                                          color: Colors.black
                                                              .withOpacity(0.2),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                        minHeight: 130.h),
                                                    child: CarouselSlider(
                                                      carouselController:
                                                          carouselController,
                                                      items: images?.map(
                                                        (e) {
                                                          return InkWell(
                                                            onTap: () {
                                                              drawingDetailController
                                                                  .checkImage(
                                                                      e);
                                                            },
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              child: Photo(
                                                                imageUrl:
                                                                    e.file_path,
                                                                boxFit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                      options: CarouselOptions(
                                                          initialPage:
                                                              carouselIndex,
                                                          onPageChanged:
                                                              (index, reason) {
                                                            setState(() {
                                                              carouselIndex =
                                                                  index; // 현재 페이지 인덱스 저장
                                                            });
                                                          },
                                                          enableInfiniteScroll:
                                                              false,
                                                          viewportFraction: 1),
                                                    ),
                                                  ),
                                            Visibility(
                                              visible: (images != null &&
                                                      images!.length > 1) &&
                                                  carouselIndex > 0,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: InkWell(
                                                  onTap: () {
                                                    carouselController
                                                        .previousPage(
                                                            duration: Duration(
                                                                milliseconds:
                                                                    100),
                                                            curve:
                                                                Curves.easeIn);
                                                  },
                                                  child: SizedBox(
                                                    height: double.infinity,
                                                    width: 24,
                                                    child: Icon(
                                                      Icons
                                                          .keyboard_arrow_left_sharp,
                                                      color: Colors.white,
                                                      shadows: [
                                                        BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.25),
                                                            offset:
                                                                Offset(0, 4),
                                                            blurRadius: 4)
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: images != null &&
                                                  images!.length > 1 &&
                                                  carouselIndex <
                                                      images!.length - 1,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: InkWell(
                                                  onTap: () {
                                                    carouselController.nextPage(
                                                        duration: Duration(
                                                            milliseconds: 100),
                                                        curve: Curves.easeIn);
                                                  },
                                                  child: SizedBox(
                                                    height: double.infinity,
                                                    width: 24,
                                                    child: Icon(
                                                      Icons
                                                          .keyboard_arrow_right_sharp,
                                                      color: Colors.white,
                                                      shadows: [
                                                        BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.25),
                                                            offset:
                                                                Offset(0, 4),
                                                            blurRadius: 4)
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Gaps.w16,
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return LocationSelectionDialog(
                                                      fault: appService
                                                          .selectedFault.value,
                                                    );
                                                  },
                                                );
                                                // FocusScope.of(context).requestFocus(focusNodes[2]);
                                              },
                                              child: faultField(
                                                  null,
                                                  Text(
                                                    appService.selectedFault.value
                                                                    .location !=
                                                                null &&
                                                            appService
                                                                    .selectedFault
                                                                    .value
                                                                    .location !=
                                                                ""
                                                        ? appService
                                                            .selectedFault
                                                            .value
                                                            .location!
                                                        : "부위",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: appService
                                                                        .selectedFault
                                                                        .value
                                                                        .location !=
                                                                    null &&
                                                                appService
                                                                        .selectedFault
                                                                        .value
                                                                        .location !=
                                                                    ""
                                                            ? Colors.black
                                                            : Colors.black38),
                                                  ),
                                                  needPadding: true),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return ElementSelectionDialog(
                                                      fault: appService
                                                          .selectedFault.value,
                                                    );
                                                  },
                                                );
                                                // FocusScope.of(context).requestFocus(focusNodes[2]);
                                              },
                                              child: faultField(
                                                  null,
                                                  Text(
                                                    appService.selectedFault.value
                                                                    .elem !=
                                                                null &&
                                                            appService
                                                                    .selectedFault
                                                                    .value
                                                                    .elem !=
                                                                ""
                                                        ? appService
                                                            .selectedFault
                                                            .value
                                                            .elem!
                                                        : "부재",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: appService
                                                                        .selectedFault
                                                                        .value
                                                                        .elem !=
                                                                    null &&
                                                                appService
                                                                        .selectedFault
                                                                        .value
                                                                        .elem !=
                                                                    ""
                                                            ? Colors.black
                                                            : Colors.black38),
                                                  ),
                                                  needPadding: true),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Gaps.h20,
                                faultField(
                                    null,
                                    height: null,
                                    InkWell(
                                      onTap: () {
                                        focusNode.unfocus();
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                TypeSelectionDialog());
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Obx(() {
                                                final cateString =
                                                    makeCateString(appService
                                                        .selectedFault.value);
                                                final isEmpty =
                                                    cateString == "";
                                                return Text(
                                                  isEmpty
                                                      ? "유형 및 형상"
                                                      : cateString,
                                                  style: TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      color: isEmpty
                                                          ? Colors.black38
                                                          : Colors.black),
                                                );
                                              }),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: Colors.black45,
                                              size: 18,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    needPadding: false),
                                Gaps.h18,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                NumberInputDialog(
                                              attribute: "폭",
                                            ),
                                          );
                                          // FocusScope.of(context).requestFocus(focusNodes[0]);
                                        },
                                        child: faultField(
                                            "폭 (mm)",
                                            Text(
                                              appService.selectedFault.value
                                                      .width ??
                                                  "",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            needPadding: true),
                                      ),
                                    ),
                                    Gaps.w16,
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                NumberInputDialog(
                                              attribute: "길이",
                                            ),
                                          );
                                          // FocusScope.of(context).requestFocus(focusNodes[1]);
                                        },
                                        child: faultField(
                                            "길이 (m)",
                                            Text(
                                              appService.selectedFault.value
                                                      .length ??
                                                  "",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            needPadding: true),
                                      ),
                                    ),
                                    Gaps.w16,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          faultField(
                                              "개소(EA)",
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                      onTap: () {
                                                        int curQty = int.parse(
                                                            appService
                                                                .selectedFault
                                                                .value
                                                                .qty!);
                                                        if (curQty > 1) {
                                                          appService
                                                                  .selectedFault
                                                                  .value
                                                                  .qty =
                                                              (curQty - 1)
                                                                  .toString();
                                                          appService
                                                              .isFaultSelected
                                                              .value = false;
                                                          appService
                                                              .isFaultSelected
                                                              .value = true;
                                                        }
                                                      },
                                                      child: SizedBox(
                                                        height: 32,
                                                        child: Center(
                                                          child: Text(
                                                            " ‒ ",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Pretendard",
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: InkWell(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return NumberInputDialog2(
                                                                attribute:
                                                                    "개소");
                                                          },
                                                        );
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                          appService
                                                                  .selectedFault
                                                                  .value
                                                                  .qty ??
                                                              "1",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                      onTap: () {
                                                        int curQty = int.parse(
                                                            appService
                                                                    .selectedFault
                                                                    .value
                                                                    .qty ??
                                                                "1");
                                                        if (curQty < 10) {
                                                          appService
                                                                  .selectedFault
                                                                  .value
                                                                  .qty =
                                                              (curQty + 1)
                                                                  .toString();
                                                          appService
                                                              .isFaultSelected
                                                              .value = false;
                                                          appService
                                                              .isFaultSelected
                                                              .value = true;
                                                        }
                                                      },
                                                      child: SizedBox(
                                                        height: 32,
                                                        child: Center(
                                                          child: Text(
                                                            " + ",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Pretendard",
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              needPadding: false),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Gaps.h28,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            if ((appService.selectedFault.value
                                                        .structure ??
                                                    "구조") ==
                                                "비구조") {
                                              appService.selectedFault.value
                                                  .structure = "구조";
                                            } else {
                                              appService.selectedFault.value
                                                  .structure = "비구조";
                                            }
                                          });
                                        },
                                        child: faultField(
                                            null,
                                            Center(
                                              child: Text(
                                                appService.selectedFault.value
                                                        .structure ??
                                                    "비구조",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            needPadding: false),
                                      ),
                                    ),
                                    Gaps.w16,
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (appService.selectedFault.value
                                                    .ing_yn ==
                                                "Y") {
                                              appService.selectedFault.value
                                                  .ing_yn = "N";
                                            } else {
                                              appService.selectedFault.value
                                                  .ing_yn = "Y";
                                            }
                                          });
                                        },
                                        child: faultField(
                                            null,
                                            Center(
                                              child: Text(
                                                appService.selectedFault.value
                                                            .ing_yn ==
                                                        "Y"
                                                    ? "진행 O"
                                                    : "진행 X",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            needPadding: false),
                                      ),
                                    ),
                                    Gaps.w16,
                                    Expanded(
                                      child: faultField(
                                          null,
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return StatusSelectionDialog(
                                                      fault: appService
                                                          .selectedFault.value);
                                                },
                                              );
                                            },
                                            child: Center(
                                              child: Text(
                                                (appService.selectedFault.value
                                                                .status ==
                                                            null ||
                                                        appService
                                                            .selectedFault
                                                            .value
                                                            .status!
                                                            .isEmpty)
                                                    ? "상태"
                                                    : appService.selectedFault
                                                        .value.status!,
                                                style: TextStyle(
                                                    color: (appService
                                                                    .selectedFault
                                                                    .value
                                                                    .status ==
                                                                null ||
                                                            appService
                                                                .selectedFault
                                                                .value
                                                                .status!
                                                                .isEmpty)
                                                        ? Colors.black38
                                                        : Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          needPadding: false),
                                    ),
                                  ],
                                ),
                                Gaps.h28,
                                faultField(
                                    null,
                                    height: null,
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return CauseSelectionDialog(
                                                fault: appService
                                                    .selectedFault.value);
                                          },
                                        );
                                      },
                                      child: Text(
                                        (appService.selectedFault.value.cause ??
                                                    "") ==
                                                ""
                                            ? "발생 원인"
                                            : appService
                                                .selectedFault.value.cause!,
                                        style: TextStyle(
                                            color: (appService.selectedFault
                                                            .value.cause ??
                                                        "") ==
                                                    ""
                                                ? Colors.black38
                                                : Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    needPadding: true),
                                Gaps.h28,
                                faultField(
                                  null,
                                  height: null,
                                  Center(
                                    child: TextField(
                                      focusNode: focusNode,
                                      controller: noteController,
                                      textInputAction: TextInputAction.done,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "메모",
                                        hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 6),
                                        isDense: true,
                                      ),
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                      onTapOutside: (event) {
                                        focusNode.unfocus();
                                      },
                                    ),
                                  ),
                                  needPadding: true,
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ))
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
