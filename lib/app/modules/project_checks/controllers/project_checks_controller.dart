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
  final LocalGalleryDataService _localGalleryDataService;
  final ImagePicker imagePicker = ImagePicker();

  TextEditingController inspectorNameController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  late FocusNode inspectorNameFocus = FocusNode();

  ProjectChecksController({
    required this.appService,
    required LocalGalleryDataService localGalleryDataService,
  }) : _localGalleryDataService = localGalleryDataService;

  @override
  void onInit() {
    curProject.value = appService.curProject?.value;
    super.onInit();

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
    } catch (e) {
      EasyLoading.showError('$fieldName 저장 실패');
    }
  }

  // 도면목록
  goDrawingList() {
    Get.toNamed(Routes.DRAWING_LIST);
  }

  takePictureAndSet(String cate, String child, String pic) async {
    try {
      CustomPicture? newImage = await _takePicture();
      if (newImage == null) {
        EasyLoading.showToast("사진 촬영 실패");
        return;
      }

      final form = appService.curProject?.value.site_check_form;
      if (form == null) {
        EasyLoading.showToast("양식을 찾을 수 없습니다");
        return;
      }

      bool isUpdated = await _updatePictureInForm(
        form: form,
        category: cate,
        childKind: child,
        pictureTitle: pic,
        newPicture: newImage,
      );

      if (isUpdated) {
        EasyLoading.showSuccess("사진이 저장되었습니다");
        _localGalleryDataService.loadGalleryFromHive();
      } else {
        EasyLoading.showError("해당 위치를 찾을 수 없습니다");
      }
    } catch (e) {
      logError("사진 저장 중 오류가 발생했습니다: $e");
      EasyLoading.showError("사진 저장 중 오류가 발생했습니다: $e");
    }
  }

  Future<bool> _updatePictureInForm({
    required SiteCheckForm form,
    required String category,
    required String childKind,
    required String pictureTitle,
    required CustomPicture newPicture,
  }) async {
    InspectionData? targetData = form.data.firstWhereOrNull(
      (data) => data.caption == category,
    );

    if (targetData == null) {
      targetData = InspectionData(
        caption: category,
        children: [],
      );
      form.data.add(targetData);
    }

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
    }

    int sameTitleCount = targetChild.pictures
        .where((pic) => pic.title.startsWith(pictureTitle))
        .length;

    String finalTitle = pictureTitle;
    if (sameTitleCount > 0) {
      finalTitle = '$pictureTitle${sameTitleCount + 1}';
    }

    Picture newPic = Picture(
      title: finalTitle,
      pid: newPicture.pid,
      remark: '',
    );

    targetChild.pictures.add(newPic);
    appService.submitProject(appService.curProject!.value);
    curProject.refresh();

    return true;
  }

  Future<CustomPicture?> _takePicture() async {
    XFile? xFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: imageMaxWidth,
    );
    if (xFile != null) {
      String savedFilePath =
          await appService.savePhotoToExternal(File(xFile.path));

      CustomPicture newPicture = appService.makeNewPicture(
        pid: appService.createId(),
        projectSeq: appService.curProject!.value.seq!,
        filePath: savedFilePath,
        thumb: savedFilePath,
        kind: "현황",
        dataState: DataState.NEW,
      );
      return newPicture;
    }
    return null;
  }

  Future<void> onRemarkSubmit(
      CustomPicture targetPicture, String newRemark) async {
    if (targetPicture.pid == null) {
      EasyLoading.showError('사진 정보가 없습니다.');
      return;
    }

    try {
      final form = appService.curProject?.value.site_check_form;

      if (form == null) {
        EasyLoading.showError('폼이 없습니다.');
        return;
      }

      bool updated = false;

      for (var data in form.data) {
        for (var child in data.children) {
          for (var picture in child.pictures) {
            if (picture.pid == targetPicture.pid) {
              picture.remark = newRemark; // remark 업데이트!
              updated = true;
              break;
            }
          }
          if (updated) break;
        }
        if (updated) break;
      }

      if (updated) {
        EasyLoading.showSuccess('메모 저장 완료');
        appService.submitProject(appService.curProject!.value);
        curProject.refresh();
      } else {
        EasyLoading.showError('해당 사진을 찾을 수 없습니다.');
      }
    } catch (e) {
      EasyLoading.showError('메모 저장 실패: $e');
      rethrow;
    }
  }

  onDeletePicture(targetPicture) async {
    try {
      await _localGalleryDataService.changePictureState(
          pid: targetPicture.pid, state: DataState.DELETED);
    } catch (e) {
      logError('사진 삭제 실패');
    }

    final form = appService.curProject?.value.site_check_form;
    if (form == null) {
      EasyLoading.showError('폼이 없습니다.');
      return;
    }

    List<InspectionData> dataToRemove = [];
    for (var data in form.data) {
      List<Children> childrenToRemove = [];
      for (var child in data.children) {
        child.pictures
            .removeWhere((picture) => picture.pid == targetPicture.pid);

        if (child.pictures.isEmpty) {
          childrenToRemove.add(child);
        }
      }

      for (var child in childrenToRemove) {
        data.children.remove(child);
      }

      if (data.children.isEmpty) {
        dataToRemove.add(data);
      }
    }

    for (var data in dataToRemove) {
      form.data.remove(data);
    }

    appService.submitProject(appService.curProject!.value);
    _localGalleryDataService.loadGalleryFromHive();
    curProject.refresh();

    Get.back();
  }

  void onDateChange(DateTime date) {
    final formatted = DateFormat('yyyy-MM-dd').format(date);
    appService.curProject?.value.site_check_form?.inspectionDate = formatted;
    appService.submitProject(appService.curProject!.value);
  }
}
