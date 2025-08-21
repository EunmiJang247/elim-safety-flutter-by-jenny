import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/modules/drawing_detail/controllers/drawing_detail_controller.dart';
import 'package:safety_check/app/utils/formatter.dart';
import 'package:safety_check/app/widgets/custom_color_picker.dart';
import 'package:safety_check/app/widgets/photo.dart';

import '../../../constant/app_color.dart';
import '../../../constant/constants.dart';
import '../../../data/models/03_marker.dart';
import '../../../data/models/04_fault.dart';
import '../../../widgets/number_input_dialog2.dart';
import '../../../widgets/two_button_dialog.dart';

class NumberDrawer extends StatefulWidget {
  const NumberDrawer({super.key});

  @override
  State<NumberDrawer> createState() => _NumberDrawerState();
}

class _NumberDrawerState extends State<NumberDrawer> {
  final AppService appService = Get.find();
  final DrawingDetailController drawingDetailController = Get.find();

  // 상수 추출
  static const _drawerAnimationDuration = Duration(milliseconds: 200);

  List<Fault> get faultList =>
      drawingDetailController.selectedMarker.value.fault_list ?? [];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildColorPicker(),
          _buildDrawerContainer(context),
        ],
      );
    });
  }

  // 색상 선택기 위젯
  Widget _buildColorPicker() {
    return Visibility(
      visible: drawingDetailController.isNumberSelected.value &&
          drawingDetailController.clrPickerOpened.value,
      child: CustomColorPicker(),
    );
  }

  // 드로어 컨테이너 위젯
  Widget _buildDrawerContainer(BuildContext context) {
    return AnimatedContainer(
      duration: _drawerAnimationDuration,
      curve: Curves.easeIn,
      decoration: BoxDecoration(color: Color(0xffD9D9D9)),
      margin: EdgeInsets.only(top: appBarHeight),
      width: drawingDetailController.isNumberSelected.value ? 136.w : 0,
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).viewInsets.bottom -
          appBarHeight,
      child: Column(
        children: [
          _buildDrawerHeader(),
          _buildFaultList(),
        ],
      ),
    );
  }

  // 드로어 헤더 섹션
  Widget _buildDrawerHeader() {
    return Container(
      height: 56,
      color: AppColors.c4,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 136.w - 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMarkerProperties(),
              _buildHeaderActions(),
            ],
          ),
        ),
      ),
    );
  }

  // 마커 속성 UI
  Widget _buildMarkerProperties() {
    return Row(
      children: [
        _buildNumberButton(),
        _buildSizeDropdown(),
      ],
    );
  }

  // 번호 버튼
  Widget _buildNumberButton() {
    return Container(
      width: 75,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => NumberInputDialog2(attribute: "번호"),
          );
        },
        child: Center(
          child: Text(
            "${drawingDetailController.selectedMarker.value.no ?? ""}번",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // 크기 드롭다운
  Widget _buildSizeDropdown() {
    return Container(
      width: 80,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.only(left: 8, right: 4),
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Center(
        child: DropdownButton(
          value: drawingDetailController.markerSize,
          items: List.generate(
            14,
            (index) => DropdownMenuItem(
              value: 6 + (index * 2),
              child: Text("${6 + (index * 2)}px"),
            ),
          ),
          onChanged: (value) {
            if (value != null) {
              drawingDetailController.changeMarkerSize(value);
            }
          },
          elevation: 2,
          dropdownColor: Colors.white,
          underline: Container(),
          isExpanded: true,
          menuWidth: 89,
        ),
      ),
    );
  }

  // 헤더 액션 버튼들
  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildOutlineColorButton(),
        _buildForegroundColorButton(),
        _buildDeleteButton(),
        _buildDetachButton(),
        _buildCloseButton(),
      ],
    );
  }

  // 외곽선 색상 버튼
  Widget _buildOutlineColorButton() {
    final outlineColor = _getMarkerOutlineColor();
    return InkWell(
      onTap: () => drawingDetailController.onClrBtnClicked(true, true),
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: AppColors.c4,
          border: Border.all(color: outlineColor),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // 전경 색상 버튼
  Widget _buildForegroundColorButton() {
    final foregroundColor = _getMarkerForegroundColor();
    return InkWell(
      onTap: () => drawingDetailController.onClrBtnClicked(true, false),
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: foregroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // 마커 외곽선 색상 얻기
  Color _getMarkerOutlineColor() {
    if (drawingDetailController.markerList.isEmpty) {
      return Colors.red;
    }

    final marker = drawingDetailController.markerList.firstWhere(
      (element) =>
          element.no == drawingDetailController.selectedMarker.value.no,
      orElse: () => Marker(outline_color: "ff0000"),
    );

    final colorHex = marker.outline_color ?? "ff0000";
    return Color(int.parse("0xFF$colorHex"));
  }

  // 마커 전경 색상 얻기
  Color _getMarkerForegroundColor() {
    if (drawingDetailController.markerList.isEmpty) {
      return Colors.red;
    }

    final marker = drawingDetailController.markerList.firstWhere(
      (element) =>
          element.no == drawingDetailController.selectedMarker.value.no,
      orElse: () => Marker(foreground_color: "ff0000"),
    );

    final colorHex = marker.foreground_color ?? "ff0000";
    return Color(int.parse("0xFF$colorHex"));
  }

  // 삭제 버튼
  Widget _buildDeleteButton() {
    return InkWell(
      onTap: () => _showDeleteDialog(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
        child: Icon(
          FontAwesomeIcons.trashCan,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // 분리 버튼
  Widget _buildDetachButton() {
    return InkWell(
      onTap: () => _showDetachDialog(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
        child: Icon(
          FontAwesomeIcons.linkSlash,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // 닫기 버튼
  Widget _buildCloseButton() {
    return InkWell(
      onTap: () {
        drawingDetailController.closeNumberDrawer(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        child: Icon(
          Icons.close_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // 분리 확인 다이얼로그
  void _showDetachDialog() {
    showDialog(
      context: context,
      builder: (context) => TwoButtonDialog(
        height: 200,
        content: Column(
          children: [
            Text(
              "마커 분리",
              style: TextStyle(
                fontFamily: "Pretendard",
                color: AppColors.c1,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Gaps.h16,
            Text(
              "'${drawingDetailController.selectedMarker.value.no}'번을 분리하시겠습니까? \n",
              style: TextStyle(fontFamily: "Pretendard", fontSize: 18),
              textAlign: TextAlign.center,
            )
          ],
        ),
        yes: "분리",
        no: "취소",
        onYes: () {
          drawingDetailController.detachMarker();
          Get.back();
        },
        onNo: () => Get.back(),
      ),
    );
  }

  // 삭제 확인 다이얼로그
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => TwoButtonDialog(
        height: 200,
        content: Column(
          children: [
            Text(
              "번호 삭제",
              style: TextStyle(
                fontFamily: "Pretendard",
                color: AppColors.c1,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Gaps.h16,
            Text(
              "'${drawingDetailController.selectedMarker.value.no}'번을 삭제하시겠습니까?\n삭제하면 복구 할 수 없습니다.",
              style: TextStyle(fontFamily: "Pretendard", fontSize: 18),
              textAlign: TextAlign.center,
            )
          ],
        ),
        yes: "삭제",
        no: "취소",
        onYes: () {
          drawingDetailController.delMarker();
          Get.back();
        },
        onNo: () => Get.back(),
      ),
    );
  }

  void _sortFaultsByCloneGroup(List<Fault> faults) {
    faults.sort((a, b) {
      // 1. group_fid를 기준으로 먼저 묶고
      final groupCompare = (a.group_fid ?? '').compareTo(b.group_fid ?? '');
      if (groupCompare != 0) return groupCompare;

      // 2. 같은 그룹이라면 등록시간 순으로 정렬
      return (a.reg_time ?? '').compareTo(b.reg_time ?? '');
    });
  }

  List<Fault> _filterChildFaults(List<Fault> faults, String fid) {
    return faults.where((fault) => fault.group_fid == fid).toList();
  }

  // 결함 목록 위젯
  Widget _buildFaultList() {
    List<Fault> sortedFaults = [...faultList];
    _sortFaultsByCloneGroup(sortedFaults);

    if (drawingDetailController.appService.selectedFault.value.fid != null &&
        drawingDetailController.isPointSelected.value) {
      String fid = drawingDetailController.appService.selectedFault.value.fid!;
      sortedFaults = _filterChildFaults(sortedFaults, fid);
    }
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 16, top: 16, right: 16),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sortedFaults.length,
          itemBuilder: (context, index) => FaultItemCard(
            fault: sortedFaults[index],
            drawingDetailController: drawingDetailController,
            appService: appService,
          ),
        ),
      ),
    );
  }
}

// 결함 아이템 카드 위젯 - 코드 재사용성을 높이기 위해 별도 위젯으로 추출
class FaultItemCard extends StatelessWidget {
  final Fault fault;
  final DrawingDetailController drawingDetailController;
  final AppService appService;

  static const _cardHeight = 100.0;
  static final _imageWidth = 35.w;
  static const _borderRadius =
      BorderRadius.horizontal(left: Radius.circular(8));
  // 이 클래스에서 필요한 상수 추가
  static const _cardMarginBottom = 16.0;

  const FaultItemCard({
    super.key,
    required this.fault,
    required this.drawingDetailController,
    required this.appService,
  });

  @override
  Widget build(BuildContext context) {
    final List<CustomPicture> faultPics =
        drawingDetailController.loadGallery(fault.fid!) ?? [];
    final String? thumb = faultPics.isNotEmpty
        ? (faultPics.first.thumb ?? faultPics.first.file_path)
        : null;

    return InkWell(
      onTap: () {
        appService.selectedFault.value = fault;
        appService.isFaultSelected.value = true;
      },
      child: Padding(
        padding: (fault.group_fid != fault.fid)
            ? const EdgeInsets.fromLTRB(12, 0, 0, 0)
            : EdgeInsets.zero,
        child: Container(
            height: _cardHeight,
            margin: const EdgeInsets.only(bottom: _cardMarginBottom),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  spreadRadius: -1,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 10),
                  blurRadius: 15,
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Row(
              children: [
                _buildThumbnail(thumb),
                Expanded(child: _buildFaultDetails()),
              ],
            )),
      ),
    );
  }

  // 썸네일 위젯
  Widget _buildThumbnail(String? thumb) {
    return thumb != null
        ? SizedBox(
            height: _cardHeight,
            width: _imageWidth,
            child: ClipRRect(
              borderRadius: _borderRadius,
              child: Photo(
                imageUrl: thumb,
                height: _cardHeight,
                boxFit: BoxFit.cover,
              ),
            ),
          )
        : Container(
            width: _imageWidth,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: _borderRadius,
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.image,
                size: 50,
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          );
  }

  // 결함 세부정보 위젯
  Widget _buildFaultDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHeaderRow(),
          _buildLocationRow(),
          _buildMeasurementsRow(),
        ],
      ),
    );
  }

  // 헤더 행(카테고리 및 가시성)
  Widget _buildHeaderRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            makeCateString(fault),
            style: TextStyle(
              color: fault.status == "Y" ? Colors.redAccent : Colors.black,
              fontFamily: "Pretendard",
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Visibility(
            visible: appService.displayingFid[fault.group_fid] == fault.fid,
            child: Text(
              fault.structure ?? "미지정",
              style: TextStyle(fontSize: 12),
            ))
      ],
    );
  }

  // 위치 행
  Widget _buildLocationRow() {
    return Row(
      children: [
        Text(
          fault.location ?? "부위X",
          style: TextStyle(
            fontFamily: "Pretendard",
            fontSize: 14,
          ),
        ),
        Gaps.w16,
        Text(
          fault.elem ?? "부재X",
          style: TextStyle(
            fontFamily: "Pretendard",
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // 측정값 행
  Widget _buildMeasurementsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildMeasurement("폭", fault.width ?? "X"),
        _buildMeasurement("길이", fault.length ?? "X"),
        _buildMeasurement("개소", "${fault.qty ?? 0}"),
      ],
    );
  }

  // 측정 요소 위젯
  Widget _buildMeasurement(String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Text(
            "$label ",
            style: TextStyle(
              fontFamily: "Pretendard",
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: "Pretendard",
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
