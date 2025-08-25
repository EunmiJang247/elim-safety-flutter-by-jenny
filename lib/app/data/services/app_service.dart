import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import "package:path/path.dart";
import 'package:path_provider/path_provider.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/models/06_engineer.dart';
import 'package:safety_check/app/data/models/07_fault_cate1_list.dart';
import 'package:safety_check/app/data/models/08_fault_cate2_list.dart';
import 'package:safety_check/app/data/models/09_appended.dart';
import 'package:safety_check/app/data/models/11_drawing_memo.dart';
import 'package:safety_check/app/data/models/fault_category.dart';
import 'package:safety_check/app/modules/drawing_detail/controllers/drawing_detail_controller.dart';
import 'package:safety_check/app/widgets/web_3d_view.dart';
import 'package:image/image.dart' as img; // image 패키지

import '../../routes/app_pages.dart';
import '../../utils/log.dart';
import '../models/03_marker.dart';
import '../models/04_fault.dart';
import '../models/10_elem_list.dart';
import '../models/base_response.dart';
import '../models/02_drawing.dart';
import '../models/01_project.dart';
import '../models/sign_in_response.dart';
import '../models/update_history.dart';
import '../models/00_user.dart';
import '../repository/app_repository.dart';
import 'local_app_data_service.dart';
import 'local_gallery_data_service.dart';

class AppService extends GetxService {
  final AppRepository _appRepository;
  final LocalAppDataService _localAppDataService;
  final LocalGalleryDataService _localGalleryDataService;

  User? user;
  List? locationList = [];
  List? statusList = [];
  List? causeList = [];
  Map<String, String>? faultCate1;
  Map<String, String>? faultCate2;
  List<ElementList>? elements;
  String projectName = "";
  String drawingName = "";
  // String? curProjectSeq;
  // String? curDrawingSeq;

  Rx<Drawing> curDrawing = Drawing().obs;

  Map<String, List> faultImageInfo = {};

  // 결함 현황표 관련
  int faultTableCurRowIndex = -1;
  Rx<Fault> selectedFault = Rx(Fault());
  RxBool isFaultSelected = false.obs;
  RxList faultTableGroupingIndexes = [].obs;
  // 화면에 출력중인 결함 (group_fid 같은 것중 하나)
  Map<String, String> displayingFid = {};

  AppService({
    required AppRepository appRepository,
    required LocalAppDataService localAppDataService,
    required LocalGalleryDataService localGalleryDataService,
  })  : _appRepository = appRepository,
        _localAppDataService = localAppDataService,
        _localGalleryDataService = localGalleryDataService;

  Rx<bool> isOfflineMode = false.obs;
  Rx<UpdateHistoryItem?> lastUpdateHistory =
      Rx(UpdateHistoryItem(history: [], version: "", update_date: ""));
  DateTime? currentBackPressTime;

  RxList<Project> projectList = <Project>[].obs;
  RxList<Drawing> drawingList = <Drawing>[].obs;
  RxList<Marker> markerList = <Marker>[].obs;
  List<Fault> get faultList => markerList
      .map<List<Fault>>(
        (e) => e.fault_list ?? [],
      )
      .expand(
        (element) => element,
      )
      .toList();
  Rx<Project>? curProject = Project().obs;

  Future<BaseResponse?> init() async {
    BaseResponse? response = await _appRepository.init();
    return response;
  }

  Future<BaseResponse?> test() async {
    BaseResponse? response = await _appRepository.test();
    return response;
  }

  void onPop(context) {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) >
            const Duration(milliseconds: 1500)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("한번 더 누르면 종료됩니다."),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 46),
          duration: Duration(milliseconds: 1500),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  String createId() {
    // 마커 id 만드는 함수에 쓰임
    // 현재 시각(년/월/일/시/분/초/밀리초)을 가져와서 숫자 문자열만 남겨 반환한다
    return DateTime.now().toString().replaceAll(RegExp(r"[\s-:.]"), "");
  }

  Future<String?> signIn({
    required String email,
    required String password,
    required bool offline,
  }) async {
    isOfflineMode.value = offline;
    String? result;
    SignInResponse? response;

    if (offline) {
      user = _localAppDataService.getLastLoginUser();
      // if (password != user?.password) {
      //   result = '마지막으로 로그인했던 아이디와 비밀번호를 입력하세요.';
      //   return result;
      // }

      locationList = _localAppDataService.getLocationList();
    } else {
      await EasyLoading.show(dismissOnTap: true);
      BaseResponse? baseResponse = await _appRepository.signIn(
        email: email,
        password: password,
      );
      if (baseResponse?.result?.code != 100) {
        result = baseResponse?.result?.message;
      } else {
        response = SignInResponse(
            user: User.fromJson(baseResponse?.data?['user']),
            engineers: (baseResponse?.data?['engineer_list'])
                .map((e) => Engineer.fromJson(e))
                .toList()
                .cast<Engineer>(),
            faultCate1List: FaultCate1List.fromJson(baseResponse?.data),
            faultCate2List: FaultCate2List.fromJson(baseResponse?.data),
            elements: baseResponse?.data?["elem_list"]
                .map((e) => ElementList.fromJson(e))
                .toList()
                .cast<ElementList>(),
            locationList: baseResponse?.data?["location_list"],
            statusList: baseResponse?.data?["status_list"],
            causeList: baseResponse?.data?["cause_list"]);
        if (response.user != null) {
          user = response.user!;
          if (user != null) {
            await _localAppDataService.writeLastLoginUser(user!);
          }
          if (response.faultCate1List != null) {
            faultCate1 = FaultCategory.listToMap(
                response.faultCate1List?.fault_cate1_list ?? []);
            // await _localAppDataService.writ
          }
          if (response.faultCate2List != null) {
            faultCate2 = FaultCategory.listToMap(
                response.faultCate2List?.fault_cate2_list ?? []);
            // await _localAppDataService.writ
          }
          if (response.elements != null) {
            elements = response.elements;
          }
          if (response.locationList != null) {
            locationList = response.locationList;
          }
          // print(locationList);
          if (response.statusList != null) {
            statusList = response.statusList;
          }
          // print(statusList);

          if (response.causeList != null) {
            causeList = response.causeList;
          }
          // print(causeList);
          logSuccess(response.user!.toJson(),
              des: 'AppService.signIn($email / $password)');
        }
        // if (response.location_List != null) {
        //   location_list = response.location_List!;
        //   await _localAppDataService.putLocationList(location_list!);
        // }
        // await EasyLoading.dismiss();
      }
    }
    return result;
  }

  Future<String?> logOut() async {
    String? result;
    BaseResponse? baseResponse = await _appRepository.logOut();
    if (baseResponse?.result?.code != 100) {
      result = baseResponse?.result?.message;
    } else {}
    isLeftBarOpened.value = false;
    Get.offAllNamed(Routes.LOGIN);
    return result;
  }

  Future<String?> findPw({String? email}) async {
    if (email != null) {
      String? result = await _appRepository.findPw(email: email);
      return result;
    } else {
      return "";
    }
  }

  Future<List<Project>?> getProjectList({required int my, String? q}) async {
    List<Project>? result;

    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.searchProjectList(my: my, q: q);
      projectList.value = result ?? [];

      // for (Project prj in projectList) {
      //   // await _localAppDataService.putProject(user!.seq, prj);
      // }
    }
    return result;
  }

  Future<Map?> submitProject(Project project) async {
    Map? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.submitProject(project: project);
    }
    return result;
  }

  Future<List<Drawing>?> getDrawingList({required String? projectSeq}) async {
    List<Drawing>? result;

    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.searchDrawingList(projectSeq: projectSeq);
      drawingList.value = result ?? [];

      // for (Drawing prj in drawingList) {
      //   // await _localAppDataService.putProject(user!.seq, prj);
      // }
    }
    return result;
  }

  // 도면 메모 저장
  Future<DrawingMemo?> submitDrawingMemo(DrawingMemo memo) async {
    DrawingMemo? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.submitDrawingMemo(memo: memo);
    }
    return result;
  }

  // 도면 메모 삭제
  Future deleteDrawingMemo(String memoSeq) async {
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      await _appRepository.deleteDrawingMemo(memoSeq: memoSeq);
    }
    return null;
  }

  toFloorName(String floor) {
    String floorName = "";
    if (int.parse(floor) < 0) {
      floorName = floor.replaceFirst('-', '지하 ');
    } else if (floor == "127") {
      floorName = "지붕";
    } else if (floor == "126") {
      floorName = "옥상";
    }
    floorName += "층";
    return floorName;
  }

  Future<String?> copyDrawing({required String? seq}) async {
    String? result;

    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.copyDrawing(seq: seq);
    }
    return result;
  }

  Future<List<Marker>?> getMarkerList({
    String? drawingSeq,
    String? projectSeq,
    String? mid,
  }) async {
    List<Marker>? result;

    if (isOfflineMode.value) {
      result = _localAppDataService.MarkerList;
    } else {
      result = await _appRepository.searchMarkerList(
        projectSeq: projectSeq,
        drawingSeq: drawingSeq,
        mid: mid,
      );
      markerList.value = result ?? [];

      for (Marker marker in markerList) {
        _localAppDataService.putMarker(marker);
        if (marker.fault_list != null) {
          for (Fault flt in marker.fault_list!) {
            if (flt.picture_list != null) {
              for (CustomPicture pic in flt.picture_list!) {
                if (!_localGalleryDataService.isPictureInBox(pic.pid!)) {
                  _localGalleryDataService.addPicture(makeNewPicture(
                    seq: pic.seq!,
                    pid: pic.pid!,
                    projectSeq: pic.project_seq!,
                    fid: pic.fid!,
                    filePath: pic.file_path!,
                    thumb: pic.thumb!,
                    location: pic.location,
                    dong: pic.dong,
                    floorName: pic.floor_name,
                    kind: "결함",
                    no: pic.no,
                  ));
                }
              }
            }
          }
        }
      }
    }
    return result;
  }

  Future<String?> sortMarker({required String? drawingSeq}) async {
    String? result;

    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.sortMarker(drawingSeq: drawingSeq);
    }
    return result;
  }

  Future<Map?> submitMarker(
      {required bool isNew,
      required Marker marker,
      String? lastFaultSeq,
      String? markerSize}) async {
    Map? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.submitMarker(
          isNew: isNew,
          marker: marker,
          lastFaultSeq: lastFaultSeq,
          markerSize: markerSize);
    }
    return result;
  }

  Future<Appended?> deleteMarker(
      {required String markerSeq, String? lastFaultSeq}) async {
    Appended? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.deleteMarker(
          seq: markerSeq, lastFaultSeq: lastFaultSeq);
    }
    return result;
  }

  Future<Appended?> overrideMarker(
      {required String fromSeq,
      required String toSeq,
      String? lastFaultSeq}) async {
    Appended? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.overrideMarker(
          fromSeq: fromSeq, toSeq: toSeq, lastFaultSeq: lastFaultSeq);
    }
    return result;
  }

  Future<Map?> mergeMarker(
      {required String fromSeq,
      required String toSeq,
      String? lastFaultSeq}) async {
    Map? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.mergeMarker(
          fromSeq: fromSeq, toSeq: toSeq, lastFaultSeq: lastFaultSeq);
    }
    return result;
  }

  Future<Map?> submitFault({
    required bool isNew,
    required Fault fault,
    String? mid,
    String? lastFaultSeq,
  }) async {
    Map? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.submitFault(
          isNew: isNew, fault: fault, mid: mid, lastFaultSeq: lastFaultSeq);
    }
    return result;
  }

  Future<Appended?> deleteFault(
      {required String faultSeq, String? lastFaultSeq}) async {
    Appended? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.deleteFault(
          seq: faultSeq, lastFaultSeq: lastFaultSeq);
    }
    return result;
  }

  // 사진 목록 새로고침 (서버에서 사진 불러와 디비에 저장하고 디비 내용 불러옴)
  Future<List<CustomPicture>?> searchPicture(
      {required String? projectSeq}) async {
    List<CustomPicture>? result = [];
    try {
      List<CustomPicture>? pictures =
          await _appRepository.searchPicture(projectSeq: projectSeq) ?? [];
      List pidList = pictures
          .map(
            (e) => e.pid,
          )
          .toList();
      for (CustomPicture pic in _localGalleryDataService.PictureList) {
        if (pic.project_seq == projectSeq &&
            !pidList.contains(pic.pid) &&
            pic.seq != null) {
          _localGalleryDataService.removePicture(pic.pid!);
        }
      }
      for (CustomPicture pic in pictures) {
        if (!_localGalleryDataService.isPictureInBox(pic.pid!)) {
          _localGalleryDataService.addPicture(makeNewPicture(
              seq: pic.seq!,
              pid: pic.pid!,
              projectSeq: pic.project_seq!,
              fid: pic.fid,
              filePath: pic.file_path!,
              thumb: pic.thumb!,
              kind: pic.fid == null ? "기타" : "결함",
              location: pic.location,
              dong: pic.dong,
              floorName: pic.floor_name,
              no: pic.no));
        } else {
          int? picState = _localGalleryDataService.checkState(pic.pid!);
          if (picState != null &&
              (picState == DataState.EDITED.index ||
                  picState == DataState.DELETED.index)) {
            continue;
          }
          pic.state = DataState.NOT_CHANGED.index;
          _localGalleryDataService.updatePicture(
              pid: pic.pid!, changedPicture: pic);
        }
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    result = _localGalleryDataService.PictureList.where((element) =>
        element.project_seq == projectSeq &&
        element.state != DataState.DELETED.index).toList();
    return result;
  }

  Future<int> uploadPicture({
    required int currentCount,
    required int totalCount,
  }) async {
    List<CustomPicture> pictureList = _localGalleryDataService.PictureList;
    if (pictureList.isEmpty) return 0;

    for (CustomPicture picture in pictureList) {
      if (picture.state == DataState.NEW.index) {
        BaseResponse? response =
            await _appRepository.uploadPicture(newPicture: picture);
        if (response?.result?.code != 100) {
          logError(response?.result?.message,
              des: 'AppService.uploadPicture(pid:${picture.pid})');

          if (response?.result?.code == 400) {
            await _localGalleryDataService.removePicture(picture.pid!);
          }
        } else {
          CustomPicture uploadedPicture =
              CustomPicture.fromJson(response?.data);
          // print(uploadedPicture.no);
          uploadedPicture.state = DataState.NOT_CHANGED.index;
          _localGalleryDataService.updatePicture(
              pid: uploadedPicture.pid!, changedPicture: uploadedPicture);
          if (uploadedPicture.fid != null) {
            for (Marker marker in markerList) {
              for (Fault fault in marker.fault_list ?? []) {
                if (fault.fid == uploadedPicture.fid) {
                  fault.picture_list ??= [];
                  fault.picture_list?.add(uploadedPicture);
                  fault.pic_no = uploadedPicture.no;
                  if (Get.isRegistered<DrawingDetailController>()) {
                    DrawingDetailController drawingDetailController =
                        Get.find();
                    drawingDetailController.countFaults();
                  }
                }
              }
            }
          }
        }
        currentCount++;
        await EasyLoading.showProgress(
          currentCount / totalCount,
          status: '사진 업로드중...\n$currentCount/$totalCount',
          maskType: EasyLoadingMaskType.black,
        );
      }
    }

    return currentCount;
  }

  Future<int> updatePicture({
    required int currentCount,
    required int totalCount,
  }) async {
    List<CustomPicture>? pictureList = _localGalleryDataService.PictureList;
    if (pictureList.isEmpty) return 0;

    for (CustomPicture picture in pictureList) {
      if (picture.state == DataState.EDITED.index) {
        BaseResponse? response;
        if (picture.seq != null) {
          response = await _appRepository.updatePicture(
              pid: picture.pid,
              kind: picture.kind,
              seq: picture.seq!,
              location: picture.location);
        } else {
          response = await _appRepository.uploadPicture(newPicture: picture);
        }
        if (response?.result?.code != 100) {
          logError(response?.result?.message,
              des: 'AppService.updateEditedGallery(pid:${picture.pid})');
          switch (response?.result?.code) {
            case 300:
            case 400:
              _localGalleryDataService.removePicture(picture.pid!);
              break;
          }
        } else {
          _localGalleryDataService.changePictureState(
              pid: picture.pid!, state: DataState.NOT_CHANGED);
        }
        currentCount++;
        await EasyLoading.showProgress(
          currentCount / totalCount,
          status: '사진 수정중...\n$currentCount/$totalCount',
          maskType: EasyLoadingMaskType.black,
        );
      }
    }
    return currentCount;
  }

  Future<int> deletePicture({
    required int currentCount,
    required int totalCount,
  }) async {
    // print("DeletePicture");
    // print(currentCount);
    // print(totalCount);
    List<CustomPicture>? pictureList = _localGalleryDataService.PictureList;
    if (pictureList.isEmpty) return 0;

    for (CustomPicture picture in pictureList) {
      if (picture.state == DataState.DELETED.index) {
        if (picture.seq != null) {
          BaseResponse? response =
              await _appRepository.deletePicture(seq: picture.seq!);
          if (response?.result?.code != 100) {
            logError(response?.result?.message,
                des: 'AppService.updateDeletedGallery(pid:${picture.pid})');
          } else {
            _localGalleryDataService.removePicture(picture.pid!);
          }
        } else {
          _localGalleryDataService.removePicture(picture.pid!);
        }
        currentCount++;
        await EasyLoading.showProgress(
          currentCount / totalCount,
          status: '사진 삭제중...\n$currentCount/$totalCount',
          maskType: EasyLoadingMaskType.black,
        );
      }
    }
    return currentCount;
  }

  Future<int?> addFaultContent(
      {required int type, required String name}) async {
    int? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      if (type == 1) {
        result = await _appRepository.addFaultCate1(name: name);
        if (result != null) {
          faultCate1 ??= {};
          faultCate1![result.toString()] = name;
        }
      } else if (type == 2) {
        result = await _appRepository.addFaultCate2(name: name);
        if (result != null) {
          faultCate2 ??= {};
          faultCate2![result.toString()] = name;
        }
      } else {
        result = await _appRepository.addFaultElem(name: name);
      }
    }
    return result;
  }

  bool checkNeedUpdate() {
    bool? result;

    // 변경된 사진 체크
    result = _localGalleryDataService.PictureList.where(
      (element) => element.state != DataState.NOT_CHANGED.index,
    ).isNotEmpty;

    return result;
  }

  Future<void> uploadCompleted() async {
    //Project? project = await _appRepository.submitCompleted(project_seq: project_seq);
    // if (project != null) {
    //   int index = projectList.value.indexWhere((element) => isSameValue(element.seq, project.seq));
    //   if (index != -1) {
    //     projectList.update((val) {
    //       val?[index] = val[index].copyWithAppSubmitTime(project.app_submit_time);
    //     });
    //   }
    // }
    //logInfo(project?.toJson(), des: 'AppService.updateCompleted($project_seq)');
  }

  CustomPicture makeNewPicture(
      {String? seq,
      required String pid,
      required String projectSeq,
      String? fid,
      required String filePath,
      required String thumb,
      required String kind,
      DataState dataState = DataState.NOT_CHANGED,
      String? dong,
      String? floorName,
      String? no,
      String? location,
      String? cate1Seq,
      List<String>? cate2Seq,
      String? width,
      String? length}) {
    CustomPicture newPicture = CustomPicture(
      seq: seq,
      pid: pid,
      file_path: filePath,
      project_seq: projectSeq,
      drawing_seq: curDrawing.value.seq,
      thumb: thumb,
      fid: fid,
      kind: kind,
      no: no,
      dong: dong,
      floor_name: floorName,
      location: location,
      cate1_seq: cate1Seq,
      cate2_seq: cate2Seq,
      width: width,
      length: length,
      state: dataState.index,
    );
    if (curDrawing.value.seq != null) {
      // Drawing curDrawing = drawingList.singleWhere(
      //     (element) => element.seq == curDrawingSeq,
      //     orElse: () => Drawing());
      // Fault curFault = Fault();
      // if (fid != null) {
      //   curFault = faultList.singleWhere((element) => element.fid == fid,
      //       orElse: () => Fault());
      // }
    }
    _localGalleryDataService.addPicture(newPicture);
    // print("NEW PICTURE ADDED!!");
    // print("PRO_SEQ: $projectSeq");
    // print("DRAW_SEQ: $curDrawingSeq");
    return newPicture;
  }

  changeFaultPictureInfo(String pid, Fault fault) {
    CustomPicture? changedPicture =
        _localGalleryDataService.gallery_box.get(pid);
    if (changedPicture != null) {
      changedPicture.floor_name = fault.floor;
      changedPicture.dong = fault.dong;
      changedPicture.location = fault.location;
      changedPicture.cate1_seq = fault.cate1_seq;
      changedPicture.cate2_seq = fault.cate2?.split(", ");
      changedPicture.length = fault.length;
      changedPicture.width = fault.width;
      _localGalleryDataService.updatePicture(
          pid: pid, changedPicture: changedPicture);
    }
  }

  //=========================================== Left Bar Control =============================================

  RxBool isLeftBarOpened = false.obs;
  Rx<List<bool?>> needUpdateCheckList = Rx([]);
  bool isProjectSelected = false;
  // bool isGalleryOpened = false;
  bool isProjectInfoPage = false;
  String liveTourUrl = "";
  List<UpdateHistoryItem>? get updateHistory =>
      Get.find<LocalAppDataService>().getUpdateHistory();
  bool get needUpdate => checkNeedUpdate();

  getUser() {
    return user;
  }

  toggleLeftBarCollapsed() {
    isLeftBarOpened.value = !isLeftBarOpened.value;
  }

  projectSelected() {
    isProjectSelected = true;
  }

  projectClosed() {
    isProjectSelected = false;
  }

  // initUpdateCheckList() {
  //   List<bool?> result = [];
  //   result.add(_appService.checkNeedUpdate());
  //   needUpdateCheckList.value = result;
  // }

  onTapHome() {
    isLeftBarOpened.value = false;
    isProjectSelected = false;
    curDrawing.value = Drawing();
    Get.offAllNamed(Routes.PROJECT_LIST);
  }

  onTapSendDataToServer() async {
    isLeftBarOpened.value = false;
    List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.wifi) &&
        !connectivityResult.contains(ConnectivityResult.ethernet) &&
        !connectivityResult.contains(ConnectivityResult.mobile)) {
      return await EasyLoading.showInfo('네트워크 연결이 필요합니다.');
    }

    // List<EditedProject> editedProjectList = _localMachineDataService.getEditedProjectList();
    List<CustomPicture> changedPictures =
        _localGalleryDataService.PictureList.where(
      (element) => element.state != DataState.NOT_CHANGED.index,
    ).toList();

    int totalCount = changedPictures.length;
    // print("TOTAL: $totalCount");
    // print("UPLOAD: ${_localGalleryDataService.PictureList.where(
    //   (element) => element.state == DataState.NEW.index,
    // ).length}");
    // print("UPDATE: ${_localGalleryDataService.PictureList.where(
    //   (element) => element.state == DataState.EDITED.index,
    // ).length}");
    // print("DELETE: ${_localGalleryDataService.PictureList.where(
    //   (element) => element.state == DataState.DELETED.index,
    // ).length}");

    if (totalCount < 1) {
      // initUpdateCheckList();
      return;
    }

    int currentCount = 0;
    await EasyLoading.showProgress(
      currentCount / totalCount,
      status: '서버 전송중...\n$currentCount/$totalCount',
      maskType: EasyLoadingMaskType.black,
    );

    // if (mid == null) {
    //   int updatedEditedProjectCount = await _appService.updateEditedProject(
    //     totalCount: totalCount,
    //     currentCount: currentCount,
    //   );
    //   if (updatedEditedProjectCount >= 0) currentCount += updatedEditedProjectCount;
    // }

    try {
      int uploadedPicCount = await uploadPicture(
        totalCount: totalCount,
        currentCount: currentCount,
      );
      if (uploadedPicCount >= 0) currentCount = uploadedPicCount;

      int updatedPicCount = await updatePicture(
        totalCount: totalCount,
        currentCount: currentCount,
      );
      if (updatedPicCount >= 0) currentCount = updatedPicCount;

      int deletedPicCount = await deletePicture(
        totalCount: totalCount,
        currentCount: currentCount,
      );
      if (deletedPicCount >= 0) currentCount = deletedPicCount;
    } on Exception catch (e) {
      await EasyLoading.dismiss();
      Fluttertoast.showToast(msg: "전송중 에러가 발생했습니다. $e");
    }

    await uploadCompleted();
    // initUpdateCheckList();
    Fluttertoast.showToast(msg: "전송이 완료되었습니다!");

    // ProjectGalleryController projectGalleryController = Get.find();
    // projectGalleryController.fetchData();
    isLeftBarOpened.refresh();

    LocalGalleryDataService localGalleryDataService =
        Get.find<LocalGalleryDataService>();
    localGalleryDataService.fetchGalleryPictures();

    await EasyLoading.dismiss();
  }

  onTapGallery() {
    isLeftBarOpened.value = false;
    Get.toNamed(Routes.PROJECT_GALLERY, arguments: curProject);

    // if (!isGalleryOpened) {
    //   _localGalleryDataService.fetchGalleryPictures();
    // } else {
    //   Get.offNamedUntil(
    //       Routes.PROJECT_GALLERY, ModalRoute.withName('/project-gallery'));
    //   Get.back();
    // }
  }

  cameraSelected() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: imageMaxWidth,
    );
    if (file != null) {
      String savedFilePath = await savePhotoToExternal(File(file.path));
      // File resizedFile = await compressImage(file);

      String? floorName;
      if (curDrawing.value.seq != null) {
        Drawing drawing = drawingList.singleWhere(
            (element) => element.seq == curDrawing.value.seq,
            orElse: () => Drawing());
        floorName = drawing.floor_name;
      }
      makeNewPicture(
        pid: createId(),
        projectSeq: curProject!.value.seq!,
        filePath: savedFilePath,
        thumb: savedFilePath,
        kind: curDrawing.value.seq != null ? "현황" : "기타",
        dong: curDrawing.value.dong,
        floorName: floorName,
        dataState: DataState.NEW,
      );

      // await searchPicture(projectSeq: curProject!.value.seq!) ?? [];

      isLeftBarOpened.value = true;
      isLeftBarOpened.value = false;

      // ProjectGalleryController projectGalleryController = Get.find();
      // projectGalleryController.fetchData();
    }
  }

  onTapViewer(BuildContext context, String url) {
    // launchUrl(Uri.parse(liveTourUrl));
    Uri? uri = Uri.tryParse(url);
    if (uri != null && uri.isAbsolute) {
      showDialog(
        // barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Web3dView(
            url: url,
          );
        },
      );
    } else {
      Fluttertoast.showToast(msg: "유효하지 않은 URL입니다");
    }
    isLeftBarOpened.value = false;
  }

  Future<File> compressImage(XFile file) async {
    // 원본 이미지 로드
    final originalImage = File(file.path);
    final bytes = await originalImage.readAsBytes();

    // 이미지 디코딩 및 크기 조정
    final decodedImage = img.decodeImage(bytes);
    final resizedImage = img.copyResize(decodedImage!,
        width: 1200, height: 900); // 원하는 크기로 조정 (300x300)

    // 크기 조정된 이미지 저장
    final resizedBytes = Uint8List.fromList(img.encodeJpg(resizedImage));
    final resizedFile = File(file.path.replaceFirst('.jpg', '_resized.jpg'));
    await resizedFile.writeAsBytes(resizedBytes);
    return resizedFile;
  }

  // Future<String> savePhotoToExternal(File photo) async {
  //   // 사진 저장할 디렉토리 경로 생성
  //   final Directory? appPicturesDir = await getExternalStorageDirectory();
  //   final String rootPath =
  //       appPicturesDir!.path.split("/").sublist(0, 4).join('/');
  //   final String targetPath = join(rootPath, 'Pictures/Elim/Safety');
  //   final Directory targetDir = Directory(targetPath);

  //   // 디렉토리가 없으면 생성
  //   if (!await targetDir.exists()) {
  //     await targetDir.create(recursive: true);
  //   }

  //   // 촬영된 사진 파일 저장
  //   final String fileName = basename(photo.path); // 원본 파일 이름 가져오기
  //   final String savedFilePath = join(targetDir.path, fileName);

  //   // 파일 복사
  //   await File(photo.path).copy(savedFilePath);
  //   Fluttertoast.showToast(msg: "사진이 태블릿에 저장되었습니다.");
  //   return savedFilePath;
  // }

  Future<String> savePhotoToExternal(File photo) async {
    try {
      Directory? targetDir;
      String message = "error";

      if (Platform.isAndroid) {
        // Android: External Storage 사용
        final Directory? appPicturesDir = await getExternalStorageDirectory();
        if (appPicturesDir != null) {
          final String rootPath =
              appPicturesDir.path.split("/").sublist(0, 4).join('/');
          final String targetPath = join(rootPath, 'Pictures/Elim/Safety');
          targetDir = Directory(targetPath);
          message = "사진이 태블릿에 저장되었습니다.";
        }
      } else if (Platform.isIOS) {
        // iOS: Documents Directory 사용
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String targetPath =
            join(appDocDir.path, 'Pictures', 'Elim', 'Safety');
        targetDir = Directory(targetPath);
        message = "사진이 기기에 저장되었습니다.";
      }

      if (targetDir == null) {
        // 폴백: 임시 디렉토리 사용
        final Directory tempDir = await getTemporaryDirectory();
        targetDir = Directory(join(tempDir.path, 'Pictures', 'Elim', 'Safety'));
        message = "사진이 임시 저장되었습니다.";
      }

      // 디렉토리가 없으면 생성
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // 촬영된 사진 파일 저장
      final String fileName = basename(photo.path);
      final String savedFilePath = join(targetDir.path, fileName);

      // 파일 복사
      await File(photo.path).copy(savedFilePath);

      Fluttertoast.showToast(msg: message);
      print("✅ 사진 저장 완료: $savedFilePath");

      return savedFilePath;
    } catch (e) {
      print("❌ 사진 저장 실패: $e");

      // 오류 시 원본 경로 반환
      Fluttertoast.showToast(msg: "사진 저장에 실패했습니다. 원본 경로를 사용합니다.");
      return photo.path;
    }
  }
}
