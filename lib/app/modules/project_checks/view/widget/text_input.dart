import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/app_color.dart';

class TextInput extends StatefulWidget {
  final String? text;
  final TextEditingController controller;
  final FocusNode focusNode;

  const TextInput(
      {super.key,
      this.text,
      required this.controller,
      required this.focusNode});

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  @override
  void initState() {
    super.initState();
    if (widget.text != null && widget.text!.isNotEmpty) {
      widget.controller.text = widget.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          hintText: '점검자명 입력',
          isDense: true,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.c4),
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
