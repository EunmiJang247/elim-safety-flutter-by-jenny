import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/modules/project_checks/controllers/project_checks_controller.dart';

class OpinionModal extends GetView<ProjectChecksController> {
  const OpinionModal({super.key, this.title, this.text, this.hintText});

  final String? title;
  final String? text;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController(
      text: text ?? '',
    );
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight * 0.9,
              maxWidth: constraints.maxWidth * 0.95,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title ?? '점검자 의견',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 5,
                      decoration: InputDecoration(
                        hintText: hintText ?? '점검자 의견을 입력하세요',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: MaterialButton(
                            onPressed: () => Navigator.of(context).pop(),
                            color: AppColors.button,
                            child: const Text(
                              "닫기",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Pretendard",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pop(_controller.text);
                            },
                            color: AppColors.button,
                            child: const Text(
                              "저장",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Pretendard",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
