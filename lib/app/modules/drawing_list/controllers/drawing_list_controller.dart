import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import '../../../data/models/02_drawing.dart';
import '../../../data/models/01_project.dart';
import '../../../routes/app_pages.dart';

class DrawingListController extends GetxController {
  final AppService _appService;
  Project? curProject;

  List dates = [];
  RxList<String> dong = ["전체 동"].obs;
  RxList<String> floor = ["전체 층"].obs;
  List<DropdownMenuItem> datesItem = [];
  List<DropdownMenuItem> dongItem = [];
  List<DropdownMenuItem> levelItem = [];

  bool get offlineMode => _appService.isOfflineMode.value;
  bool isLoaded = false;

  DrawingListController({required AppService appService})
      : _appService = appService;

  RxString curDate = "".obs;
  RxString curDong = "".obs;
  RxString curLevel = "".obs;

  List<Drawing> drawingList = [];
  RxList<Drawing> searchList = <Drawing>[].obs;

  getDongFloor() {
    dong = ["전체 동"].obs;
    floor = ["전체 층"].obs;
    Set<String?> tempDong = {};
    Map<String?, String?> tempFloor = {};
    for (var drawing in drawingList) {
      if (drawing.dong != "") {
        tempDong.add(drawing.dong);
      } else {
        drawing.dong = "이름없음";
        tempDong.add("이름없음");
      }
      if (tempFloor[drawing.floor] == null) {
        tempFloor[drawing.floor] = drawing.floor_name ?? "이름없음";
      }
    }
    var tempDongList = tempDong.toList();
    var tempFloorNameList = [];
    tempDongList.sort();
    var tempFloorKeys = tempFloor.keys.toList();
    tempFloorKeys.sort(
      (a, b) => int.parse(a ?? "-128").compareTo(int.parse(b ?? "-128")),
    );
    for (var i = 0; i < tempFloorKeys.length; i++) {
      tempFloorNameList.add(tempFloor[tempFloorKeys[i]]);
    }
    dong.addAll(tempDongList.map(
      (e) => e.toString(),
    ));
    floor.addAll(tempFloorNameList.map(
      (e) => e.toString(),
    ));
    // print(dong);
    // print(floor);
  }

  @override
  Future<void> onInit() async {
    curProject = _appService.curProject?.value;
    _appService.isProjectInfoPage = false;

    dates.add(curProject?.field_bgn_dt);
    List<String>? otherDates = curProject?.before_list
            ?.where(
              (element) =>
                  element["field_bgn_dt"] != null &&
                  element["field_bgn_dt"] != curProject?.field_bgn_dt,
            )
            .map(
              (e) => e["field_bgn_dt"].toString(),
            )
            .toList() ??
        [];
    dates.addAll(otherDates);
    curDate.value = (curProject?.field_bgn_dt)!;
    await EasyLoading.show();
    await fetchData();
    // datesItem = List.generate(
    //   dates.length, (index) =>
    //     DropdownMenuItem(
    //       value: dates[index],
    //       child: Text(parseDate(dates[index])),
    //     ),
    // );
    getDongFloor();
    await EasyLoading.dismiss();

    super.onInit();
  }

  String? parseDate(String? origin) {
    if (origin != null) {
      return origin.substring(0, 7);
    }
    return null;
  }

  Future fetchData() async {
    drawingList =
        await _appService.getDrawingList(projectSeq: curProject?.seq) ?? [];

    // 모든 drawingList 데이터 출력
    // for (int i = 0; i < drawingList.length; i++) {
    //   print("[$i] ${drawingList[i].toJson()}");
    // }

    searchList.value = List.from(drawingList);
    // 설비목록 가져오기
    if (offlineMode) {
      // for (Drawing drawing in drawingList) {
      //   // appService.reflectAllChangesInProject(project_seq: project.seq!);
      // }
    }
    sortDrawingList();
    isLoaded = true;
  }

  void sortDrawingList() {
    searchList.sort(
      (a, b) {
        // 1. 동명으로 먼저 정렬
        int dongResult = a.dong!.compareTo(b.dong!);
        if (dongResult != 0) {
          return dongResult;
        }

        // 2. floor가 1000이 넘는지 체크 (특수도면들)
        int aFloor = int.parse(a.floor ?? "0");
        int bFloor = int.parse(b.floor ?? "0");
        bool aIsSpecial = aFloor > 1000;
        bool bIsSpecial = bFloor > 1000;

        // 둘 다 특수도면이면 floor 큰 순서부터 (내림차순)
        if (aIsSpecial && bIsSpecial) {
          return bFloor.compareTo(aFloor);
        }

        // 한쪽만 특수도면이면 특수도면을 뒤로
        if (aIsSpecial && !bIsSpecial) return 1;
        if (!aIsSpecial && bIsSpecial) return -1;

        // 3. 둘 다 일반층일 때 층으로 정렬
        // 지상층과 지하층 구분
        bool aIsAboveGround = aFloor > 0;
        bool bIsAboveGround = bFloor > 0;
        bool aIsUnderground = aFloor < 0;
        bool bIsUnderground = bFloor < 0;

        // 지상층끼리 비교 (높은 층부터)
        if (aIsAboveGround && bIsAboveGround) {
          return bFloor.compareTo(aFloor); // 내림차순
        }

        // 지하층끼리 비교 (높은 층부터, 지하는 음수이므로 큰 값이 높은 층)
        if (aIsUnderground && bIsUnderground) {
          return bFloor.compareTo(aFloor); // 내림차순
        }

        // 지상층이 지하층보다 먼저
        if (aIsAboveGround && bIsUnderground) return -1;
        if (aIsUnderground && bIsAboveGround) return 1;

        // 기타층 (0층)들은 seq 큰 순서부터
        if (!aIsAboveGround &&
            !aIsUnderground &&
            !bIsAboveGround &&
            !bIsUnderground) {
          int aSeq = int.parse(a.seq ?? "0");
          int bSeq = int.parse(b.seq ?? "0");
          return bSeq.compareTo(aSeq); // 내림차순
        }

        // 지상층이 기타층보다 먼저
        if (aIsAboveGround && !bIsAboveGround && !bIsUnderground) return -1;
        if (!aIsAboveGround && !aIsUnderground && bIsAboveGround) return 1;

        // 지하층이 기타층보다 먼저
        if (aIsUnderground && !bIsAboveGround && !bIsUnderground) return -1;
        if (!aIsAboveGround && !aIsUnderground && bIsUnderground) return 1;

        return 0;
      },
    );
  }

  changeDate(value) async {
    curDate.value = value;
    _appService.isProjectSelected = true;
    _appService.curProject?.value = _appService.projectList
        .where(
          (element) => element.field_bgn_dt == curDate.value,
        )
        .first;
    curProject = _appService.curProject?.value;
    await fetchData();
    curDong.value = "";
    curLevel.value = "";
    getDongFloor();
  }

  selectDrawing(Drawing selectedDrawing, String drawingName) {
    _appService.projectName = curProject?.name ?? "제목 없음";
    _appService.drawingName = drawingName;
    selectedDrawing.project_seq = curProject?.seq;
    Get.toNamed(Routes.DRAWING_DETAIL, arguments: selectedDrawing);
  }

  filterDrawing() {
    searchList.clear();
    for (Drawing drawing in drawingList) {
      if (curDong.value != "" && drawing.dong != curDong.value) {
        continue;
      }
      if (curLevel.value != "") {
        String tempFloor = drawing.floor_name ?? "이름없음";
        if (tempFloor != curLevel.value) {
          continue;
        }
      }
      // debugPrint(drawing.seq);
      searchList.add(drawing);
    }
    sortDrawingList();
  }

  showInfoDialog(
      BuildContext context, Drawing selectedDrawing, String drawingName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          // shape: LinearBorder(),
          // insetPadding: EdgeInsets.zero,
          // backgroundColor:Colors.white,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.2,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "도면 정보",
                          style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Gaps.h16,
                      Text(
                        "도면명: $drawingName",
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 16,
                        ),
                      ),
                      Gaps.h8,
                      Text(
                        "표기 층: ${selectedDrawing.floor}",
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 16,
                        ),
                      ),
                      Gaps.h8,
                      Text(
                        "파일명: ${selectedDrawing.file_name}",
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gaps.h8,
                      Text(
                        "생성일: ${selectedDrawing.reg_time}",
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 16,
                        ),
                      ),
                      Gaps.h8,
                      Text(
                        "파일크기: ${selectedDrawing.file_size}",
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    copyDrawing(selectedDrawing.seq);
                    Get.back();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                        color: AppColors.c4,
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
                        "복사",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Pretendard",
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  copyDrawing(String? seq) async {
    String? result = await _appService.copyDrawing(seq: seq);
    if (result != null) {
      if (result == "OK") {
        Fluttertoast.showToast(msg: "복사에 성공했습니다.");
      } else {
        Fluttertoast.showToast(msg: result);
      }
    }
    fetchData();
  }

  goProjectInfo() {
    Get.offAllNamed(Routes.PROJECT_INFO);
  }
}
