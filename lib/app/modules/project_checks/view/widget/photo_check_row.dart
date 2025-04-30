import 'package:flutter/cupertino.dart';
import 'package:safety_check/app/data/models/site_check_form.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/photo_box.dart';

class PhotoCheckRow extends StatelessWidget {
  final Children? data;
  const PhotoCheckRow({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(bottom: 10),
          child: Text(
            "  ${data?.kind}",
            textAlign: TextAlign.start,
          ),
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
