import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/modules/drawing_detail/controllers/drawing_detail_controller.dart';

import '../data/models/03_marker.dart';

class CustomColorPicker extends StatefulWidget {
  const CustomColorPicker({super.key});

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  AppService appService = Get.find();
  DrawingDetailController drawingDetailController = Get.find();
  List<Color> colors = [
    Color(0xffff0000),
    Color(0xff0909ff),
    Colors.yellow,
    Colors.green,
  ];

  String intToHex(int colorValue) {
    // 16진수로 변환 후, 마지막 6자리 추출
    return (colorValue & 0xFFFFFF)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
  }

  @override
  void initState() {
    if (drawingDetailController.isBorderColorChanging.value) {
      colors.add(Colors.black);
    } else {
      colors.add(Colors.white);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          drawingDetailController.clrPickerOpened.value = false;
        });
      },
      child: Container(
        width: 72,
        margin: EdgeInsets.only(top: appBarHeight),
        decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(4))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: colors.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      if (!drawingDetailController
                          .isMarkerColorChanging.value) {
                        appService.selectedFault.value.color =
                            intToHex(colors[index].value);
                      } else if (drawingDetailController
                          .isBorderColorChanging.value) {
                        for (Marker marker
                            in drawingDetailController.markerList) {
                          if (marker.no ==
                              drawingDetailController.selectedMarker.value.no) {
                            marker.outline_color =
                                intToHex(colors[index].value);
                            drawingDetailController.editMarker(marker);
                          }
                        }
                      } else {
                        for (Marker marker
                            in drawingDetailController.markerList) {
                          if (marker.no ==
                              drawingDetailController.selectedMarker.value.no) {
                            marker.foreground_color =
                                intToHex(colors[index].value);
                            drawingDetailController.editMarker(marker);
                          }
                        }
                      }
                      drawingDetailController.clrPickerOpened.value = false;
                      if (drawingDetailController.isBorderColorChanging.value ||
                          drawingDetailController.isMarkerColorChanging.value) {
                        drawingDetailController.isNumberSelected.value = false;
                        drawingDetailController.isNumberSelected.value = true;
                      } else {
                        appService.isFaultSelected.value = false;
                        appService.isFaultSelected.value = true;
                      }
                    },
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                            color: colors[index],
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
