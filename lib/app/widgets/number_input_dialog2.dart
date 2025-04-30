import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/modules/drawing_detail/controllers/drawing_detail_controller.dart';

class NumberInputDialog2 extends StatefulWidget {
  const NumberInputDialog2({super.key, required this.attribute});
  final String attribute;
  @override
  State<NumberInputDialog2> createState() => _NumberInputDialog2State();
}

class _NumberInputDialog2State extends State<NumberInputDialog2> {
  AppService appService = Get.find();
  final DrawingDetailController drawingDetailController = Get.find();
  String degree = "0";
  List<String> nums = [];

  int cursor = 0;
  double inputFieldWidth = 100;
  double inputFieldHeight = 150;

  @override
  void initState() {
    if (widget.attribute == "번호") {
      if (drawingDetailController.selectedMarker.value.no?.isNotEmpty ??
          false) {
        degree = drawingDetailController.selectedMarker.value.no!;
      } else {
        degree = "0";
      }
    } else if (widget.attribute == "개소") {
      if (appService.selectedFault.value.qty?.isNotEmpty ?? false) {
        degree = appService.selectedFault.value.qty!;
      } else {
        degree = "1";
      }
    }
    cursor = degree.length - 1;
    // print(degree);
    degree = degree.padRight(4, " ");
    // print(degree);
    for (var i = 0; i < degree.length; i++) {
      nums.add(degree.substring(i, i + 1));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: 600,
        height: 450,
        decoration: BoxDecoration(
            color: Color(0xffD9D9D9), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text("${widget.attribute}을(를) 지정해주세요.",
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => setState(() {
                      cursor = 0;
                    }),
                    child: Container(
                      height: inputFieldHeight,
                      width: inputFieldWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // // border: Border.all(color: Colors.grey),
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(10)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                              child: Text(
                            nums[0],
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 50,
                            ),
                          )),
                          Visibility(
                            visible: cursor == 0,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Divider(
                                  thickness: 4,
                                  color: AppColors.c4,
                                  indent: 8,
                                  endIndent: 8,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() {
                      cursor = 1;
                    }),
                    child: Container(
                      height: inputFieldHeight,
                      width: inputFieldWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // border: Border.all(color: Colors.grey),
                      ),
                      child: Stack(
                        children: [
                          Center(
                              child: Text(
                            nums[1],
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 50,
                            ),
                          )),
                          Visibility(
                            visible: cursor == 1,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Divider(
                                  thickness: 4,
                                  color: AppColors.c4,
                                  indent: 8,
                                  endIndent: 8,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() {
                      cursor = 2;
                    }),
                    child: Container(
                      height: inputFieldHeight,
                      width: inputFieldWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // // border: Border.all(color: Colors.grey),
                      ),
                      child: Stack(
                        children: [
                          Center(
                              child: Text(
                            nums[2],
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 50,
                            ),
                          )),
                          Visibility(
                            visible: cursor == 2,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Divider(
                                  thickness: 4,
                                  color: AppColors.c4,
                                  indent: 8,
                                  endIndent: 8,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() {
                      cursor = 3;
                    }),
                    child: Container(
                      height: inputFieldHeight,
                      width: inputFieldWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // // border: Border.all(color: Colors.grey),
                        borderRadius:
                            BorderRadius.horizontal(right: Radius.circular(10)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                              child: Text(
                            nums[3],
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 50,
                            ),
                          )),
                          Visibility(
                            visible: cursor == 3,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Divider(
                                  thickness: 4,
                                  color: AppColors.c4,
                                  indent: 8,
                                  endIndent: 8,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisExtent: 50,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                nums[cursor] = index.toString();
                                if (cursor < 3) {
                                  cursor += 1;
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                  child: Text(
                                index.toString(),
                                style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontSize: 30,
                                ),
                              )),
                            ),
                          );
                        },
                      ),
                    ),
                    Gaps.w12,
                    InkWell(
                      onTap: () {
                        setState(() {
                          nums[cursor] = " ";
                          if (cursor > 0) {
                            cursor -= 1;
                          }
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          // border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                            child: Icon(
                          Icons.backspace_outlined,
                          color: Colors.white,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // print(nums);
                if (nums[0] == " ") {
                  nums[0] = "0";
                }
                String num = int.parse(nums
                        .where(
                          (e) => e != " ",
                        )
                        .join(""))
                    .toString();
                // print(num);
                if (widget.attribute == "번호") {
                  drawingDetailController.changeNumber(num);
                  Get.back();
                  drawingDetailController.isNumberSelected.value = false;
                  drawingDetailController.isNumberSelected.value = true;
                } else if (widget.attribute == "개소") {
                  appService.selectedFault.value.qty = num;
                  Get.back();
                  appService.isFaultSelected.value = false;
                  appService.isFaultSelected.value = true;
                }
                FocusScope.of(context).unfocus();
              },
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black,
                  // border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: EdgeInsets.all(16),
                child: Center(
                    child: Text(
                  "확인",
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 16,
                      color: Colors.white),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
