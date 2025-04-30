import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/data/models/site_check_form.dart';

// 공통 picture 리스트
final List<Picture> standardPictures = [
  Picture(title: "정면"),
  Picture(title: "우측"),
  Picture(title: "배면"),
  Picture(title: "좌측"),
  Picture(title: "직접입력"),
];

// 샘플 데이터
final List<InspectionData> categories = [
  InspectionData(
    caption: "외벽마감재",
    children: [
      for (var kind in ["치장벽돌", "타일", "석재", "복합판넬", "노출콘크리트위수성페인트", "직접입력"])
        Children(
          kind: kind,
          pictures: List.from(standardPictures), // 복사해서 넣기
        ),
    ],
  ),
  InspectionData(
    caption: "부대시설",
    children: [
      Children(
        kind: "환기구(덮개상태)",
        pictures: [
          Picture(
            title: "바닥형",
          ),
          Picture(
            title: "벽부형",
          ),
          Picture(
            title: "입상형",
          ),
        ],
      ),
      Children(
        kind: "지반침하 및 도로포장상태",
        pictures: List.from(standardPictures),
      ),
      Children(
        kind: "도로부 신축이음부상태",
        pictures: List.from(standardPictures),
      ),
      Children(
        kind: "옹벽",
      ),
      Children(
        kind: "석축",
      ),
      Children(
        kind: "사면",
      ),
      Children(
        kind: "담장",
      ),
      Children(
        kind: "추락방지(점검로)",
      ),
      Children(
        kind: "추락방지(외부난간)",
      ),
      Children(
        kind: "천창",
      ),
      Children(
        kind: "채광창",
      ),
      Children(
        kind: "현장 메모사항",
      ),
    ],
  ),
  InspectionData(
    caption: "외관사진",
    children: [
      Children(
        kind: "옥탑지붕층",
        pictures: [
          Picture(
            title: "헬리포트",
          ),
          Picture(
            title: "옥탑",
          ),
          Picture(
            title: "지붕층",
          ),
          Picture(
            title: "EV기계실",
          ),
          Picture(
            title: "물탱크실",
          ),
          Picture(
            title: "태양광",
          ),
          Picture(
            title: "직접입력",
          ),
        ],
      ),
      Children(
        kind: "지상층",
        pictures: [
          Picture(
            title: "계단실",
          ),
          Picture(
            title: "복도",
          ),
          Picture(
            title: "EV홀",
          ),
          Picture(
            title: "EV기계실",
          ),
          Picture(
            title: "상층부",
          ),
          Picture(
            title: "주차장",
          ),
          Picture(
            title: "램프",
          ),
          Picture(
            title: "공조실",
          ),
          Picture(
            title: "직접입력",
          ),
        ],
      ),
      Children(
        kind: "지하층",
        pictures: [
          Picture(
            title: "전기실",
          ),
          Picture(
            title: "발전기",
          ),
          Picture(
            title: "기계실",
          ),
          Picture(
            title: "물탱크실",
          ),
          Picture(
            title: "저수조실",
          ),
          Picture(
            title: "지하주차장장",
          ),
          Picture(
            title: "주차장램프",
          ),
          Picture(
            title: "직접입력",
          ),
        ],
      )
    ],
  ),
];

class InspectionCateDropdown extends StatefulWidget {
  final Function onChanged;
  const InspectionCateDropdown({super.key, required this.onChanged});

  @override
  State<InspectionCateDropdown> createState() => _InspectionCateDropdownState();
}

class _InspectionCateDropdownState extends State<InspectionCateDropdown> {
  InspectionData? selectedCategory;
  Children? selectedChild;
  Picture? selectedPictureTitle;

  @override
  void initState() {
    super.initState();
    selectedCategory = categories[0];
    selectedChild = selectedCategory!.children.first;
    selectedPictureTitle = selectedChild?.pictures.first;
  }

  @override
  Widget build(BuildContext context) {
    Future<String?> _showInputDialog() async {
      TextEditingController _controller = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('직접 입력'),
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: '내용을 입력하세요'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 아무 값 없이 닫기
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(_controller.text); // 입력한 값을 pop으로 반환
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );

      return result;
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButton<InspectionData>(
            value: selectedCategory,
            isExpanded: true,
            items: categories
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat.caption),
                    ))
                .toList(),
            onChanged: (newCat) {
              final firstChild = newCat?.children.first;
              setState(() {
                selectedCategory = newCat;
                selectedChild = firstChild;
                selectedPictureTitle = firstChild?.pictures.first;
              });
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: DropdownButton<Children>(
            value: selectedChild,
            isExpanded: true,
            items: selectedCategory?.children
                    .map(
                      (child) => DropdownMenuItem(
                        value: child,
                        child: Text(child.kind),
                      ),
                    )
                    .toList() ??
                [],
            onChanged: (newChild) async {
              if (newChild?.kind == "직접입력") {
                final result = await _showInputDialog();
                if (result != null && result.isNotEmpty) {
                  final customChild = Children(
                    kind: result,
                    pictures: List.from(standardPictures),
                  );

                  setState(() {
                    selectedCategory?.children.add(customChild);
                    selectedChild = customChild;
                    selectedPictureTitle = customChild.pictures.first;
                  });
                }
              } else {
                setState(() {
                  selectedChild = newChild;
                  selectedPictureTitle = newChild?.pictures.first;
                });
              }
            },
          ),
        ),
        SizedBox(width: 12),
        if ((selectedChild?.pictures ?? []).isNotEmpty)
          Expanded(
            child: DropdownButton<Picture>(
              value: selectedPictureTitle,
              isExpanded: true,
              items: (selectedChild?.pictures ?? [])
                  .map(
                    (pic) => DropdownMenuItem(
                      value: pic,
                      child: Text(pic.title),
                    ),
                  )
                  .toList(),
              onChanged: (newTitle) async {
                if (newTitle?.title == "직접입력") {
                  final resultTitle = await _showInputDialog();
                  if (resultTitle != null && resultTitle.isNotEmpty) {
                    final customPic = Picture(
                      title: resultTitle,
                    );

                    setState(() {
                      selectedChild?.pictures.add(customPic);
                      selectedPictureTitle = customPic; // ✅ 새로 추가한 Picture를 선택
                    });
                  }
                } else {
                  setState(() {
                    selectedPictureTitle = newTitle;
                  });
                }
              },
            ),
          )
        else
          SizedBox(
            width: 0,
          ), // 아무것도 안 보여주기
        SizedBox(width: 12),
        MaterialButton(
          onPressed: () {
            widget.onChanged(selectedCategory?.caption, selectedChild?.kind,
                selectedPictureTitle?.title);
          },
          color: AppColors.button,
          child: Text(
            "사진 촬영",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Pretendard",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
