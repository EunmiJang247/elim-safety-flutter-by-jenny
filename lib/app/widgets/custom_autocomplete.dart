import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomAutoCompleteField extends StatelessWidget {
  final TextEditingController textController;
  List<String> suggestions;
  String? hintText;
  FocusNode? focusNode;
  TextInputType? keyboardType;
  double? width;

  CustomAutoCompleteField(
      {super.key,
      required this.textController,
      required this.suggestions,
      this.hintText,
      this.focusNode,
      this.keyboardType,
      this.width});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: textController.value,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        textEditingController.text = textController.text;
        textController.addListener(() {
          if (textController.text != textEditingController.text) {
            textEditingController.value = textController.value;
          }
        });

        textEditingController.addListener(() {
          if (textController.text != textEditingController.text) {
            textController.value = textEditingController.value;
          }
        });
        return Container(
          height: 36,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(4)),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                keyboardType: keyboardType,
                controller: textEditingController,
                focusNode: this.focusNode,
                onSubmitted: (String value) {
                  onFieldSubmitted();
                },
                decoration: InputDecoration(
                    labelText: hintText,
                    border: InputBorder.none,
                    isDense: true),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return List<String>.empty();
        }
        return suggestions.where(
          (String option) {
            return option.contains(textEditingValue.text.toLowerCase());
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      spreadRadius: -1),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      spreadRadius: 0),
                ]),
            width: width,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    onSelected(option);
                  },
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: Colors.black12))),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(option),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
