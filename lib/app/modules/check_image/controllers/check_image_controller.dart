import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';

import '../../project_gallery/controllers/project_gallery_controller.dart';

class CheckImageController extends GetxController {
  final AppService _appService;
  final LocalGalleryDataService _localGalleryDataService;

  CheckImageController({
    required AppService appService,
    required LocalGalleryDataService localGalleryDataService,
  })  : _appService = appService,
        _localGalleryDataService = localGalleryDataService;

  TransformationController transformationController1 =
      TransformationController();
  TransformationController transformationController2 =
      TransformationController();
  RxBool isCompareMode = false.obs;
  CustomPicture? original;
  CustomPicture? compare;
  String projectName = "";
  String drawingName = "";

  List<String> kind = ["기타", "전경"];
  RxString curKind = "".obs;
  RxString curLocation = "".obs;

  @override
  void onInit() {
    original = Get.arguments as CustomPicture;
    if (original?.dong != null) {
      projectName += (original?.dong)!;
    }
    if (original?.floor_name != null) {
      if (projectName != "") {
        projectName += " ";
      }
      projectName += (original?.floor_name)!;
    }
    if (original?.location != null) {
      if (projectName != "") {
        projectName += " ";
      }
      projectName += (original?.location)!;
    }
    if (projectName == "") {
      projectName = "사진 정보 없음";
    }

    if (original?.cate1_seq != null || original?.cate2_seq != null) {
      String cate = makeCateString(original?.cate1_seq, original?.cate2_seq);
      if (projectName != "" && cate != "") {
        projectName += " / ";
      }
      projectName += cate;
    }

    if (original?.width != null) {
      if (projectName != "") {
        projectName += " / ";
      }
      projectName += "폭 ${original?.width!}mm";
    }
    if (original?.length != null) {
      if (projectName != "") {
        projectName += " / ";
      }
      projectName += "길이 ${original?.length!}m";
    }

    drawingName = _appService.drawingName;
    compare = original?.before_picture;
    curLocation.value = original?.location ?? "부위 없음";

    curKind.value = original?.kind == "결함" ? "기타" : original?.kind ?? "기타";
    if (canChangeToCurrent() || original?.kind == "현황") {
      kind.add("현황");
    }
    // print(canChangeToCurrent());
    // print(kind);
    super.onInit();
  }

  onDoubleTap(bool isOriginal) {
    if (isOriginal) {
      transformationController2.value = Matrix4.identity();
    } else {
      transformationController1.value = Matrix4.identity();
    }
  }

  onClickCompareSwitch(bool value) {
    if (compare != null) {
      transformationController1.value = Matrix4.identity();
      transformationController2.value = Matrix4.identity();
      isCompareMode.value = value;
    } else {
      Fluttertoast.showToast(msg: "비교할 사진이 없습니다!");
    }
  }

  canChangeToCurrent() {
    if (original!.drawing_seq == null) return false;
    return true;
  }

  changeKind(String newKind) {
    if (original!.kind != "현황" &&
        original!.drawing_seq == null &&
        newKind == "현황") {
      Fluttertoast.showToast(msg: "해당 사진은 현황 사진으로 변경할 수 없습니다!");
      return;
    }
    _localGalleryDataService.changePictureKind(
      pid: original!.pid!,
      kind: newKind,
    );
    _localGalleryDataService.changePictureState(
      pid: original!.pid!,
      state: DataState.EDITED,
    );
    _localGalleryDataService.loadGalleryFromHive();

    original?.kind = newKind;
    curKind.value = newKind;

    _appService.isLeftBarOpened.refresh();
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

  void changeLocation(String selectedLocation) {
    _localGalleryDataService.changePictureLocation(
        pid: original!.pid!, location: selectedLocation);
    _localGalleryDataService.changePictureState(
        pid: original!.pid!, state: DataState.EDITED);
    original?.location = selectedLocation;
    curLocation.value = selectedLocation;
    // print(selectedLocation);
    _appService.isLeftBarOpened.value = true;
    _appService.isLeftBarOpened.value = false;
    ProjectGalleryController projectGalleryController = Get.find();
    projectGalleryController.localGalleryDataService.loadGalleryFromHive();
  }

  deletePicture() async {
    EasyLoading.show(dismissOnTap: true);
    await _localGalleryDataService.changePictureState(
        pid: original!.pid!, state: DataState.DELETED);

    // 갤러리 새로고침
    _localGalleryDataService.loadGalleryFromHive();

    // 결함에서 사진 제거
    _appService.selectedFault.value.picture_list?.removeWhere(
      (element) => element.pid == original?.pid,
    );
    _appService.selectedFault.refresh();

    // if (_appService.isProjectInfoPage || _appService.isGalleryOpened) {
    //   // 갤러리 들어가서 삭제
    //   ProjectGalleryController projectGalleryController = Get.find();
    //   projectGalleryController.fetchData();
    // } else {
    //   // 도면 들어가서 삭제
    //   DrawingDetailController drawingDetailController =
    //       Get.find<DrawingDetailController>();
    //   // print("DELETE PICTURE!!!!!!");
    //   _appService.selectedFault.value.picture_list?.removeWhere(
    //     (element) => element.pid == original?.pid,
    //   );
    //   drawingDetailController.countFaults();
    //   _appService.isFaultSelected.value = false;
    //   _appService.selectedFault.value = Fault();
    // }

    // if (_appService.isProjectInfoPage) {
    //   ProjectInfoController projectInfoController = Get.find();
    //   projectInfoController.fetchData();
    // }

    Get.back();
    EasyLoading.dismiss();
  }
}
