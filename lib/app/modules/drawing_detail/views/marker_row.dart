import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/routes/app_pages.dart';
import 'package:safety_check/app/utils/formatter.dart';

import '../../../constant/app_color.dart';
import '../../../constant/constants.dart';
import '../../../data/models/04_fault.dart';

class FaultCount {
  int qty = 1;
  String picNo = "";
  int showIndex = 0;

  FaultCount({this.qty = 1, this.picNo = "", this.showIndex = -1});

  @override
  String toString() {
    return "Qty: $qty | PicNo: $picNo | ShowIndex: $showIndex";
  }
}

class MarkerRow extends StatefulWidget {
  const MarkerRow({
    super.key,
    this.controller,
    required this.markerNo,
    required this.faultList,
    this.onTapRow,
  });

  final GetxController? controller;
  final String markerNo;
  final List<Fault>? faultList;
  final void Function(Fault)? onTapRow;

  @override
  State<MarkerRow> createState() => _MarkerRowState();
}

class _MarkerRowState extends State<MarkerRow> {
  AppService appService = Get.find();
  List<FaultCount> faultCountList = []; //  [qty, pic_no]
  int faultCountIndex = 0;

  @override
  void initState() {
    FaultCount faultCount = FaultCount();
    for (var i = 0; i < (widget.faultList ?? []).length; i++) {
      if (widget.faultList?[i].picture_list != null &&
          widget.faultList![i].picture_list!.isNotEmpty) {
        faultCount.picNo = widget.faultList![i].picture_list!.first.no ?? "";
        faultCount.showIndex = i;
      }

      // 같은 결함이 연속으로 나오는 경우
      if (i < (widget.faultList ?? []).length - 1 &&
          widget.faultList![i]
              .isSame(widget.faultList![i + 1], isEditingFault: false)) {
        faultCount.qty += 1;
        if (widget.faultList?[i + 1].picture_list != null &&
            widget.faultList![i + 1].picture_list!.isNotEmpty) {
          faultCount.picNo = widget.faultList![i + 1].picture_list!.first.no!;
          faultCount.showIndex = i + 1;
        }
      } else {
        faultCountList.add(faultCount);
        faultCount = FaultCount();
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
      child: Row(
        children: [
          SizedBox(
            width: tableSize["seq"],
            child: Center(
                child: Text(
              widget.markerNo,
              style: TextStyle(fontFamily: "Pretendard", color: Colors.black),
            )),
          ),
          Expanded(
              child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: faultCountList.length,
            itemBuilder: (context, index) {
              appService.faultTableCurRowIndex++;
              if (index == 0) {
                faultCountIndex = 0;
              } else if (index > 0) {
                faultCountIndex += faultCountList[index - 1].qty;
              }
              int showIndex = faultCountIndex;
              if (faultCountList[index].showIndex != -1) {
                showIndex = faultCountList[index].showIndex;
              }
              Fault displayingFault = widget.faultList![showIndex];

              String faultType = makeCateString(displayingFault);
              bool isSelected = appService.isFaultSelected.value == true &&
                  appService.selectedFault.value
                      .isSame(displayingFault, isEditingFault: true);

              String qty = (faultCountList[index].qty *
                      int.parse(displayingFault.qty ?? "0"))
                  .toString();
              if (qty == "0") {
                qty = "-";
              }
              return Obx(() => InkWell(
                    onTap: () {
                      setState(() {
                        widget.onTapRow?.call(displayingFault);
                      });
                    },
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: (appService.faultTableGroupingIndexes
                                    .contains(index)) ||
                                isSelected
                            ? AppColors.c4
                            : (appService.faultTableCurRowIndex) % 2 == 0
                                ? Colors.white
                                : Colors.black.withOpacity(0.05),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                              width: tableSize["location"],
                              child: Center(
                                  child: Text(
                                displayingFault.location ?? "",
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black),
                              ))),
                          SizedBox(
                              width: tableSize["element"],
                              child: Center(
                                  child: Text(
                                displayingFault.elem ?? "",
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black),
                              ))),
                          Expanded(
                            child: Center(
                                child: Text(
                              faultType,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black),
                            )),
                          ),
                          SizedBox(
                              width: tableSize["width"],
                              child: Center(
                                  child: Text(
                                displayingFault.width == null ||
                                        displayingFault.width == ""
                                    ? "-"
                                    : displayingFault.width!,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black),
                              ))),
                          SizedBox(
                              width: tableSize["length"],
                              child: Center(
                                  child: Text(
                                displayingFault.length == null ||
                                        displayingFault.length == ""
                                    ? "-"
                                    : displayingFault.length!,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black),
                              ))),
                          SizedBox(
                              width: tableSize["qty"],
                              child: Center(
                                  child: Text(
                                qty,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black),
                              ))),
                          SizedBox(
                              width: tableSize["ing_yn"],
                              child: Center(
                                  child: Text(
                                displayingFault.ing_yn == "Y" ? "O" : "X",
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black),
                              ))),
                          SizedBox(
                              width: tableSize["status"],
                              child: Center(
                                  child: Text(
                                displayingFault.status ?? "",
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black),
                              ))),
                          SizedBox(
                              width: tableSize["note"],
                              child: Center(
                                  child: Text(
                                displayingFault.structure!,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black),
                              ))),
                          // SizedBox(
                          //     width: 160,
                          //     child: Center(
                          //         child: Text(tableInfo[index]["cause"]))),
                          InkWell(
                            onTap: () {
                              // 사진번호 클릭 시 사진 상세 화면으로 이동
                              if (faultCountList[index].picNo.isNotEmpty) {
                                // 해당 인덱스의 결함 정보 가져오기
                                int showIndex = faultCountList[index].showIndex;
                                if (showIndex >= 0 &&
                                    showIndex <
                                        (widget.faultList ?? []).length) {
                                  Fault fault = widget.faultList![showIndex];
                                  // 사진 정보 가져오기 (첫 번째 사진이 있는 경우)
                                  if (fault.picture_list != null &&
                                      fault.picture_list!.isNotEmpty) {
                                    CustomPicture picture =
                                        fault.picture_list!.first;
                                    Get.toNamed(
                                      Routes.CHECK_IMGAGE,
                                      arguments: picture,
                                    );
                                  }
                                }
                              }
                            },
                            child: SizedBox(
                                width: tableSize["pic_no"],
                                child: Center(
                                    child: Text(
                                  faultCountList[index].picNo,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black),
                                ))),
                          ),
                        ],
                      ),
                    ),
                  ));
            },
          ))
        ],
      ),
    );
  }
}
