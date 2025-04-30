import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';
import 'package:safety_check/app/modules/check_image/controllers/check_image_controller.dart';

import '../../../constant/data_state.dart';
import '../../../data/models/01_project.dart';
import '../../../data/models/04_fault.dart';
import '../../../data/models/05_picture.dart';
import '../../../data/services/app_service.dart';
import '../../../routes/app_pages.dart';

class ProjectGalleryController extends GetxController {
  final AppService _appService;
  final LocalGalleryDataService localGalleryDataService;
  ScrollController scrollController = ScrollController();
  Project? projectInfo;
  final List<String> imageCates = ["전체", "전경", "현황", "기타", "결함"];
  int gridColumn = 3;
  double crossAxisSpacing = 22;
  double mainAxisExtent = 233;
  double imageHeight = 185;

  FocusNode focusNode = FocusNode();

  ProjectGalleryController({
    required AppService appService,
    required this.localGalleryDataService,
  }) : _appService = appService;

  RxString curCate = "전체".obs;

  RxList<CustomPicture> searchResult = <CustomPicture>[].obs;

  List<Fault>? faultList;

  @override
  void onInit() {
    projectInfo = _appService.curProject?.value;
    faultList = _appService.markerList
        .map(
          (data) => data.fault_list,
        )
        .expand(
          (element) => element ?? [],
        )
        .cast<Fault>()
        .toList();
    Future.microtask(
      () async {
        localGalleryDataService.loadGalleryFromHive();
      },
    );
    super.onInit();
  }

  onTapBack() {
    Get.back();
  }

  void checkImage(CustomPicture picture) {
    // 기존 컨트롤러가 있다면 제거
    if (Get.isRegistered<CheckImageController>()) {
      Get.delete<CheckImageController>();
    }

    Get.toNamed(Routes.CHECK_IMGAGE,
        arguments: picture, preventDuplicates: false);
  }

  int checkPictureState(String pid) {
    return localGalleryDataService.checkState(pid) ?? 1;
  }

  String makeCateString(String? cate1Seq, List<String>? cate2Seq) {
    String cate1 = _appService.faultCate1?[cate1Seq] ?? "";
    String cate2 = cate2Seq
            ?.map(
              (e) => _appService.faultCate2?[e] ?? "",
            )
            .join(", ") ??
        "";
    String result = "$cate1 $cate2";
    if (cate1 == "" || cate2 == "") {
      result = result.trim();
    }
    return result;
  }

  deletePicture(String pid) {
    localGalleryDataService.changePictureState(
        pid: pid, state: DataState.DELETED);
    localGalleryDataService.loadGalleryFromHive();
  }
}
