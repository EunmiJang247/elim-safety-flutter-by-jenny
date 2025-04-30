import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/widgets/custom_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../constant/app_color.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.appService.onPop(context);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.backGround,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child:
              KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
            return SafeArea(
                child: Row(
              children: [
                Expanded(
                    child: CupertinoScrollbar(
                  child: SingleChildScrollView(
                    reverse: isKeyboardVisible,
                    child: Container(
                      // height: MediaQuery.of(context).size.height +
                      //     MediaQuery.of(context).viewInsets.bottom,
                      padding: EdgeInsets.only(left: 70, right: 70),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            "스마트안전진단",
                            style: TextStyle(
                              color: AppColors.c4,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 7.h,
                          ),
                          Text(
                            "로그인",
                            style: TextStyle(
                                color: AppColors.tc1,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 7.h,
                          ),
                          Text(
                            "발급받은 계정 정보를 입력해주세요",
                            style: TextStyle(
                                color: AppColors.tc1,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Color(0xffE5E7EB)),
                                borderRadius: BorderRadius.circular(8)),
                            child: TextField(
                              controller: controller.idController,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  border: InputBorder.none,
                                  hintText: "아이디/이메일",
                                  hintStyle: TextStyle(
                                      color: Color(0xffb2b2b2), fontSize: 16)),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Color(0xffE5E7EB)),
                                borderRadius: BorderRadius.circular(8)),
                            child: Obx(() => Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: controller.pwController,
                                        obscureText:
                                            controller.isObscureText.value,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                            border: InputBorder.none,
                                            hintText: "비밀번호",
                                            hintStyle: TextStyle(
                                                color: Color(0xffb2b2b2),
                                                fontSize: 16)),
                                        onSubmitted: (value) =>
                                            controller.onTapLogin(context,
                                                offline: false),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.isObscureText.value =
                                            !controller.isObscureText.value;
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12.0),
                                        child: Icon(
                                          controller.isObscureText.value
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "로그인 정보를 저장합니다.",
                                style: TextStyle(
                                    color: AppColors.tc1,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                              Obx(
                                () => CupertinoSwitch(
                                  value: controller.isSaveLoginInfo.value,
                                  onChanged: (value) =>
                                      controller.setIsSaveInfo(value),
                                  // activeTrackColor: AppColors.c4,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          customButton(
                            context,
                            "로그인",
                            () =>
                                controller.onTapLogin(context, offline: false),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          InkWell(
                            onTap: () {
                              controller.onTapFindPw();
                            },
                            child: Text(
                              "비밀번호를 잊으셨나요?",
                              style: TextStyle(
                                  color: AppColors.tc1,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom,
                          )
                        ],
                      ),
                    ),
                  ),
                )),
                Expanded(
                    child: SizedBox(
                  child: Stack(
                    children: [
                      CarouselSlider(
                          items: controller.bannerImages,
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height,
                            padEnds: false,
                            pageSnapping: true,
                            autoPlay: true,
                            viewportFraction: 1,
                            enlargeCenterPage: false,
                            onPageChanged: (index, reason) {
                              controller.index.value = index;
                            },
                          )),
                      Obx(() => Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: AnimatedSmoothIndicator(
                                activeIndex: controller.index.value,
                                count: controller.bannerImages.length,
                                effect: WormEffect(
                                  dotWidth: 8.0,
                                  dotHeight: 8.0,
                                  activeDotColor: AppColors.c4,
                                  dotColor: Colors.grey,
                                ),
                                // onDotClicked: (index) {
                                //   _controller.animateToPage(index);
                                // },
                              ),
                            ),
                          )),
                    ],
                  ),
                ))
              ],
            ));
          }),
        ),
      ),
    );
  }
}
