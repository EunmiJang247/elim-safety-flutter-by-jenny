class SiteCheckForm {
  String inspectorName;
  String inspectionDate;
  List<InspectionData> data;

  SiteCheckForm({
    required this.inspectorName,
    required this.inspectionDate,
    required this.data,
  });

  factory SiteCheckForm.fromJson(Map<String, dynamic> json) {
    return SiteCheckForm(
      inspectorName: json['inspectorName'],
      inspectionDate: json['inspectionDate'],
      data: (json['data'] as List)
          .map((e) => InspectionData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'inspectorName': inspectorName,
        'inspectionDate': inspectionDate,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class InspectionData {
  final String caption;
  final List<Children> children;

  InspectionData({
    required this.caption,
    required this.children,
  });

  factory InspectionData.fromJson(Map<String, dynamic> json) {
    return InspectionData(
      caption: json['caption'],
      children:
          (json['children'] as List).map((e) => Children.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'caption': caption,
        'children': children.map((e) => e.toJson()).toList(),
      };
}

class Children {
  final String kind;
  final List<Picture> pictures;
  final String? remark;

  Children({
    required this.kind,
    List<Picture>? pictures,
    this.remark,
  }) : pictures = pictures ?? [];

  factory Children.fromJson(Map<String, dynamic> json) {
    return Children(
      kind: json['kind'],
      pictures:
          (json['pictures'] as List).map((e) => Picture.fromJson(e)).toList(),
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'pictures': pictures.map((e) => e.toJson()).toList(),
        'remark': remark,
      };
}

class Picture {
  final String title;
  String? pid;
  String? remark;

  Picture({
    required this.title,
    this.pid,
    this.remark,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      title: json['title'],
      pid: json['pid'] ?? '',
      remark: json['remark'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'pid': pid,
        'remark': remark,
      };
}
