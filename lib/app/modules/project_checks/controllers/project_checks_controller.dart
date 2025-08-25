import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/data/models/01_project.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/models/site_check_form.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';
import 'package:safety_check/app/utils/log.dart';
import '../../../routes/app_pages.dart';

class ProjectChecksController extends GetxController {
  final curProject = Rx<Project?>(null);
  final AppService appService;
  final LocalGalleryDataService
      localGalleryDataService; // Initialized in the constructor
  final ImagePicker imagePicker = ImagePicker();

  TextEditingController inspectorNameController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController picRemarkController = TextEditingController();

  late FocusNode inspectorNameFocus = FocusNode();

  ProjectChecksController({
    required this.appService,
    required LocalGalleryDataService localGalleryDataService,
  }) : localGalleryDataService = localGalleryDataService;

  @override
  void onInit() {
    curProject.value = appService.curProject?.value;
    super.onInit(); // 부모가 준비해놓은 기본 세팅까지 포함해서 초기화함(필수는 아니지만 하면 좋음)
    logInfo("데이터! : ${curProject.value?.site_check_form?.toJson()}");
    print("데이터! : ${curProject.value?.site_check_form?.toJson()}");
    print(" 현재 프로젝트! : ${curProject.toJson()}");

    if (curProject.value?.site_check_form == null) {
      appService.curProject?.value.site_check_form = SiteCheckForm(
        inspectorName: "",
        inspectionDate: "",
        data: [],
      );
    }

    inspectorNameFocus.addListener(() {
      if (!inspectorNameFocus.hasFocus) {
        _onFieldUnfocused('inspectorName', inspectorNameController.text);
      }
    });
  }

  void _onFieldUnfocused(String fieldName, String value) async {
    try {
      switch (fieldName) {
        case 'inspectorName':
          appService.curProject?.value.site_check_form?.inspectorName = value;
          break;
      }

      appService.submitProject(appService.curProject!.value);
      logInfo("!!!");
    } catch (e) {
      EasyLoading.showError('$fieldName 저장 실패');
    }
  }

  // 도면목록
  goDrawingList() {
    Get.toNamed(Routes.DRAWING_LIST);
  }

  takePictureAndSet(String cate, String child, String pic) async {
    // 드롭다운 오른쪽의 사진 촬영 버튼을 눌렀을 때 발동되는 함수
    // 1차, 2차, 3차 드롭다운에서 선택된 값 3개가 변수로 들어옴!!
    // 사진을 찍은 것을 하이브에 저장한 후 업로드를 눌러 업데이트 하는 기능이 필요하다.
    // 메모를 쓰려면 업로드를 먼저 누르게 해야한다.
    try {
      CustomPicture? newImage = await _takePicture(cate, child, pic);
      // 하이브에 업데이트
      print("newImage: ${newImage?.toJson()}");
      // {seq: null, project_seq: 3, drawing_seq: null,
      //fault_seq: null,
      //file_path: /storage/emulated/0/Pictures/Elim/Safety/scaled_62c44a77-9a06-4e0d-b8a3-32dd78f44c0b5946246287640078804.jpg,
      //file_name: null, file_size: null,
      //thumb: /storage/emulated/0/Pictures/Elim/Safety/scaled_62c44a77-9a06-4e0d-b8a3-32dd78f44c0b5946246287640078804.jpg,
      //no: null, kind: 현황, pid: 20250508145446344605, fid: null,
      //before_picture: null, location: null, cate1_seq: null,
      //cate2_seq: null, cate1_name: null, cate2_name: null, width: null,
      //length: null, dong: 외벽마감재 치장벽돌 좌측, floor: null, floor_name: null,
      //reg_time: null, update_time: null, state: 0}
      if (newImage == null) {
        EasyLoading.showToast("사진 촬영 실패");
        return;
      }

      final form = appService.curProject?.value.site_check_form;
      //  site_check_form: {"inspectorName":"ㄱ","inspectionDate":"ㄴ","data":[]}}]
      if (form == null) {
        EasyLoading.showToast("양식을 찾을 수 없습니다");
        return;
      }

      bool isUpdated = await _updatePictureInForm(
        // site_check_form에 사진 정보를 저장(사진이 서버에 저장된것은 아님)
        form: form, // 현재 프로젝트의 site_check_form
        category: cate, //  대분류
        childKind: child, // 중분류
        pictureTitle: pic, // 소분류
        newPicture: newImage, // 찍힌 사진의 정보
      );

      if (isUpdated) {
        curProject.refresh();
        localGalleryDataService.loadGalleryFromHive();
        EasyLoading.showSuccess("사진이 태블릿에 저장되었습니다");
      } else {
        EasyLoading.showError("해당 위치를 찾을 수 없습니다");
      }
    } catch (e) {
      logError("사진 저장 중 오류가 발생했습니다: $e");
      EasyLoading.showError("사진 저장 중 오류가 발생했습니다: $e");
    }
  }

  Future<CustomPicture?> _takePicture(
      String cate, String child, String pic) async {
    XFile? xFile = await imagePicker.pickImage(
      // image_picker 패키지를 통해 카메라 열기
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: imageMaxWidth,
    );
    if (xFile != null) {
      // 사진 촬영 후 처리
      String savedFilePath =
          await appService.savePhotoToExternal(File(xFile.path));
      // 디바이스의 사진 갤러리 또는 앱 외부 저장소 경로로 복사한 다음, 그 파일의 경로를 리턴할 거

      CustomPicture newPicture = appService.makeNewPicture(
          pid: appService.createId(),
          projectSeq: appService.curProject!.value.seq!,
          filePath: savedFilePath,
          thumb: savedFilePath,
          kind: "현황",
          dataState: DataState.NEW,
          dong: "${cate}-${child}(${pic})");
      return newPicture;
    }
    return null;
  }

  Future<bool> _updatePictureInForm({
    required SiteCheckForm form, // 현재 프로젝트의 siteCheckForm
    required String category, // 대분류
    required String childKind, // 중분류
    required String pictureTitle, // 소분류
    required CustomPicture newPicture, // 테블릿에 저장된 사진 그상태
  }) async {
    // 카테고리 찾기 또는 생성
    InspectionData? targetData = form.data.firstWhereOrNull(
      (data) => data.caption == category,
      // 대분류의 카테고리를 찾는다
    );

    if (targetData == null) {
      targetData = InspectionData(
        caption: category,
        children: [],
      );
      form.data.add(targetData);
      // 대분류 카테고리가 기존에 없었다면 새로 추가한다
    }

    // 중분류 항목 찾기 또는 생성
    Children? targetChild = targetData.children.firstWhereOrNull(
      (child) => child.kind == childKind,
    );

    if (targetChild == null) {
      targetChild = Children(
        kind: childKind,
        pictures: [],
        remark: '',
      );
      targetData.children.add(targetChild);
      // 중분류 카테고리가 기존에 없었다면 새로 추가한다
    }

    Picture newPic = Picture(
      title: pictureTitle,
      pid: newPicture.pid,
      remark: '',
    );

    targetChild.pictures.add(newPic);

    // 로그 및 저장
    logInfo("바로여기: ${appService.curProject?.value.site_check_form?.toJson()}");
    print("바로여기: ${appService.curProject?.value.site_check_form?.toJson()}");
    // 바로여기: {inspectorName: fff, inspectionDate: 2025-05-27, memo: null, opinion: null,
    //data: [{caption: 외벽마감재, remark: null, children: [{kind: 치장벽돌, pictures:
    //[{title: 정면, pic: Instance of 'CustomPicture', remark: }], remark: }]}]}

    return true;
  }

  Future<void> onRemarkSubmit(
      CustomPicture targetPicture, String newRemark) async {
    if (targetPicture.pid == null) {
      EasyLoading.showError('사진 정보가 없습니다.');
      return;
    }

    try {
      logInfo('사진 pid: ${targetPicture.pid}, 메모: $newRemark');

      final form = appService.curProject?.value.site_check_form;

      if (form == null) {
        EasyLoading.showError('폼이 없습니다.');
        return;
      }

      bool updated = false;

      // for (var data in form.data) {
      //   for (var child in data.children) {
      //     for (var picture in child.pictures) {
      //       if (picture.picture == targetPicture.picture) {
      //         picture.remark = newRemark; // remark 업데이트!
      //         updated = true;
      //         break;
      //       }
      //     }
      //     if (updated) break;
      //   }
      //   if (updated) break;
      // }

      // if (updated) {
      //   logInfo(
      //       "바로여기222: ${appService.curProject?.value.site_check_form?.toJson()}");
      //   EasyLoading.showSuccess('메모 저장 완료');
      //   appService.submitProject(appService.curProject!.value);
      //   curProject.refresh(); // UI 갱신
      // } else {
      //   EasyLoading.showError('해당 사진을 찾을 수 없습니다.');
      // }
    } catch (e) {
      EasyLoading.showError('메모 저장 실패: $e');
      rethrow;
    }
  }

  void onFixingReasonClick(Children? data, String? fixingReason) {
    final form = appService.curProject?.value.site_check_form;
    if (form == null || fixingReason == null || data == null) return;

    data.remark = fixingReason;

    appService.submitProject(appService.curProject!.value);
    curProject.refresh();
  }

  onDeletePicture(targetPicture) async {
    logInfo('onDeletePicture');
    // 1. 먼저 Hive 상태 삭제 처리
    try {
      await localGalleryDataService.changePictureState(
          pid: targetPicture.pid, state: DataState.DELETED);
    } catch (e) {
      logInfo('사진 삭제 실패');
    }

    // 2. 서버 및 현장점검 데이터 구조 반영
    final form = appService.curProject?.value.site_check_form;
    if (form == null) {
      EasyLoading.showError('폼이 없습니다.');
      return;
    }

    // 삭제 대상 사진을 가진 child와 data를 추적하기 위한 임시 변수
    List<InspectionData> dataToRemove = [];

    for (var data in form.data) {
      List<Children> childrenToRemove = [];
      // for (var child in data.children) {
      //   child.pictures
      //       .removeWhere((picture) => picture.pid == targetPicture.pid);

      //   // 2-1. picture가 모두 삭제되었으면 children에서도 삭제 대상에 추가
      //   if (child.pictures.isEmpty) {
      //     childrenToRemove.add(child);
      //   }
      // }

      // 2-2. 빈 children 제거
      for (var child in childrenToRemove) {
        data.children.remove(child);
      }

      // 2-3. data 내 children이 없으면 data도 제거 대상
      if (data.children.isEmpty) {
        dataToRemove.add(data);
      }
    }

    // 2-4. 빈 카테고리 제거
    for (var data in dataToRemove) {
      form.data.remove(data);
    }

    // 3. 서버 전송 및 상태 반영
    appService.submitProject(appService.curProject!.value);
    localGalleryDataService.loadGalleryFromHive();
    curProject.refresh();

    // 4. 닫기
    Get.back();
  }

  void onDateChange(DateTime date) {
    final formatted = DateFormat('yyyy-MM-dd').format(date);
    appService.curProject?.value.site_check_form?.inspectionDate = formatted;
    appService.submitProject(appService.curProject!.value);
  }

  onMakeOpinionClick(opinion) {
    final form = appService.curProject?.value.site_check_form;
    if (form == null) return;
    form.opinion = opinion;
    appService.submitProject(appService.curProject!.value);
  }

  onMakeMemoClick(memo) {
    final form = appService.curProject?.value.site_check_form;
    if (form == null) return;
    form.memo = memo;
    appService.submitProject(appService.curProject!.value);
  }
}
