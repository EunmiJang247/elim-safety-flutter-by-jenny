import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/opinion_modal.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';
import '../../../project_checks/controllers/project_checks_controller.dart';

class ProjectChecksHeader extends GetView<ProjectChecksController> {
  const ProjectChecksHeader({super.key});

  @override
  Widget build(BuildContext context) {
    Future<String?> _showOpinionDialog() async {
      final result = await showDialog<String>(
        context: Get.context!,
        builder: (context) => OpinionModal(
          title: '점검자 의견',
          text: controller
                  .appService.curProject?.value.site_check_form?.opinion ??
              '',
          hintText: '점검자 의견을 입력하세요',
        ),
      );
      return result;
    }

    Future<String?> _showMemoDialog() async {
      final result = await showDialog<String>(
        context: Get.context!,
        builder: (context) => OpinionModal(
          title: '현장 메모사항',
          text: controller.appService.curProject?.value.site_check_form?.memo ??
              '',
          hintText: '메모를 입력하세요',
        ),
      );
      return result;
    }

    // Future<String?> _showMemoDialog() async {
    //   TextEditingController _controller = TextEditingController(
    //     text:
    //         controller.appService.curProject?.value.site_check_form?.memo ?? '',
    //   );

    //   final result = await showDialog<String>(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Text('메모'),
    //         content: TextField(
    //           controller: _controller,
    //           decoration: InputDecoration(hintText: '메모를 입력하세요'),
    //         ),
    //         actions: [
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: Text('취소'),
    //           ),
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop(_controller.text);
    //             },
    //             child: Text('확인'),
    //           ),
    //         ],
    //       );
    //     },
    //   );

    //   return result;
    // }

    return CustomAppBar(
      leftSide: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(left: 48),
              width: 200.w,
              child: Text(
                controller.appService.curProject!.value.name ?? "",
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              // await controller.appService
              //     .onTapSendDataToServer(); // 서버 전송 완료될 때까지 기다림
              // controller.appService.updateNeedUpdateFlag(); // 그다음 업데이트 체크
              FocusScope.of(context).unfocus();
              Get.back();
            },
            child: Container(
              margin: EdgeInsets.only(right: 44),
              height: appBarHeight,
              width: 44,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      rightSide: Row(
        children: [
          MaterialButton(
            onPressed: () async {
              final opinion = await _showOpinionDialog();
              if (opinion != null) {
                controller.onMakeOpinionClick(opinion);
              }
            },
            color: AppColors.button,
            child: Text("점검자 의견",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Pretendard",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
          ),
          SizedBox(
            width: 8,
          ),
          MaterialButton(
            onPressed: () async {
              final memo = await _showMemoDialog();
              if (memo != null) {
                controller.onMakeMemoClick(memo);
              }
            },
            color: AppColors.button,
            child: Text("메모사항",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Pretendard",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
          ),
          SizedBox(
            width: 8,
          ),
          MaterialButton(
            onPressed: () {
              controller.goDrawingList();
            },
            color: AppColors.button,
            child: Text("도면 목록",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Pretendard",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
