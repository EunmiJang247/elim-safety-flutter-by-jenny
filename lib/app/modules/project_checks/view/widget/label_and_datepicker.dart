import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/utils/log.dart';

class LabelAndDatePicker extends StatefulWidget {
  const LabelAndDatePicker(
      {super.key,
      required this.label,
      this.text,
      this.onDateTap,
      required this.onDateChange});

  final String label;
  final String? text;
  final VoidCallback? onDateTap;
  final Function onDateChange;

  @override
  State<LabelAndDatePicker> createState() => _LabelAndDatePickerState();
}

class _LabelAndDatePickerState extends State<LabelAndDatePicker> {
  late DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();

    final parsed = DateTime.tryParse(widget.text ?? '');
    if (parsed != null) {
      _selectedDate = parsed;
    } else {
      _selectedDate = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(
        widget.label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      const SizedBox(width: 8),
      Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
        ),
        child: TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
                locale: const Locale('ko'),
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(1950),
                lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.button,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      dialogTheme: const DialogTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                });

            widget.onDateTap!();

            if (picked != null) {
              logInfo(picked);
              setState(() {
                _selectedDate = picked;
              });
              widget.onDateChange(_selectedDate);
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 4, right: 10, bottom: 3),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: _selectedDate != null
              ? Text(
                  DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                )
              : Row(
                  children: [
                    Text(
                      "날짜 선택",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
        ),
      ),
    ]);
  }
}
