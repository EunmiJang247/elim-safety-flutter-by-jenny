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
  // InteractiveViewer의 확대/축소, 이동(transform) 상태를 제어·관찰하는 컨트롤러를 생성
  GlobalKey drawingKey = GlobalKey();
  // 특정 위젯(여기서는 도면/이미지 컨테이너)에 전역적으로 접근하기 위한 키
  // 이 키로 RenderBox를 얻어 위젯의 실제 크기/좌표를 계산하거나 context에 접근할 수 있다
  Image image = Image.network("");
  // 도면(이미지)을 화면에 띄우기 위해 Image 위젯을 미리 선언
  late ImageStream imageStream;
  // Image 위젯은 내부적으로 이미지를 디코딩할 때 ImageStream을 통해 비트맵 데이터를 흘려보냅니다
  late ImageStreamListener imageStreamListener;
  // imageStream에 리스너를 달아서 콜백을 받는 역할을 합니다
  // onImage → 실제 픽셀이 준비되었을 때 실행 / onError → 로딩 실패했을 때 실행
  bool isLoaded = false;

  List<Widget> lines = [];
  // 연결선(CustomPaint 등)들을 담아둘 리스트
  Offset topLeftOffset = Offset.zero;
  // 현재 화면에서 보이는 도면의 왼쪽 위 좌표를 저장
  Map<String, String> bfMarkerPosition = {};
  // before marker position (마커 이전 위치) 저장용 맵
  // 마커를 드래그해서 움직이기 전의 원래 x, y 좌표를 임시로 저장해 둡니다
  Map<String, String> bfFaultPosition = {};
  // before fault position (결함 아이콘 이전 위치) 저장용 맵.
  double maxScale = 10;
  // InteractiveViewer에서 도면을 최대로 확대할 수 있는 배율
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

  List<String> convertDVtoDB({double? x, double? y}) {
    // 화면 좌표(DV, Device View) → DB 좌표(DB, 비율 좌표) 변환
    List<String> result = [];
    // 변환된 좌표를 담을 빈 리스트 생성
    if (x != null) {
      result.add((x / drawingDetailController.drawingWidth).toString());
      // 현재 도면의 실제 화면 너비(drawingWidth)로 나눔 → 0~1 사이의 비율로 변환
      // 예: 도면 너비가 1000이고, x = 250이면 → "0.25"
    }
    if (y != null) {
      result.add((y / drawingDetailController.drawingHeight).toString());
    }
    return result;
  }

  // 디비의 값을 기기에 맞게 변경
  Offset convertDBtoDV({String? x, String? y}) {
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
    // convertDBtoDV: 데이터베이스(DB)에 저장된 좌표(x, y)를 디바이스 화면 좌표(Offset)로 변환

    // 두 마커의 중심 간 거리 계산
    double distance = (m1P - m2P).distance;

    // 두 마커의 반지름을 더한 값과 거리 비교
    return distance < drawingDetailController.markerSizeUi;
    // drawingDetailController.markerSizeUi는 마커의 지름을 의미한
  }

  @override
  void initState() {
    transformationController.addListener(updateInfos);
    // 확대/축소, 드레그 상태가 변할때마다 updateInfos() 호출
    // TransformationController는 Flutter 프레임워크의 일부로,
    // InteractiveViewer 위젯과 함께 사용하기 위해 설계된 컨트롤러
    // InteractiveViewer의 변환 상태(확대, 축소, 이동 등)를 제어하고 관찰할 수 있도록 설계됨
    super.initState();

    image = Image.network(
      key: drawingKey,
      // GlobalKey를 사용하여 이 이미지 위젯에 전역적으로 접근할 수 있도록 설정
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
        (drawingDetailController.markerSizeUi * 0.5) * (1 - 1 / currentScale);

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
    // UI 스케일 업데이트
    drawingDetailController.updateUiScale(context);

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
      // RepaintBoundary는 Flutter에서 렌더링 성능 최적화와 위젯 독립성을 위해 쓰는 위젯
      // DrawingView 안에는 InteractiveViewer, 마커, 결함, 메모 등 계속 변하는 많은 위젯이 있어요
      // RepaintBoundary를 사용하면 "이 Container 단위로만 다시 그림" → 다른 화면 위젯들은 건드리지 않음
      child: Container(
        height: MediaQuery.of(context).size.height - appBarHeight,
        width: MediaQuery.of(context).size.width - leftBarWidth,
        color: Colors.black,
        child: Stack(
          children: [
            Obx(() => InteractiveViewer(
                  // Flutter의 기본 위젯으로, 확대/축소(zoom), 드래그(pan) 같은 제스처를 지원
                  transformationController: transformationController,
                  // 확대/이동 상태를 추적하거나, 코드로 직접 조정할 수 있게 연결한 컨트롤러
                  maxScale: maxScale,
                  // 최대 확대 배율 제한 (여기선 10).
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                        children: <Widget>[
                              GestureDetector(
                                onTapDown: (details) {
                                  // 메모 추가 기능
                                  if (drawingDetailController
                                      .addMemoMode.value) {
                                    // 조건: addMemoMode(메모 추가 모드)가 켜져 있을 때만 동작
                                    Offset localPosition =
                                        details.localPosition;
                                    // 사용자가 터치한 좌표(details.localPosition)를 가져옴.
                                    List<String> newPosition = convertDVtoDB(
                                        x: localPosition.dx,
                                        y: localPosition.dy - verticalPadding);
                                    // convertDVtoDB를 써서 디바이스 좌표를 DB 저장용 좌표로 변환
                                    drawingDetailController.makeNewDrawingMemo(
                                      newPosition[0],
                                      newPosition[1],
                                    );
                                    // 컨트롤러의 makeNewDrawingMemo()를 호출해서 새 메모 아이콘 생성
                                  }
                                },
                                onLongPressStart: (details) {
                                  // 길게 누르면
                                  if (currentScale >= scaleStd) {
                                    // 조건: 현재 확대 배율(currentScale)이 기준 배율(scaleStd, 예: 1.7) 이상일 때만 동작.
                                    // 충분히 확대했을 때만 결함/마커 같은 세밀한 조작을 허용한다는 의미
                                    Offset localPosition =
                                        details.localPosition;
                                    // details.localPosition → 터치된 위치 (도면 내부의 좌표, 픽셀 단위).
                                    List<String> newPosition = convertDVtoDB(
                                        x: localPosition.dx,
                                        y: localPosition.dy - verticalPadding);
                                    // 도면 위젯의 상단 여백(verticalPadding)을 보정하기 위해서 빼는 것!
                                    String mfGap = convertDVtoDB(
                                            y: drawingDetailController
                                                    .markerSizeUi *
                                                1.2)
                                        // 마커 크기(markerSizeUi)에 1.2를 곱하여 약간 더 큰 값을 계산한다
                                        // 이 y크기를 데이터베이스로 바꾼다.
                                        // 예를 들어, markerSizeUi * 1.2가 120이고 도면 높이가 1000이라면, 반환값은 0.12가 됩니다
                                        .first;
                                    drawingDetailController.onLongPress(
                                        // onLongPress 함수를 실행한다
                                        // 새로운 위치와 마커 간격을 전달한다
                                        newPosition,
                                        mfGap);
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
                                      width:
                                          drawingDetailController.markerSizeUi,
                                      height:
                                          drawingDetailController.markerSizeUi,
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
    // 빌드해서 반환할 위젯들을 담는 리스트
    List<Widget> result = [];

    // 화면에 표시할 모든 마커를 순회
    for (final data in drawingDetailController.markerList) {
      // 이 마커의 위치를 포커싱 등에서 쓰기 위한 GlobalKey (크기/위치 참조 용)
      GlobalKey globalKey = GlobalKey();

      // 위치 계산: DB에 저장된 비율 좌표(x,y)를 현재 기기 화면 좌표(Offset)로 변환
      Offset mPosition = convertDBtoDV(x: data.x!, y: data.y!);

      // 색상 계산 캐싱
      Color outlineColor = getColorWithCache(data.outline_color ?? "FF0000");
      Color foregroundColor =
          getColorWithCache(data.foreground_color ?? "FFFFFF");

      Color textColor = foregroundColor == Color.fromARGB(255, 136, 136, 202) ||
              foregroundColor == Color(0xffff0000) ||
              foregroundColor == Color(0xff0909ff) ||
              foregroundColor == Color(0xff4caf50)
          ? Colors.white
          : Colors.black;

      if (currentScale > scaleStd) {
        outlineColor = outlineColor.withOpacity(opac);
        textColor = textColor.withOpacity(opac);
      }

      // 실제로 그릴 마커 하나를 result에 추가
      result.add(Visibility(
        visible: isLoaded,
        // isLoaded(이미지/도면이 로딩 완료되었는지)에 따라 보이기/숨기기
        child: Positioned(
            // 마커 박스의 left/top 좌표: 마커 중심 기준에서 반지름만큼 빼고, 터치 여유(touchRange)도 반영
            left: mPosition.dx - // 마커의 중심 좌표의 x값
                drawingDetailController.markerSizeUi / 2 -
                // 마커의 크기(markerSizeUi)의 절반입니다
                //마커의 중심 좌표(mPosition.dx)에서 마커의 반지름만큼 빼면 마커의 좌측 경계선(left)을 구할 수 있습니다
                touchRange,
            //터치 여유 공간입니다. 사용자가 마커를 쉽게 선택하거나 조작할 수 있도록 마커 주변에 추가적인 여유 공간을 제공합니다
            top: mPosition.dy -
                drawingDetailController.markerSizeUi / 2 -
                touchRange +
                verticalPadding,
            child: GestureDetector(
              onTap: () {
                // focusOnSpot(globalKey, Offset(double.parse(data.x!) - drawingDetailController.markerSize/2, double.parse(data.y!) - drawingDetailController.markerSize/2));
                drawingDetailController.selectedMarker.value = data;
                drawingDetailController.isNumberSelected.value = true;
                // 숫자 선택 상태(isNumberSelected)를 false로 설정
              },
              onLongPressStart: (details) {
                // onLongPressStart: 터치 이벤트의 위치 정보(localPosition, globalPosition 등)를 포함합니다
                if (currentScale >= scaleStd) {
                  // 현재 화면의 확대 배율(currentScale)이 기준 배율(scaleStd) 이상인지 확인
                  if (!drawingDetailController.isMovingNumOrFault.value) {
                    drawingDetailController.isMovingNumOrFault.value = true;
                    // isMovingNumOrFault는 마커나 결함이 이동 중인지 여부를 나타내는 상태 변수를 true로
                  }

                  drawingDetailController.selectedMarker.value = data;
                  drawingDetailController.isNumberSelected.value = false;
                  // 숫자 선택 상태(isNumberSelected)를 false로 설정

                  bfMarkerPosition["x"] = data.x!;
                  bfMarkerPosition["y"] = data.y!;
                  // bfMarkerPosition는 마커의 이전 위치를 저장하는 맵입니다

                  print("bfMarkerPosition: $bfMarkerPosition");

                  Offset markerCenter = Offset(
                      drawingDetailController.markerSizeUi / 2 + touchRange,
                      drawingDetailController.markerSizeUi / 2 + touchRange);

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
                width: drawingDetailController.markerSizeUi + touchRange * 2,
                height: drawingDetailController.markerSizeUi + touchRange * 2,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: drawingDetailController.markerSizeUi +
                            touchRange * 2,
                        height: drawingDetailController.markerSizeUi +
                            touchRange * 2,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    Center(
                      child: Container(
                        key: globalKey,
                        width: drawingDetailController.markerSizeUi,
                        height: drawingDetailController.markerSizeUi,
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
                                  drawingDetailController.markerSizeUi /
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
                                        drawingDetailController.markerSizeUi /
                                            3,
                                      )
                                    : max(
                                        6,
                                        drawingDetailController.markerSizeUi /
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
          print("marker: ${marker.toJson()}");
          if (currentScale < scaleStd) {
            // 현재 배율(currentScale)이 기준(scaleStd)보다 작은 경우,
            // 세밀 조작 비활성화, 결함 크기도 크게 보이도록 유지.
            faultSize = drawingDetailController.faultSizeUi;
          } else {
            // 확대 되어 있는 경우
            //
            faultSize = drawingDetailController.faultSizeUi - 3 / currentScale;
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
                            fixRange = 0;
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
                            fixRange = 5;
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
