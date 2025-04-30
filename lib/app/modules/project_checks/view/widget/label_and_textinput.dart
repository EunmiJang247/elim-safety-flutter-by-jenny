import 'package:flutter/material.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/text_input.dart';

class LabelAndTextinput extends StatelessWidget {
  const LabelAndTextinput(
      {super.key,
      required this.controller,
      this.text,
      required this.label,
      required this.focusNode});

  final TextEditingController controller;
  final String? text;
  final String label;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      SizedBox(
        width: 8,
      ),
      TextInput(
        text: text,
        controller: controller,
        focusNode: focusNode,
      ),
    ]);
  }
}
