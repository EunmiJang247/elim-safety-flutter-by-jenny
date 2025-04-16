import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/models/10_elem_list.dart';
import 'package:safety_check/app/data/models/11_drawing_memo.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';
import 'package:safety_check/app/modules/drawing_detail/views/drawing_memo.dart';
import 'package:safety_check/app/modules/drawing_list/controllers/drawing_list_controller.dart';

import '../../../data/models/02_drawing.dart';
import '../../../data/models/03_marker.dart';
import '../../../data/models/04_fault.dart';
import '../../../data/models/09_appended.dart';
import '../../../data/services/app_service.dart';
import '../../../routes/app_pages.dart';
import '../views/drawing_help_dialog.dart';

class DrawingDetailController extends GetxController {
  final AppService appService;
  final LocalGalleryDataService _localGalleryDataService;
  final ImagePicker imagePicker = ImagePicker();

  late ScrollController cScrollController;
  late TextEditingController cate1Controller;
  late TextEditingController cate2Controller;
  late TextEditingController memoTextController;

  double lastScreenWidth = 0;
  double lastScreenHeight = 0;

  DrawingDetailController(
      {required AppService appService1,
      required LocalGalleryDataService localGalleryDataService})
      : appService = appService1,
        _localGalleryDataService = localGalleryDataService;

  bool get offlineMode => appService.isOfflineMode.value;

  String? drawingUrl;

  RxBool isDrawingSelected = true.obs;

  RxBool isNumberSelected = false.obs;
  RxBool isPointSelected = false.obs;
  Rx<Marker> selectedMarker = Rx(Marker(no: "1"));
  RxBool clrPickerOpened = false.obs;

  RxBool isGrouping = false.obs;
  RxBool addMemoMode = false.obs;
  Rxn<DrawingMemo> curDrawingMemo = Rxn<DrawingMemo>();
  FocusNode drawingMemoFocusNode = FocusNode();

  RxList<Marker> markerList = <Marker>[].obs;
  List<Fault> faultList = [];

  // RxMap<String, List<Fault>> tableData = <String, List<Fault>>{}.obs;
  RxMap<String, List<Fault>> tableMarkerData = <String, List<Fault>>{}.obs;
  RxMap<String, Map<int, Map<String, List<Fault>>>> tableData =
      <String, Map<int, Map<String, List<Fault>>>>{}.obs;

  RxString tempCate1 = "".obs;
  RxString tempCate2 = "".obs;

  // 번호에 결합된 그룹 (번호에 선 몇 개 이어졌는지 체크용)
  Map<String, List<Fault?>> groupsLinkedToMarker = {};
  double drawingWidth = 0;
  double drawingHeight = 0;
  double drawingX = 0;
  double drawingY = 0;
  double markerSize = 20;
  double faultSize = 8;
  double fontSize = 16;
  RxBool isMarkerColorChanging = false.obs;
  RxBool isBorderColorChanging = false.obs;
  RxBool isMovingNumOrFault = false.obs;
  Rxn<CustomPicture> memoPicture = Rxn<CustomPicture>();

  String get projectName => appService.projectName;
  String get imageDescription => appService.drawingName;
  List<ElementList>? get elements => appService.elements;

  @override
  void onInit() async {
    cScrollController = ScrollController();
    memoTextController = TextEditingController();

    // 텍스트 변경 리스너
    memoTextController.addListener(() {
      // curDrawingMemo.value?.memo = memoTextController.text;
    });

    memoPicture.value = null;

    appService.curDrawing.value = Get.arguments as Drawing;
    drawingUrl = appService.curDrawing.value.file_path;
    markerSize = double.parse(appService.curDrawing.value.marker_size ?? "20");
    await fetchData();
    if (markerList.isNotEmpty) {
      markerSize = double.parse(markerList.first.size ?? "20");
    }
    fontSize = 16 * markerSize / 32;
    faultSize = markerSize / 4;
    countFaults();
    super.onInit();
  }

  @override
  void dispose() {
    cScrollController.dispose();
    memoTextController.dispose();
    drawingMemoFocusNode.dispose();

    super.dispose();
  }

  onTapBack() {
    if (appService.isFaultSelected.value || isNumberSelected.value) {
      appService.isFaultSelected.value = false;
      isNumberSelected.value = false;
    } else {
      Get.back();
    }
  }

  refreshScreen() {
    Get.offNamed(Routes.DRAWING_DETAIL, arguments: appService.curDrawing);
  }

  Future<void> fetchData() async {
    await EasyLoading.show(maskType: EasyLoadingMaskType.clear);
    markerList.value = await appService.getMarkerList(
            drawingSeq: appService.curDrawing.value.seq) ??
        [];
    if (markerList.isNotEmpty) {
      markerList.sort(
        (a, b) => int.parse(a.no!).compareTo(int.parse(b.no!)),
      );
      selectedMarker.value = markerList.first;
    }
    faultList = [];
    for (Marker marker in markerList) {
      faultList.addAll(marker.fault_list ?? []);

      // Load pictures from local gallery for each fault
      for (Fault fault in marker.fault_list ?? []) {
        List<CustomPicture>? pictures = loadGallery(fault.fid ?? "");
        if (pictures?.isNotEmpty ?? false) {
          fault.picture_list = pictures;
        }
      }
    }
    if (faultList.isNotEmpty) {
      appService.selectedFault.value = faultList[0];
    }
    // 설비목록 가져오기
    if (offlineMode) {
      // for (Marker drawing in markerList) {
      //   // appService.reflectAllChangesInProject(project_seq: project.seq!);
      // }
    }
    countFaults();
    EasyLoading.dismiss();
  }

  void openUrl(BuildContext context, String? url) {
    appService.onTapViewer(context, url ?? "");
  }

  bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  changeNumber(String value) {
    List<Fault>? changingFault = selectedMarker.value.fault_list;
    for (Fault fault in changingFault ?? []) {
      fault.marker_no = value;
      editFault(fault);
    }
    selectedMarker.value.no = value;
    editMarker(selectedMarker.value);
    isNumberSelected.value = false;
  }

  changeMarkerSize(num? value) {
    isNumberSelected.value = false;
    markerSize = value!.toDouble();
    fontSize = 16 * markerSize / 32;
    faultSize = markerSize / 4;
    editMarker(selectedMarker.value);
    isNumberSelected.value = true;
    DrawingListController drawingListController = Get.find();
    drawingListController.drawingList.map(
      (e) => e.marker_size = value.toString(),
    );
  }

  // 번호별 결함 수 확인
  // 번호별 결함 수 확인 메서드 수정
  void countFaults() {
    String markerNo = "";
    tableMarkerData.value = {};
    appService.displayingFid = {};
    tableData.clear();

    // 동이름과 층별로 마커 그룹화
    Map<String, Map<int, List<Marker>>> markersByDongAndFloor = {};

    for (Marker marker in markerList) {
      String dong = marker.dong ?? "기타";
      int floor = int.parse(marker.floor ?? "0");

      // 동 데이터 초기화
      if (!markersByDongAndFloor.containsKey(dong)) {
        markersByDongAndFloor[dong] = {};
      }

      // 층 데이터 초기화
      if (!markersByDongAndFloor[dong]!.containsKey(floor)) {
        markersByDongAndFloor[dong]![floor] = [];
      }

      // 해당 동과 층에 마커 추가
      markersByDongAndFloor[dong]![floor]!.add(marker);
    }

    // 동이름 키를 오름차순으로 정렬
    List<String> sortedDongNames = markersByDongAndFloor.keys.toList()..sort();

    // 정렬된 동이름 순서대로 처리
    for (var dong in sortedDongNames) {
      var floorMap = markersByDongAndFloor[dong];

      tableData[dong] = {};

      // 층 이름 내림차순으로 정렬
      List<int> sortedFloorNames = floorMap!.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      // 정렬된 층 순서대로 처리
      for (var floor in sortedFloorNames) {
        List<Marker> markers = floorMap[floor]!;

        // 층별 데이터 초기화
        tableData[dong]![floor] = {};

        // 마커별 결함 데이터 처리
        for (Marker marker in markers) {
          markerNo = marker.no ?? "";
          List<Fault> markerFaults = marker.fault_list ?? [];

          // 결함 처리 (기존 로직 유지)
          for (Fault fault in markerFaults) {
            // 결함 전체 목록에 추가
            if (!faultList.contains(fault)) {
              faultList.add(fault);
            }

            // 그룹 파울트 ID 처리
            if (appService.displayingFid[fault.group_fid] == null) {
              appService.displayingFid[fault.group_fid!] = fault.fid!;
            }

            if (!tableData[dong]![floor]!.containsKey(markerNo)) {
              tableData[dong]![floor]![markerNo] = [];
            }
            tableData[dong]![floor]![markerNo]!.add(fault);

            // 마커에 연결된 그룹 처리
            if (groupsLinkedToMarker[markerNo] == null) {
              groupsLinkedToMarker[markerNo] = [fault];
            } else if (!groupsLinkedToMarker[markerNo]!.contains(fault)) {
              groupsLinkedToMarker[markerNo]!.add(fault);
            }
          }
        }
      }
    }
  }

  Future<void> onLongPress(List<String> position, String mfGap) async {
    String? mid = await addMarker(position, mfGap);
    await addFault(position, mid);
  }

  Future<String?> sortMarker() async {
    String drawingSeq = appService.curDrawing.value.seq!;
    String? result = await appService.sortMarker(drawingSeq: drawingSeq);
    fetchData();
    countFaults();
    selectedMarker.value = markerList.first;
    appService.isFaultSelected.value = true;
    appService.isFaultSelected.value = false;
    return result;
  }

  // 마커 추가
  Future<String?> addMarker(List<String> position, String mfGap) async {
    var mid = appService.createId();
    Marker newMarker = Marker(
        drawing_seq: appService.curDrawing.value.seq,
        x: position[0],
        y: (double.parse(position[1]) - double.parse(mfGap)).toString(),
        mid: mid);
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }
    Map? result = await appService.submitMarker(
        isNew: true, marker: newMarker, lastFaultSeq: lastFaultSeq);
    if (result != null) {
      Marker resultMarker = result["marker"];
      resultMarker.fault_list = [];
      resultMarker.fault_cnt = 0;
      markerList.add(resultMarker);
      if (result["appended"] != null) {
        applyChanges(result["appended"]);
      }
      countFaults();
      return result["marker"].mid ?? appService.createId();
    } else {
      Fluttertoast.showToast(msg: "번호 추가에 실패하였습니다.");
      countFaults();
      return null;
    }
  }

  Future<String?> editMarker(Marker marker) async {
    Marker newMarker = marker;
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }
    Map? result = await appService.submitMarker(
        isNew: false,
        marker: newMarker,
        lastFaultSeq: lastFaultSeq,
        markerSize: markerSize.toString());
    if (result != null) {
      if (result["appended"] != null) {
        applyChanges(result["appended"]);
      }
      countFaults();
      return result["marker"].mid ?? appService.createId();
    } else {
      Fluttertoast.showToast(msg: "번호 추가에 실패하였습니다.");
      countFaults();
      return null;
    }
  }

  overrideMarker(BuildContext context, Marker fromM, Marker toM) async {
    Appended? appended;
    if (fromM.seq != null && toM.seq != null) {
      appended = await appService.overrideMarker(
          fromSeq: fromM.seq!,
          toSeq: toM.seq!,
          lastFaultSeq: faultList.last.seq);
      // 덮어쓰기 매커니즘 (fromMarker의 모든 결함을 toMarker의 첫번째 결함의 내용으로 바꾸고 옮긴후 삭제)
      Fault? objFault = fromM.fault_list?.first;
      if (objFault != null) {
        for (Fault fault in toM.fault_list ?? []) {
          Fault newFault = objFault.copyWoPic();
          fault.user_seq = newFault.user_seq;
          fault.location = newFault.location;
          fault.elem_seq = newFault.elem_seq;
          fault.cate1_seq = newFault.cate1_seq;
          fault.width = newFault.width;
          fault.length = newFault.length;
          fault.qty = newFault.qty;
          fault.structure = newFault.structure;
          fault.status = newFault.status;
          fault.deleted = newFault.deleted;
          fault.cause = newFault.cause;
          fault.reg_time = newFault.reg_time;
          fault.update_time = newFault.update_time;
          fault.user_name = newFault.user_name;
          fault.elem = newFault.elem;
          // fault.marker_no = newFault.marker_no;
          fault.drawing_seq = newFault.drawing_seq;
          fault.project_seq = newFault.project_seq;
          fault.dong = newFault.dong;
          fault.floor = newFault.floor;
          fault.cate1_name = newFault.cate1_name;
          fault.cate2 = newFault.cate2;
          fault.cate2_name = newFault.cate2_name;
          fault.pic_no = newFault.pic_no;
        }
      }
      // toM.no = fromM.no;
      isNumberSelected.value = true;
      isNumberSelected.value = false;
    }
    if (appended != null) {
      applyChanges(appended);
    }
    countFaults();
    FocusScope.of(context).unfocus();
  }

  // 마커 합치기
  mergeMarker(BuildContext context, Marker fromM, Marker toM) async {
    Map? result;
    if (fromM.seq != null && toM.seq != null) {
      result = await appService.mergeMarker(
          fromSeq: fromM.seq!,
          toSeq: toM.seq!,
          lastFaultSeq: faultList.last.seq);
      // 합치기 매커니즘 (fromMarker의 모든 결함을 toMarker로 옮기고 삭제)
      for (Fault fault in fromM.fault_list ?? []) {
        fault.mid = toM.mid;
        fault.marker_seq = toM.seq;
        fault.marker_no = toM.no;
        toM.fault_list?.add(fault);
      }
      markerList.remove(fromM);
      selectedMarker.value = markerList.first;
      isNumberSelected.value = true;
      isNumberSelected.value = false;
    }
    if (result?["appended"] != null) {
      applyChanges(result?["appended"]);
    }
    countFaults();
    FocusScope.of(context).unfocus();
  }

  Future<void> delMarker() async {
    isNumberSelected.value = false;
    String markerSeq = selectedMarker.value.seq ?? "1";
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }
    Appended? appended = await appService.deleteMarker(
        markerSeq: markerSeq, lastFaultSeq: lastFaultSeq);

    if (appended != null) {
      applyChanges(appended);
    }

    markerList.remove(selectedMarker.value);

    if (markerList.isNotEmpty) {
      selectedMarker.value = markerList.first;
    } else {
      selectedMarker.value = Marker();
    }
    countFaults();
  }

  // 마커 분리
  Future<void> detachMarker() async {
    Marker originMarker = selectedMarker.value;
    Map<String, List<Fault>> groupedByFid = {};
    for (Fault fault in originMarker.fault_list ?? []) {
      String group_fid = fault.group_fid ?? "";
      if (!groupedByFid.containsKey(group_fid)) {
        groupedByFid[group_fid] = [];
      }
      groupedByFid[group_fid]!.add(fault);
    }
    if (groupedByFid.length == 1) {
      Fluttertoast.showToast(msg: "결함이 한 종류일 땐 분리할 수 없습니다.");
      return;
    }

    int idx = 0;
    for (String groupFid in groupedByFid.keys) {
      if (idx == 0) {
        idx++;
        continue;
      }
      List<Fault> faults = groupedByFid[groupFid]!;
      String newX = (double.tryParse(faults[0].x ?? "0")?.toStringAsFixed(5)) ??
          "0.00000";
      String newY = (((double.tryParse(faults[0].y ?? "0") ?? 0) - 0.05)
              .toStringAsFixed(5)) ??
          "0.00000";
      Marker newMarker = Marker(
        drawing_seq: originMarker.drawing_seq,
        x: newX,
        y: newY,
        mid: appService.createId(),
      );
      String? lastFaultSeq;
      if (faultList.isNotEmpty) {
        lastFaultSeq = faultList.last.seq;
      }

      Map? result = await appService.submitMarker(
          isNew: true, marker: newMarker, lastFaultSeq: lastFaultSeq);
      if (result != null) {
        Marker resultMarker = result["marker"];
        resultMarker.fault_list = [];
        resultMarker.fault_cnt = 0;
        markerList.add(resultMarker);
        if (result["appended"] != null) {
          applyChanges(result["appended"]);
        }
        for (Fault fault in faults) {
          originMarker.fault_list?.remove(fault);
          fault.mid = resultMarker.mid;
          fault.marker_seq = resultMarker.seq;
          fault.marker_no = resultMarker.no;

          Map? faultResult = await appService.submitFault(
            isNew: false,
            fault: fault,
            mid: resultMarker.mid,
            lastFaultSeq: lastFaultSeq,
          );

          if (faultResult != null) {
            resultMarker.fault_list?.add(fault);
            resultMarker.fault_cnt = resultMarker.fault_list?.length ?? 0;

            if (faultResult["fault"] != null) {
              if (fault.cause != faultResult["fault"].cause) {
                fault.cause = faultResult["fault"].cause;
                appService.isFaultSelected.value = false;
                appService.isFaultSelected.value = true;
              }
            }
            if (faultResult["appended"] != null) {
              applyChanges(faultResult["appended"]);
            }
          }
          countFaults();
        }
      } else {
        Fluttertoast.showToast(msg: "번호 추가에 실패하였습니다.");
        countFaults();
      }
    }
  }

  // 테이블 결함 추가
  Future<void> addFault(List<String> position, String? mid) async {
    Fault newFault = Fault(qty: "1");
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      Fault lastFault = faultList.last;
      newFault = lastFault.copyWoPic();
      lastFaultSeq = faultList.last.seq;
    }
    newFault.x = position[0];
    newFault.y = position[1];
    newFault.fid = appService.createId();
    newFault.group_fid = newFault.fid;
    Map? result = await appService.submitFault(
        isNew: true, fault: newFault, mid: mid, lastFaultSeq: lastFaultSeq);
    if (result != null) {
      if (result["marker"] != null) {
        Marker newMarker = result["marker"];
        newMarker.fault_list = [result["fault"]];
        newMarker.fault_cnt = 1;
        markerList.add(newMarker);
      }
      if (result["fault"] != null) {
        newFault = result["fault"];
        faultList.add(newFault);
        for (Marker marker in markerList) {
          if (marker.mid == newFault.mid) {
            marker.fault_list?.add(newFault);
            marker.fault_cnt = marker.fault_list?.length ?? 0;
          }
        }
      }
      if (result["appended"] != null) {
        applyChanges(result["appended"]);
      }
      onTapRow(newFault);
    }
    countFaults();
  }

  // 테이블 결함 수정
  Future<void> editFault(Fault fault) async {
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }

    // 결함속 사진 정보 수정
    if (fault.picture_list?.isNotEmpty ?? false) {
      for (CustomPicture pic in fault.picture_list ?? []) {
        appService.changeFaultPictureInfo(pic.pid!, fault);
      }
    }
    Map? result = await appService.submitFault(
        isNew: false, fault: fault, mid: fault.mid, lastFaultSeq: lastFaultSeq);
    if (result != null) {
      if (result["fault"] != null) {
        if (fault.cause != result["fault"].cause) {
          fault.cause = result["fault"].cause;
          appService.isFaultSelected.value = false;
          appService.isFaultSelected.value = true;
        }
      }
      if (result["appended"] != null) {
        applyChanges(result["appended"]);
      }
    }
    countFaults();
  }

  // 테이블 결함 삭제
  Future<void> delFault() async {
    appService.isFaultSelected.value = false;
    Fault objFault = appService.selectedFault.value;
    String faultSeq = objFault.seq!;
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }

    // 결함삭제 API 호출
    Appended? appended = await appService.deleteFault(
        faultSeq: faultSeq, lastFaultSeq: lastFaultSeq);
    if (appended != null) {
      applyChanges(appended);
    }

    List<Marker> deletingMarker = [];

    // 결함 목록에서 제거
    faultList.removeWhere((Fault f) => f.seq == faultSeq);

    // 결함이 없는 마커 찾기 (삭제할 마커)
    for (Marker marker in markerList) {
      marker.fault_list!.remove(objFault);
      marker.fault_cnt = marker.fault_list!.length;
      if (marker.fault_list!
          .where(
            (element) => element.mid == marker.mid,
          )
          .isEmpty) {
        deletingMarker.add(marker);
      }
    }

    // 결함이 없는 마커 삭제
    for (Marker marker in deletingMarker) {
      selectedMarker.value = marker;
      delMarker();
    }

    appService.selectedFault.value = faultList.last;

    countFaults();
    appService.isFaultSelected.value = true;
    appService.isFaultSelected.value = false;
  }

  Future<void> cloneFault() async {
    Fault newFault = appService.selectedFault.value.copyWoPic();
    newFault.fid = appService.createId();
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }
    Map? result = await appService.submitFault(
        isNew: true,
        fault: newFault,
        mid: selectedMarker.value.mid,
        lastFaultSeq: lastFaultSeq);
    if (result != null) {
      if (result["marker"] != null) {
        Marker newMarker = result["marker"];
        newMarker.fault_list = [result["fault"]];
        newMarker.fault_cnt = 1;
        markerList.add(newMarker);
      }
      if (result["fault"] != null) {
        newFault = result["fault"];
        faultList.add(newFault);
        for (Marker marker in markerList) {
          if (marker.mid == newFault.mid) {
            marker.fault_list?.add(newFault);
            appService.selectedFault.value = marker.fault_list!.last;
            marker.fault_cnt = marker.fault_list?.length ?? 0;
          }
        }
      }
      if (result["appended"] != null) {
        applyChanges(result["appended"]);
      }
      onTapRow(newFault);
    }
    countFaults();
    appService.isFaultSelected.value = false;
    appService.isFaultSelected.value = true;
  }

  void clearFault() {
    appService.selectedFault.value.location = null;
    appService.selectedFault.value.elem = null;
    appService.selectedFault.value.cate1_seq = null;
    appService.selectedFault.value.cate2 = null;
    appService.selectedFault.value.width = null;
    appService.selectedFault.value.length = null;
    appService.selectedFault.value.qty = "1";
    appService.selectedFault.value.structure = "구조";
    appService.selectedFault.value.ing_yn = "Y";
    appService.selectedFault.value.status = null;
    appService.selectedFault.value.cause = null;
  }

  // 그룹화 버튼
  void onTapGroupButton(bool cancel) {
    if (!cancel && isGrouping.value) {
      if (appService.faultTableGroupingIndexes.isNotEmpty) {
        int groupSeq = int.parse(
            faultList[appService.faultTableGroupingIndexes.first].seq!);
        for (var index in appService.faultTableGroupingIndexes) {
          faultList[index].seq = groupSeq.toString();
          faultList.sort(
            (a, b) => int.parse(a.seq!).compareTo(int.parse(b.seq!)),
          );
          countFaults();
        }
      }
    }
    appService.faultTableGroupingIndexes.clear();
    isGrouping.value = !isGrouping.value;
  }

  // 테이블 결함 선택
  void onTapRow(Fault fault) {
    if (isGrouping.value) {
      // if (groupingIndexes.contains(index)){
      //   groupingIndexes.remove(index);
      // } else{
      //   groupingIndexes.add(index);
      // }
    } else {
      tempCate1.value = "";
      tempCate2.value = "";
      var tempMarkerList = markerList.where(
        (p0) => p0.mid == fault.mid,
      );
      if (tempMarkerList.isNotEmpty) {
        selectedMarker.value = tempMarkerList.first;
      } else {
        selectedMarker.value = markerList.first;
      }
      appService.selectedFault.value = fault;
      appService.isFaultSelected.value = true;
    }
  }

  // void scrollToFocusedField(FocusNode focusNode) {
  //   Future.delayed(Duration(milliseconds: 300), () {
  //     if (focusNode.context == null || focusNode.context!.findRenderObject() == null) {
  //       print('FocusNode context or RenderObject is null');
  //       return;
  //     }
  //
  //     final renderBox = focusNode.context!.findRenderObject() as RenderBox;
  //     final position = renderBox.localToGlobal(Offset.zero).dy;
  //
  //     cScrollController.animateTo(
  //       position - 100,
  //       duration: Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //     );
  //   });
  // }

  void closeFaultDrawer(context) {
    FocusScope.of(context).unfocus();
    clrPickerOpened.value = false;
    tempCate1.value = "";
    tempCate2.value = "";
    appService.isFaultSelected.value = false;
  }

  void closeNumberDrawer(context) {
    FocusScope.of(context).unfocus();
    clrPickerOpened.value = false;
    tempCate1.value = "";
    tempCate2.value = "";
    isNumberSelected.value = false;
    isPointSelected.value = false;
  }

  void checkImage(CustomPicture picture) {
    Get.toNamed(Routes.CHECK_IMGAGE, arguments: picture);
  }

  void onClrBtnClicked(bool isMarker, bool isBorder) {
    isMarkerColorChanging.value = isMarker;
    isBorderColorChanging.value = isBorder;
    clrPickerOpened.value = !clrPickerOpened.value;
  }

  void showHelpDialog(context) {
    showDialog(
      context: context,
      builder: (context) => drawingHelpDialog(context),
    );
  }

  void applyChanges(Appended appended) {
    List<Marker> newMarkers = appended.markerList ?? [];
    List<Fault> newFaults = appended.faultList ?? [];

    // 마커가 기존에 있는건지 확인 후 변경 또는 추가
    for (Marker marker in newMarkers) {
      Marker? changed = markerList.firstWhereOrNull(
        (p0) => p0.mid == marker.mid,
      );
      if (changed != null) {
        changed = marker;
      } else {
        marker.fault_list = [];
        marker.fault_cnt = 0;
        markerList.add(marker);
      }
    }
    // 마커 리스트 돌면서 해당 번호를 가진 결함 추가
    for (Fault fault in newFaults) {
      for (Marker marker in markerList) {
        if (marker.no == fault.marker_no) {
          marker.fault_list!.add(fault);
          if (marker.fault_cnt == null) {
            marker.fault_cnt = 1;
          } else {
            marker.fault_cnt = marker.fault_list?.length ?? 0;
          }
        }
      }
    }
    countFaults();
  }

  Future<CustomPicture?> takePicture(Fault? fault) async {
    XFile? xFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: imageMaxWidth,
    );
    if (xFile != null) {
      // File file = await appService.compressImage(xImage);
      String savedFilePath =
          await appService.savePhotoToExternal(File(xFile.path));

      CustomPicture newPicture = appService.makeNewPicture(
        pid: appService.createId(),
        projectSeq: appService.curProject!.value.seq!,
        filePath: savedFilePath,
        thumb: savedFilePath,
        kind: "결함",
        fid: fault?.fid,
        dong: fault?.dong,
        floorName: appService.curDrawing.value.floor_name,
        location: fault?.location,
        cate1Seq: fault?.cate1_seq,
        cate2Seq: fault?.cate2?.split(", "),
        width: fault?.width,
        length: fault?.length,
        dataState: DataState.NEW,
      );
      appService.isFaultSelected.refresh();
      appService.isLeftBarOpened.refresh();
      appService.curProject?.refresh();
      _localGalleryDataService.fetchGalleryPictures();

      return newPicture;
    }
    return null;
  }

  Future<List<CustomPicture>?> takeFromGallery(Fault? fault) async {
    List<XFile> xImages = await imagePicker.pickMultiImage();
    List<CustomPicture>? result = [];
    for (XFile xFile in xImages) {
      File file = await appService.compressImage(xFile);

      CustomPicture newPicture = appService.makeNewPicture(
        pid: appService.createId(),
        projectSeq: appService.curProject!.value.seq!,
        filePath: file.path,
        thumb: file.path,
        kind: "결함",
        fid: fault?.fid,
        dong: fault?.dong,
        floorName: appService.curDrawing.value.floor_name,
        location: fault?.location,
        cate1Seq: fault?.cate1_seq,
        cate2Seq: fault?.cate2?.split(", "),
        width: fault?.width,
        length: fault?.length,
        dataState: DataState.NEW,
      );
      result.add(newPicture);
      appService.isFaultSelected.value = false;
      appService.isFaultSelected.value = true;
    }
    return result;
  }

  List<CustomPicture>? loadGallery(String fid) {
    return _localGalleryDataService.loadGallery(fid);
  }

  memoView(String memoSeq) {
    // 메모 선택
    curDrawingMemo.value = appService.curDrawing.value.memo_list.firstWhere(
      (element) => element.seq == memoSeq,
    );

    if (curDrawingMemo.value != null) {
      // 사진 선택
      memoPicture.value =
          _localGalleryDataService.getPicture(curDrawingMemo.value!.pid ?? "");

      memoTextController.text = curDrawingMemo.value!.memo ?? "";

      Get.dialog(
        GestureDetector(
          onTap: () {
            // 바깥 영역 클릭 시 포커스만 제거
            FocusScope.of(Get.context!).unfocus();
          },
          child: Stack(
            children: [
              // 바깥 영역을 위한 투명한 Positioned.fill
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              // 실제 다이얼로그
              DrawingMemoView(),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  // 메모 사진 촬영
  takeMemoPicture() async {
    XFile? xFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: imageMaxWidth,
    );
    if (xFile != null) {
      // File file = await appService.compressImage(xImage);
      String savedFilePath =
          await appService.savePhotoToExternal(File(xFile.path));

      memoPicture.value = appService.makeNewPicture(
        pid: appService.createId(),
        projectSeq: appService.curProject!.value.seq!,
        filePath: savedFilePath,
        thumb: xFile.path,
        kind: "기타",
        dong: appService.curDrawing.value.dong,
        floorName: appService.curDrawing.value.floor_name,
        dataState: DataState.NEW,
      );
      curDrawingMemo.value!.pid = memoPicture.value!.pid;

      appService.isLeftBarOpened.refresh();
      _localGalleryDataService.fetchGalleryPictures();
    }
  }

  // 메모 저장
  submitDrawingMemo() {
    if (curDrawingMemo.value != null) {
      curDrawingMemo.value!.memo = memoTextController.text;
      appService.submitDrawingMemo(curDrawingMemo.value!);
      drawingMemoFocusNode.unfocus();
    }
  }

  // 메모 삭제
  deleteMemo() {
    if (curDrawingMemo.value != null) {
      // 도면 메모 목록에서 삭제
      appService.curDrawing.value.memo_list.remove(curDrawingMemo.value);

      appService.deleteDrawingMemo(curDrawingMemo.value!.seq!);
      Get.back();
    }
  }

  // 메모 사진 삭제
  deleteMemoPicture() {
    // 사진 삭제
    if (memoPicture.value != null) {
      _localGalleryDataService.changePictureState(
        pid: memoPicture.value!.pid!,
        state: DataState.DELETED,
      );
      memoPicture.value!.state = DataState.DELETED.index;
      curDrawingMemo.value!.pid = null;
    }

    memoPicture.value = null;
  }

  // 메모 사진 보기
  memoPictureView() {
    if (memoPicture.value != null) {
      Get.toNamed(Routes.CHECK_IMGAGE, arguments: memoPicture.value);
    }
  }

  // 메모 추가
  makeNewDrawingMemo(String x, y) async {
    DrawingMemo newMemo = DrawingMemo(
      seq: "",
      drawing_seq: appService.curDrawing.value.seq,
      pid: "",
      memo: "",
      x: x,
      y: y,
    );

    curDrawingMemo.value = await appService.submitDrawingMemo(newMemo);
    if (curDrawingMemo.value != null) {
      appService.curDrawing.value.memo_list.add(curDrawingMemo.value!);
      addMemoMode.value = false;
      memoView(curDrawingMemo.value!.seq!);
    }
  }

  // 메모 닫기
  closeDrawingMemo() {
    // addMemoMode.value = false;
    // memoTextController.text = curDrawingMemo.value?.memo ?? "";
    curDrawingMemo.value = null;
    // memoPicture.value = null;
    Get.back();
  }
}
