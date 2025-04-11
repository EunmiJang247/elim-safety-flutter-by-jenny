import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/data/models/04_fault.dart';
import 'package:safety_check/app/data/models/11_drawing_memo.dart';
import 'package:safety_check/app/modules/drawing_detail/helpers/drawing_helpers.dart';
import 'package:safety_check/app/utils/line_painter.dart';
import 'package:safety_check/app/widgets/drawing_memo_widget.dart';
import 'package:safety_check/app/widgets/help_button_widget.dart';
import 'package:safety_check/app/widgets/two_button_dialog.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../../../constant/constants.dart';
import '../../../data/models/03_marker.dart';
import '../controllers/drawing_detail_controller.dart';

class DrawingView extends StatefulWidget {
  const DrawingView({super.key});

  @override
  State<DrawingView> createState() => _DrawingViewState();
}

class _DrawingViewState extends State<DrawingView> {
  DrawingDetailController drawingDetailController = Get.find();
  TransformationController transformationController =
      TransformationController();
  GlobalKey drawingKey = GlobalKey();
  Image image = Image.network("");
  late ImageStream imageStream;
  late ImageStreamListener imageStreamListener;
  bool isLoaded = false;

  List<Widget> lines = [];
  Offset topLeftOffset = Offset.zero;
  Map<String, String> bfMarkerPosition = {};
  Map<String, String> bfFaultPosition = {};
  double maxScale = 10;
  double positionWeight = 0;
  double currentScale = 1;
  double scaleStd = 1.7;
  double opac = 1;

  double verticalPadding = 60;

  double fixRange = 5;
  double touchRange = 5;
  double touchWeightX = 0;
  double touchWeightY = 0;

  double faultSize = 9;
  bool markerSnapped = false;

  final Map<String, Map<String, double>> _positionCache = {};
  final Map<String, bool> _visibilityCache = {};

  Offset? _lastMovePosition;

  // 캐시 정리 메서드 (dispose나 화면 크기 변경 시 호출)
  void clearPositionCache() {
    _positionCache.clear();
    _visibilityCache.clear();
  }

  // 도면 크기, 초기 좌표 가져오기
  void getDrawingPhysicalInfo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        Duration(milliseconds: 500),
        () {
          final RenderBox renderBox =
              drawingKey.currentContext!.findRenderObject() as RenderBox;
          final Size size = renderBox.size;
          final Offset position = renderBox.localToGlobal(Offset.zero);
          drawingDetailController.drawingWidth = size.width;
          drawingDetailController.drawingHeight = size.height;
          drawingDetailController.drawingX = position.dx - leftBarWidth;
          drawingDetailController.drawingY = position.dy - appBarHeight;
          drawingDetailController.isDrawingSelected.value = false;
          drawingDetailController.isDrawingSelected.value = true;

          // 도면 크기 정보 업데이트 시 모든 캐시 초기화
          PerformanceHelpers.clearCoordinateCache();

          setState(() {
            isLoaded = true;
          });
        },
      );
    });
  }

  // 기기의 값을 디비에 맞게 변경
  List<String> convertDVtoDB({double? x, double? y}) {
    List<String> result = [];
    if (x != null) {
      result.add((x / drawingDetailController.drawingWidth).toString());
    }
    if (y != null) {
      result.add((y / drawingDetailController.drawingHeight).toString());
    }
    return result;
  }

  // 디비의 값을 기기에 맞게 변경
  Offset convertDBtoDV({String? x, String? y}) {
    // double rx = 0;
    // double ry = 0;
    // if (x != null) {
    //   rx = double.parse(x);
    // }
    // if (y != null) {
    //   ry = double.parse(y);
    // }
    // return Offset(drawingDetailController.drawingWidth * rx,
    //     drawingDetailController.drawingHeight * ry);

    bool isMoving = drawingDetailController.isMovingNumOrFault.value;

    // 성능 헬퍼 사용
    return PerformanceHelpers.convertDBtoDV(
        x,
        y,
        drawingDetailController.drawingWidth,
        drawingDetailController.drawingHeight,
        useCache: !isMoving // 이동 중이면 캐시 사용 안 함
        );
  }

  void focusOnSpot(GlobalKey key, Offset targetPosition) {
    Offset? globalPosition;
    // 현재 확대/축소 상태의 비율을 가져옴
    final scale = transformationController.value.getMaxScaleOnAxis();

    // RenderBox를 사용하여 localPosition을 globalPosition으로 변환
    // key를 통해 위젯의 화면상 위치 추출
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    globalPosition = renderBox.localToGlobal(Offset.zero);

    final screenCenter = Offset(250, globalPosition.dy - appBarHeight);

    // 확대된 좌표 기준으로 대상 위치 조정
    final adjustedTarget = targetPosition * scale;

    // 화면 중앙에서 확대된 대상 위치로의 이동 거리 계산
    final translation = screenCenter - adjustedTarget;

    // 변환 행렬에 이동 설정 적용 (확대 상태 유지)
    transformationController.value = Matrix4.identity()
      ..translate(translation.dx, translation.dy)
      ..scale(scale);
  }

  bool areMarkersOverlapping(Marker marker1, Marker marker2) {
    Offset m1P = convertDBtoDV(x: marker1.x, y: marker1.y);
    Offset m2P = convertDBtoDV(x: marker2.x, y: marker2.y);

    // 두 마커의 중심 간 거리 계산
    double distance = (m1P - m2P).distance;

    // 두 마커의 반지름을 더한 값과 거리 비교
    return distance < drawingDetailController.markerSize;
  }

  @override
  void initState() {
    transformationController.addListener(updateInfos);
    super.initState();

    image = Image.network(
      key: drawingKey,
      drawingDetailController.drawingUrl ?? "",
    );
    imageStream = image.image.resolve(ImageConfiguration());

    imageStreamListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!isLoaded) {
          getDrawingPhysicalInfo();
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        // 이미지 로딩 에러 처리
        print("이미지 로딩 에러: $exception");
      },
    );
    imageStream.addListener(imageStreamListener);
  }

  updateInfos() {
    double previousScale = currentScale;

    // 상태 관련 값 한 번에 업데이트
    currentScale = transformationController.value.getMaxScaleOnAxis();
    positionWeight =
        (drawingDetailController.markerSize * 0.5) * (1 - 1 / currentScale);

    final vector.Vector3 translation =
        transformationController.value.getTranslation();
    final newTopLeftOffset = Offset(
        (-translation.x) / currentScale, (-translation.y) / currentScale);

    // 실제 변경 있을 때만 setState 호출
    if (currentScale != previousScale || topLeftOffset != newTopLeftOffset) {
      setState(() {
        topLeftOffset = newTopLeftOffset;
        // 다른 필요한 상태 업데이트
      });
    }

    // 확대/축소 비율이 크게 변경될 때 캐시 초기화
    if (previousScale != currentScale &&
        (previousScale / currentScale > 1.2 ||
            previousScale / currentScale < 0.8)) {
      PerformanceHelpers.clearCoordinateCache();
      clearPositionCache(); // 위치 캐시도 함께 초기화
      _visibilityCache.clear(); // 가시성 캐시도 초기화
    }
  }

  // updateScale() {
  //   currentScale = transformationController.value.getMaxScaleOnAxis();
  //   positionWeight =
  //       (drawingDetailController.markerSize * 0.5) * (1 - 1 / currentScale);
  // }

  // updateTopLeftCoordinate() {
  //   // 행렬에서 이동 값을 추출하여 현재 보이는 화면의 왼쪽 위 좌표 업데이트
  //   final vector.Vector3 translation =
  //       transformationController.value.getTranslation();

  //   topLeftOffset = Offset(
  //       (-translation.x) / currentScale, (-translation.y) / currentScale);
  // }

  @override
  void dispose() {
    // 캐시 정리
    PerformanceHelpers.clearCoordinateCache();
    _positionCache.clear();
    _colorCache.clear();
    _visibilityCache.clear();

    transformationController.removeListener(updateInfos);
    transformationController.dispose();
    imageStream.removeListener(imageStreamListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 디바이스 회전 또는 화면 크기 변경 감지
    final currentSize = MediaQuery.of(context).size;

    // 화면 크기 변경 시 캐시 초기화
    if (currentSize.width != drawingDetailController.lastScreenWidth ||
        currentSize.height != drawingDetailController.lastScreenHeight) {
      // 모든 캐시 초기화
      PerformanceHelpers.clearCoordinateCache();
      clearPositionCache();
      _visibilityCache.clear();

      // 새 화면 크기 저장
      drawingDetailController.lastScreenWidth = currentSize.width;
      drawingDetailController.lastScreenHeight = currentSize.height;
    }

    return RepaintBoundary(
      child: Container(
        height: MediaQuery.of(context).size.height - appBarHeight,
        width: MediaQuery.of(context).size.width - leftBarWidth,
        color: Colors.black,
        child: Stack(
          children: [
            Obx(() => InteractiveViewer(
                  transformationController: transformationController,
                  maxScale: maxScale,
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                        children: <Widget>[
                              GestureDetector(
                                onTapDown: (details) {
                                  if (drawingDetailController
                                      .addMemoMode.value) {
                                    Offset localPosition =
                                        details.localPosition;
                                    List<String> newPosition = convertDVtoDB(
                                        x: localPosition.dx,
                                        y: localPosition.dy - verticalPadding);

                                    drawingDetailController.makeNewDrawingMemo(
                                      newPosition[0],
                                      newPosition[1],
                                    );
                                  }
                                },
                                onLongPressStart: (details) {
                                  if (currentScale >= scaleStd) {
                                    Offset localPosition =
                                        details.localPosition;
                                    // print(localPosition);
                                    List<String> newPosition = convertDVtoDB(
                                        x: localPosition.dx,
                                        y: localPosition.dy - verticalPadding);
                                    String mfGap = convertDVtoDB(
                                            y: drawingDetailController
                                                    .markerSize *
                                                1.2)
                                        .first;
                                    drawingDetailController.onLongPress(
                                        newPosition, mfGap);
                                  }
                                },
                                onDoubleTap: () => setState(() {
                                  currentScale = 1;
                                  transformationController.value =
                                      Matrix4.identity();
                                }),
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: verticalPadding),
                                    child: image
                                    // Photo(
                                    //   imageUrl: drawingDetailController.drawingUrl,
                                    //   boxFit: BoxFit.cover,
                                    // )
                                    ),
                              ),
                            ] +
                            _buildConnectionLines() // 연결선 표시
                            +
                            _buildMarkers() // 마커 표시
                            +
                            _buildFaults() // 결함 표시
                            +
                            _buildMemos() // 메모 아이콘 표시

                            +
                            [
                              // 마커 처음 불러올 때 가림막 역할
                              Visibility(
                                  visible: !isLoaded,
                                  child: Container(
                                      width: drawingDetailController.markerSize,
                                      height:
                                          drawingDetailController.markerSize,
                                      color: Colors.black))
                            ]),
                  ),
                )),

            //도움말 버튼
            HelpButtonWidget(
              currentScale: currentScale,
              scaleStd: scaleStd,
              onTap: () {
                drawingDetailController.showHelpDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 연결선 표시 위젯
  List<Widget> _buildConnectionLines() {
    final List<Widget> result = [];

    for (final marker in drawingDetailController.markerList) {
      if (marker.fault_list == null) continue;

      for (final fault in marker.fault_list!) {
        if (marker.mid != fault.mid) continue;

        // 나머지 처리 로직
        Color outlineColor = fault.color != marker.outline_color
            ? getColorWithCache(fault.color ?? "FF0000")
            : getColorWithCache(marker.outline_color ?? "FF0000");

        if (fault.cloned == "Y") {
          outlineColor = outlineColor.withOpacity(0.4);
        }

        Offset mP = convertDBtoDV(x: marker.x ?? "0", y: marker.y ?? "0");
        Offset fP = convertDBtoDV(x: fault.x ?? "0", y: fault.y ?? "0");

        mP = Offset(mP.dx, mP.dy + verticalPadding);
        fP = Offset(fP.dx, fP.dy + verticalPadding);

        result.add(Visibility(
          visible: isLoaded &&
              drawingDetailController
                      .appService.displayingFid[fault.group_fid] ==
                  fault.fid,
          child: CustomPaint(
            painter: LinePainter(
                start: mP,
                end: fP,
                width: 2 / currentScale,
                color: outlineColor),
          ),
        ));
      }
    }

    return result;
  }

  // 자주 사용되는 객체 캐싱
  final Map<String, Color> _colorCache = {};

  Color getColorWithCache(String colorHex, {double opacity = 1.0}) {
    if (opacity < 1.0) {
      // 알파값이 있는 경우는 캐싱하지 않음
      return Color(int.parse("0xFF$colorHex")).withOpacity(opacity);
    }

    if (_colorCache.containsKey(colorHex)) {
      return _colorCache[colorHex]!;
    }

    Color color = Color(int.parse("0xFF$colorHex"));
    _colorCache[colorHex] = color;
    return color;
  }

  // 현재 마커와 겹치는 다른 마커를 찾는 함수 (성능 최적화)
  Marker? findOverlappingMarker(Marker currentMarker) {
    for (Marker otherMarker in drawingDetailController.markerList) {
      if (currentMarker.mid == otherMarker.mid) continue;
      if (areMarkersOverlapping(currentMarker, otherMarker)) {
        return otherMarker;
      }
    }
    return null;
  }

  // 마커 표시 위젯
  List<Widget> _buildMarkers() {
    List<Widget> result = [];

    for (final data in drawingDetailController.markerList) {
      GlobalKey globalKey = GlobalKey();

      // 위치 계산
      Offset mPosition = convertDBtoDV(x: data.x!, y: data.y!);

      // 색상 계산 캐싱
      Color outlineColor = getColorWithCache(data.outline_color ?? "FF0000");
      Color foregroundColor =
          getColorWithCache(data.foreground_color ?? "FFFFFF");

      Color textColor = foregroundColor == Color.fromARGB(255, 136, 136, 202) ||
              foregroundColor == Color(0xffff0000)
          ? Colors.white
          : Colors.black;

      if (currentScale > scaleStd) {
        outlineColor = outlineColor.withOpacity(opac);
        textColor = textColor.withOpacity(opac);
      }

      result.add(Visibility(
        visible: isLoaded,
        child: Positioned(
            left: mPosition.dx -
                drawingDetailController.markerSize / 2 -
                touchRange,
            top: mPosition.dy -
                drawingDetailController.markerSize / 2 -
                touchRange +
                verticalPadding,
            child: GestureDetector(
              onTap: () {
                // focusOnSpot(globalKey, Offset(double.parse(data.x!) - drawingDetailController.markerSize/2, double.parse(data.y!) - drawingDetailController.markerSize/2));
                drawingDetailController.selectedMarker.value = data;
                drawingDetailController.isNumberSelected.value = true;
              },
              onLongPressStart: (details) {
                if (currentScale >= scaleStd) {
                  if (!drawingDetailController.isMovingNumOrFault.value) {
                    drawingDetailController.isMovingNumOrFault.value = true;
                  }

                  drawingDetailController.selectedMarker.value = data;
                  drawingDetailController.isNumberSelected.value = false;

                  bfMarkerPosition["x"] = data.x!;
                  bfMarkerPosition["y"] = data.y!;

                  Offset markerCenter = Offset(
                      drawingDetailController.markerSize / 2 + touchRange,
                      drawingDetailController.markerSize / 2 + touchRange);

                  touchWeightX = details.localPosition.dx - markerCenter.dx;
                  touchWeightY = details.localPosition.dy - markerCenter.dy;
                }
              },
              onLongPressMoveUpdate: (details) {
                if (currentScale < scaleStd) return;

                double nextDx = topLeftOffset.dx -
                    drawingDetailController.drawingX +
                    (details.globalPosition.dx - leftBarWidth) / currentScale -
                    touchWeightX;

                double nextDy = topLeftOffset.dy -
                    drawingDetailController.drawingY +
                    (details.globalPosition.dy - appBarHeight) / currentScale -
                    touchWeightY; // + positionWeight

                if (nextDx < 0 || nextDy < 0) {
                  drawingDetailController.refreshScreen();
                  return;
                }

                setState(() {
                  markerSnapped = moveMarker(data, nextDx, nextDy);
                });
              },
              onLongPressEnd: (details) {
                if (currentScale < scaleStd) return;
                drawingDetailController.isMovingNumOrFault.value = false;

                // 겹치는 마커 확인 (최적화된 함수 사용)
                Marker? overlappingMarker = findOverlappingMarker(data);

                // 겹치는 마커가 있으면 처리
                if (overlappingMarker != null) {
                  setState(() {
                    data.x = bfMarkerPosition["x"];
                    data.y = bfMarkerPosition["y"];
                  });

                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) =>
                          copyDialog(data, overlappingMarker));
                }

                // 위치 변경되면 수정 사항 업로드
                if (data.x != bfMarkerPosition["x"] ||
                    data.y != bfMarkerPosition["y"]) {
                  drawingDetailController.editMarker(data);
                }

                bfMarkerPosition.remove("x");
                bfMarkerPosition.remove("y");
              },
              child: SizedBox(
                width: drawingDetailController.markerSize + touchRange * 2,
                height: drawingDetailController.markerSize + touchRange * 2,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width:
                            drawingDetailController.markerSize + touchRange * 2,
                        height:
                            drawingDetailController.markerSize + touchRange * 2,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    Center(
                      child: Container(
                        key: globalKey,
                        width: drawingDetailController.markerSize,
                        height: drawingDetailController.markerSize,
                        padding: EdgeInsets.only(top: 0),
                        decoration: BoxDecoration(
                          color: foregroundColor,
                          border: Border.all(
                              color: outlineColor, width: 2 / currentScale),
                          borderRadius: (data.fault_list?.any((fault) =>
                                      fault.picture_list?.isNotEmpty ??
                                      false) ??
                                  false)
                              ? BorderRadius
                                  .zero // Square shape if any fault has pictures
                              : BorderRadius.circular(
                                  drawingDetailController.markerSize /
                                      2), // Circle shape if no pictures
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 1 / currentScale),
                            decoration: BoxDecoration(
                              border: (data.fault_list?.any(
                                          (fault) => fault.status == "보수완료") ??
                                      false)
                                  ? Border(
                                      bottom: BorderSide(
                                        color: Colors.blue,
                                        width: 2 / currentScale,
                                        style: BorderStyle.solid,
                                      ),
                                    )
                                  : Border(),
                            ),
                            child: Text(
                              data.no!,
                              style: TextStyle(
                                color: textColor,
                                fontSize: (int.parse(data.no!) > 100)
                                    ? max(
                                        6,
                                        drawingDetailController.markerSize / 3,
                                      )
                                    : max(
                                        6,
                                        drawingDetailController.markerSize /
                                            2.5,
                                      ),
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ));
    }

    return result;
  }

  // 결함 표시 위젯
  List<Widget> _buildFaults() {
    return drawingDetailController.markerList
        .map((marker) {
          if (currentScale < scaleStd) {
            faultSize = drawingDetailController.faultSize;
          } else {
            faultSize = drawingDetailController.faultSize - 3 / currentScale;
          }
          return marker.fault_list?.map(
            (fault) {
              if (marker.mid == fault.mid) {
                GlobalKey globalKey = GlobalKey();
                Color faultColor = fault.color != marker.outline_color
                    ? getColorWithCache(fault.color ?? "FF0000")
                    : getColorWithCache(marker.outline_color ?? "FF0000");

                if (currentScale >= scaleStd) {
                  faultColor = faultColor.withOpacity(opac);
                }

                if (fault.cloned == "Y") {
                  faultColor = faultColor.withOpacity(0.4);
                }

                bool isMoveTogether = false;
                Marker? theMarker = marker;
                double dX = 0;
                double dY = 0;
                Offset fPosition =
                    convertDBtoDV(x: fault.x ?? "0", y: fault.y ?? "0");

                // 마커와 결함이 1:1 연결일때는 무조건 함께 이동
                if (drawingDetailController
                        .groupsLinkedToMarker[marker.no!]?.length ==
                    1) {
                  isMoveTogether = true;
                  Offset mP = convertDBtoDV(x: marker.x!, y: marker.y!);
                  dX = fPosition.dx - mP.dx;
                  dY = fPosition.dy - mP.dy;
                }
                // 마커와 결함이 1:1 연결이 아닐때는 마커와 결함 x, y 위치가 같을 때만 함께 이동
                else if ((bfMarkerPosition["x"] ?? marker.x) ==
                        (bfFaultPosition["x"] ?? fault.x) ||
                    (bfMarkerPosition["y"] ?? marker.y) ==
                        (bfFaultPosition["y"] ?? fault.y)) {
                  isMoveTogether = true;

                  Offset fP = convertDBtoDV(
                      x: bfFaultPosition["x"] ?? fault.x,
                      y: bfFaultPosition["y"] ?? fault.y);
                  Offset mP = convertDBtoDV(
                      x: bfMarkerPosition["x"] ?? marker.x,
                      y: bfMarkerPosition["y"] ?? marker.y);

                  dX = fP.dx - mP.dx;
                  dY = fP.dy - mP.dy;
                }

                return Visibility(
                  visible: isLoaded &&
                      drawingDetailController
                              .appService.displayingFid[fault.group_fid] ==
                          fault.fid,
                  child: Positioned(
                      left: fPosition.dx - faultSize / 2 - touchRange,
                      top: fPosition.dy -
                          faultSize / 2 -
                          touchRange +
                          verticalPadding,
                      child: GestureDetector(
                        onTap: () {
                          // focusOnSpot(globalKey, Offset(double.parse(fault.x!) - drawingDetailController.markerSize/2, double.parse(fault.y!) - drawingDetailController.markerSize/2));
                          drawingDetailController.selectedMarker.value = marker;
                          drawingDetailController
                              .appService.selectedFault.value = fault;
                          drawingDetailController.isNumberSelected.value = true;
                          drawingDetailController.isPointSelected.value = true;
                        },
                        onLongPressStart: (details) {
                          if (currentScale >= scaleStd) {
                            if (!drawingDetailController
                                .isMovingNumOrFault.value) {
                              drawingDetailController.isMovingNumOrFault.value =
                                  true;
                            }

                            drawingDetailController.selectedMarker.value =
                                marker;
                            drawingDetailController
                                .appService.selectedFault.value = fault;

                            drawingDetailController
                                .appService.isFaultSelected.value = false;

                            bfMarkerPosition["x"] = marker.x!;
                            bfMarkerPosition["y"] = marker.y!;
                            bfFaultPosition["x"] = fault.x!;
                            bfFaultPosition["y"] = fault.y!;

                            Offset faultCenter = Offset(
                                faultSize / 2 + touchRange,
                                faultSize / 2 + touchRange);

                            touchWeightX =
                                details.localPosition.dx - faultCenter.dx;
                            touchWeightY =
                                details.localPosition.dy - faultCenter.dy;
                          }
                        },
                        onLongPressMoveUpdate: (details) {
                          if (currentScale < scaleStd) return;

                          // 미세 움직임 무시
                          if (_lastMovePosition != null) {
                            double dx = details.globalPosition.dx -
                                _lastMovePosition!.dx;
                            double dy = details.globalPosition.dy -
                                _lastMovePosition!.dy;
                            double moveDistance =
                                dx * dx + dy * dy; // 제곱근 계산 생략
                            if (moveDistance < 4) return; // 최소 움직임 기준
                          }

                          double nextDx = topLeftOffset.dx -
                              drawingDetailController.drawingX +
                              (details.globalPosition.dx - leftBarWidth) /
                                  currentScale -
                              touchWeightX;

                          double nextDy = topLeftOffset.dy -
                              drawingDetailController.drawingY +
                              (details.globalPosition.dy - appBarHeight) /
                                  currentScale -
                              touchWeightY;

                          if (nextDx < 0 || nextDy < 0) {
                            drawingDetailController.refreshScreen();
                            return;
                          }

                          // 함께 이동하는 경우
                          if (isMoveTogether) {
                            setState(() {
                              // 마커 이동
                              markerSnapped = moveMarker(
                                  theMarker, nextDx - dX, nextDy - dY,
                                  movingFault: fault);

                              // 결함 위치를 마커 위치 기준으로 설정 (중요!)
                              Offset newMarkerPos = convertDBtoDV(
                                  x: theMarker.x!, y: theMarker.y!);
                              fault.x =
                                  convertDVtoDB(x: newMarkerPos.dx + dX).first;
                              fault.y =
                                  convertDVtoDB(y: newMarkerPos.dy + dY).first;
                            });
                          }
                          // 독립적으로 이동하는 경우 (기존 코드)
                          else {
                            Offset markerPosition =
                                convertDBtoDV(x: theMarker.x!, y: theMarker.y!);

                            // 이전 좌표의 캐시 무효화
                            PerformanceHelpers.invalidateCache(
                                fault.x!,
                                fault.y!,
                                drawingDetailController.drawingWidth,
                                drawingDetailController.drawingHeight);

                            setState(() {
                              // 기존 코드 유지
                              if (nextDx > markerPosition.dx - fixRange &&
                                  nextDx < markerPosition.dx + fixRange) {
                                fault.x = theMarker.x;
                                markerSnapped = true;
                              } else {
                                fault.x = convertDVtoDB(x: nextDx).first;
                                markerSnapped = false;
                              }

                              if (nextDy > markerPosition.dy - fixRange &&
                                  nextDy < markerPosition.dy + fixRange) {
                                fault.y = theMarker.y;
                                markerSnapped = true;
                              } else {
                                fault.y = convertDVtoDB(y: nextDy).first;
                                markerSnapped = false;
                              }
                            });
                          }
                        },
                        onLongPressEnd: (details) {
                          if (currentScale >= scaleStd) {
                            drawingDetailController.isMovingNumOrFault.value =
                                false;

                            List<Fault>? sameMidFaults =
                                PerformanceHelpers.getRelatedFaults(marker);

                            markerSnapped = sameMidFaults.any((sameMidFault) =>
                                sameMidFault.x == marker.x ||
                                sameMidFault.y == marker.y);

                            // 위치 변경되면 수정 사항 업로드
                            if (marker.x != bfMarkerPosition["x"] ||
                                marker.y != bfMarkerPosition["y"]) {
                              drawingDetailController.editMarker(marker);
                            }

                            bfMarkerPosition.remove("x");
                            bfMarkerPosition.remove("y");
                            bfFaultPosition.remove("x");
                            bfFaultPosition.remove("y");

                            // 결함 객체 미리 식별
                            List<Fault> faultsToUpdate = sameMidFaults
                                .where((sameMidFault) =>
                                    sameMidFault.group_fid == fault.group_fid)
                                .toList();

                            setState(() {
                              // 모든 결함 객체 상태도 함께 업데이트
                              for (Fault faultToUpdate in faultsToUpdate) {
                                faultToUpdate.x = fault.x;
                                faultToUpdate.y = fault.y;
                              }
                            });

                            // API 호출은 setState 외부로
                            for (Fault faultToUpdate in faultsToUpdate) {
                              drawingDetailController.editFault(faultToUpdate);
                            }
                          }
                        },
                        child: SizedBox(
                          width: faultSize + touchRange * 2,
                          height: faultSize + touchRange * 2,
                          child: Stack(
                            children: [
                              Center(
                                // 터치영역
                                child: Container(
                                  width: faultSize + touchRange * 2,
                                  height: faultSize + touchRange * 2,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Center(
                                // 결함표시
                                child: Container(
                                  key: globalKey,
                                  width: faultSize,
                                  height: faultSize,
                                  decoration: BoxDecoration(
                                    color: faultColor,
                                    border: (fault.status == "보수완료")
                                        ? Border.all(
                                            color: Colors.black.withOpacity(1),
                                            width: 0.6)
                                        : Border.all(
                                            color: Colors.transparent,
                                            width: 1),
                                    borderRadius:
                                        (fault.picture_list!.isNotEmpty)
                                            ? BorderRadius.zero
                                            : BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                );
              } else {
                return Container();
              }
            },
          ).toList();
        })
        .toList()
        .expand(
          (element) => element ?? [],
        )
        .toList()
        .cast<Widget>();
  }

  // 메모 표시 위젯
  List<Widget> _buildMemos() {
    return drawingDetailController.appService.curDrawing.value.memo_list
        .map((DrawingMemo memo) {
          // DrawingMemo 위젯 추가
          return Visibility(
            visible: isLoaded,
            child: DrawingMemoWidget(
              memo: memo,
              controller: drawingDetailController,
              verticalPadding: verticalPadding,
              currentScale: currentScale,
              scaleStd: scaleStd,
              touchRange: touchRange,
              fixRange: fixRange,
              topLeftOffset: topLeftOffset,
              convertDBtoDV: ({String? x, String? y}) =>
                  convertDBtoDV(x: x, y: y),
              convertDVtoDB: ({double? x, double? y}) =>
                  convertDVtoDB(x: x, y: y),
            ),
          );
        })
        .toList()
        .cast<Widget>();
  }

  bool moveMarker(Marker marker, double nextDx, double nextDy,
      {Fault? movingFault}) {
    bool isSnapped = false;

    // 결함 목록 가져오기
    List<Fault>? sameMidFaults = PerformanceHelpers.getRelatedFaults(marker);

    // 결함이 없으면 바로 위치 설정
    if (sameMidFaults.isEmpty) {
      // 기존 코드 유지...
      return false;
    }

    // 결함이 있는 경우 최적화
    String? newMarkerX;
    String? newMarkerY;

    // 좌표 처리 플래그
    bool xProcessed = false;
    bool yProcessed = false;

    for (Fault fault in sameMidFaults) {
      // 이동 중인 결함은 건너뛰기
      if (sameMidFaults.length > 1 &&
          movingFault != null &&
          fault == movingFault) {
        continue;
      }

      // 좌표 변환
      Offset faultPosition = convertDBtoDV(x: fault.x!, y: fault.y!);

      // X축 스냅 체크 - !xProcessed 조건만 체크
      if (!xProcessed &&
          nextDx > faultPosition.dx - fixRange &&
          nextDx < faultPosition.dx + fixRange) {
        newMarkerX = fault.x;
        isSnapped = true;
        xProcessed = true;
      }

      // Y축 스냅 체크 - !yProcessed 조건만 체크, !isSnapped 제거
      if (!yProcessed &&
          nextDy > faultPosition.dy - fixRange &&
          nextDy < faultPosition.dy + fixRange) {
        newMarkerY = fault.y;
        isSnapped = true;
        yProcessed = true;
      }

      // 둘 다 처리되었으면 루프 종료
      if (xProcessed && yProcessed) break;
    }

    // 스냅되지 않은 좌표는 일반 변환
    newMarkerX ??= convertDVtoDB(x: nextDx).first;
    newMarkerY ??= convertDVtoDB(y: nextDy).first;

    // 실제 변경이 있을 때만 상태 업데이트
    if (marker.x != newMarkerX || marker.y != newMarkerY) {
      marker.x = newMarkerX;
      marker.y = newMarkerY;
    }

    return isSnapped;
  }

  TwoButtonDialog copyDialog(Marker marker1, Marker marker2) {
    Marker fromM = marker1;
    Marker toM = marker2;
    return TwoButtonDialog(
        height: 170,
        content: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "안내",
                    style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gaps.h10,
                  normalText("수행할 액션을 골라주세요."),
                ],
              ),
            ),
            Align(
                alignment: Alignment.topRight,
                child: InkWell(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close_rounded,
                      size: 28,
                    )))
          ],
        ),
        yes: "합치기",
        no: "결함 덮어쓰기",
        onYes: () {
          drawingDetailController.mergeMarker(context, fromM, toM);
          Get.back();
          FocusScope.of(context).unfocus();
        },
        onNo: () {
          drawingDetailController.overrideMarker(context, fromM, toM);
          Get.back();
          FocusScope.of(context).unfocus();
        });
  }

  Text boldText(String content) {
    return Text(
      content,
      style: TextStyle(
          fontFamily: "Pretendard", fontSize: 18, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Text normalText(String content) {
    return Text(
      content,
      style: TextStyle(
        fontFamily: "Pretendard",
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }
}
