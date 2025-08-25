import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_check/app/data/models/site_check_form.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/photo_box.dart';

class PhotoCheckRow extends StatelessWidget {
  final Children? data;
  final Function onFixingReasonClick;
  const PhotoCheckRow({
    super.key,
    this.data,
    required this.onFixingReasonClick,
  });

  @override
  Widget build(BuildContext context) {
    Future<String?> _showFixingReasonDialog(initialValue) async {
      TextEditingController _controller = TextEditingController(
        text: initialValue ?? '',
      );
      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('보수 사유'),
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: '보수 사유를 입력하세요'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(_controller.text);
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );

      return result;
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "  ${data?.kind}",
                textAlign: TextAlign.start,
              ),
            ),
            TextButton(
              onPressed: () async {
                final fixingReason =
                    await _showFixingReasonDialog(data?.remark);
                print("fixingReason: $fixingReason");
                if (fixingReason != null && fixingReason.isNotEmpty) {
                  onFixingReasonClick(data, fixingReason);
                }
              },
              child: const Text(
                "보수 사유",
                style: TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(bottom: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...?data?.pictures.map(
                  (pic) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PhotoBox(
                        title: pic.title, pid: pic.pid, remark: pic.remark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
