import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/label_and_datepicker.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/label_and_textinput.dart';

class ProjectChecksInfo extends StatelessWidget {
  const ProjectChecksInfo(
      {super.key,
      this.inspectorName,
      this.inspectionDate,
      required this.inspectorNameController,
      required this.inspectorNameFocus,
      required this.onDateChange});

  final String? inspectorName;
  final String? inspectionDate;
  final TextEditingController inspectorNameController;
  final FocusNode inspectorNameFocus;
  final Function onDateChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        Row(children: [
          LabelAndTextinput(
              controller: inspectorNameController,
              text: inspectorName,
              label: '점검자명 :',
              focusNode: inspectorNameFocus),
          SizedBox(width: 16.w),
          LabelAndDatePicker(
            text: inspectionDate,
            label: '점검 일자 :',
            onDateTap: () => inspectorNameFocus.unfocus(),
            onDateChange: onDateChange,
          ),
        ]),
      ]),
    );
  }
}
