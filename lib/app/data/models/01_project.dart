// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safety_check/app/data/models/site_check_form.dart';

part '01_project.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class Project {
  @HiveField(0)
  String? seq;
  @HiveField(1)
  String? license_seq;
  @HiveField(2)
  String? user_seq;
  @HiveField(3)
  String? name;
  @HiveField(4)
  String? place_name;
  @HiveField(5)
  String? pic_name;
  @HiveField(6)
  String? pic_tel;
  @HiveField(7)
  String? status;
  @HiveField(8)
  String? jong;
  @HiveField(9)
  String? facility_remark;
  @HiveField(10)
  String? facility_seq;
  @HiveField(11)
  String? check_type;
  @HiveField(12)
  String? ceo_name;
  @HiveField(13)
  String? bizno;
  @HiveField(14)
  String? completion_dt;
  @HiveField(15)
  String? gross_area;
  @HiveField(16)
  String? sido;
  @HiveField(17)
  String? sigungu;
  @HiveField(18)
  String? addr;
  @HiveField(19)
  String? tel;
  @HiveField(20)
  String? contract_dt;
  @HiveField(21)
  String? contract_pic;
  @HiveField(22)
  String? contract_pic_tel;
  @HiveField(23)
  String? contract_pic_email;
  @HiveField(24)
  String? contract_price;
  @HiveField(25)
  String? vat_inc_yn;
  @HiveField(26)
  String? live_tour_url;
  @HiveField(27)
  String? safety_grade;
  @HiveField(28)
  String? color;
  @HiveField(29)
  String? deleted;
  @HiveField(30)
  String? bgn_dt;
  @HiveField(31)
  String? end_dt;
  @HiveField(32)
  String? field_bgn_dt;
  @HiveField(33)
  String? field_end_dt;
  @HiveField(34)
  String? report_dt;
  @HiveField(35)
  String? done_dt;
  @HiveField(36)
  String? requirement;
  @HiveField(37)
  String? note;
  @HiveField(38)
  String? sales_user_seq;
  @HiveField(39)
  String? remark;
  @HiveField(40)
  String? report_no;
  @HiveField(41)
  String? reg_time;
  @HiveField(42)
  String? license_name;
  @HiveField(43)
  String? license_name_abbr;
  @HiveField(44)
  String? facility_name;
  @HiveField(45)
  String? user_seqs;
  @HiveField(46)
  String? engineer_seqs;
  @HiveField(47)
  String? engineer_names;
  @HiveField(48)
  String? drawing_cnt;
  @HiveField(49)
  String? fault_cnt;
  @HiveField(50)
  String? picture_cnt;
  @HiveField(51)
  String? deleted_picture_cnt;
  @HiveField(52)
  String? ground_cnt;
  @HiveField(53)
  String? underground_cnt;
  @HiveField(54)
  String? picture;
  @HiveField(55)
  List<Map<String, dynamic>>? before_list;
  @HiveField(56)
  String? manager_name;
  @HiveField(57)
  String? attachment1;
  @HiveField(58)
  String? attachment2;
  @HiveField(59)
  String? picture_pid;
  @JsonKey(
    fromJson: _parseSiteCheckForm,
    toJson: _siteCheckFormToJson,
  )
  @HiveField(60)
  SiteCheckForm? site_check_form;

  Project({
    this.seq,
    this.license_seq,
    this.user_seq,
    this.name,
    this.place_name,
    this.pic_name,
    this.pic_tel,
    this.status,
    this.jong,
    this.facility_remark,
    this.facility_seq,
    this.check_type,
    this.ceo_name,
    this.bizno,
    this.completion_dt,
    this.gross_area,
    this.sido,
    this.sigungu,
    this.addr,
    this.tel,
    this.contract_dt,
    this.contract_pic,
    this.contract_pic_tel,
    this.contract_pic_email,
    this.contract_price,
    this.vat_inc_yn,
    this.live_tour_url,
    this.safety_grade,
    this.color,
    this.deleted,
    this.bgn_dt,
    this.end_dt,
    this.field_bgn_dt,
    this.field_end_dt,
    this.report_dt,
    this.done_dt,
    this.requirement,
    this.note,
    this.sales_user_seq,
    this.remark,
    this.report_no,
    this.reg_time,
    this.license_name,
    this.license_name_abbr,
    this.facility_name,
    this.user_seqs,
    this.engineer_seqs,
    this.engineer_names,
    this.drawing_cnt,
    this.fault_cnt,
    this.picture_cnt,
    this.deleted_picture_cnt,
    this.ground_cnt,
    this.underground_cnt,
    this.picture,
    this.before_list,
    this.manager_name,
    this.attachment1,
    this.attachment2,
    this.picture_pid,
    this.site_check_form,
  });

  copyWithAppSubmitTime(String? app_submit_time) => Project(
        seq: seq,
        license_seq: license_seq,
        user_seq: user_seq,
        name: name,
        place_name: place_name,
        pic_name: pic_name,
        pic_tel: pic_tel,
        status: status,
        jong: jong,
        facility_remark: facility_remark,
        facility_seq: facility_seq,
        check_type: check_type,
        ceo_name: ceo_name,
        bizno: bizno,
        completion_dt: completion_dt,
        gross_area: gross_area,
        sido: sido,
        sigungu: sigungu,
        addr: addr,
        tel: tel,
        contract_dt: contract_dt,
        contract_pic: contract_pic,
        contract_pic_tel: contract_pic_tel,
        contract_pic_email: contract_pic_email,
        contract_price: contract_price,
        vat_inc_yn: vat_inc_yn,
        live_tour_url: live_tour_url,
        safety_grade: safety_grade,
        color: color,
        deleted: deleted,
        bgn_dt: bgn_dt,
        end_dt: end_dt,
        field_bgn_dt: field_bgn_dt,
        field_end_dt: field_end_dt,
        report_dt: report_dt,
        done_dt: done_dt,
        requirement: requirement,
        note: note,
        sales_user_seq: sales_user_seq,
        remark: remark,
        report_no: report_no,
        reg_time: reg_time,
        license_name: license_name,
        license_name_abbr: license_name_abbr,
        before_list: before_list,
        manager_name: manager_name,
        attachment1: attachment1,
        attachment2: attachment2,
        picture_pid: picture_pid,
        site_check_form: site_check_form,
      );

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

SiteCheckForm? _parseSiteCheckForm(dynamic raw) {
  if (raw == null) return null;

  if (raw is String) {
    try {
      return SiteCheckForm.fromJson(jsonDecode(raw));
    } catch (e) {
      print('❌ site_check_form jsonDecode 실패: $e');
      return null;
    }
  }

  if (raw is Map<String, dynamic>) {
    return SiteCheckForm.fromJson(raw);
  }

  return null;
}

dynamic _siteCheckFormToJson(SiteCheckForm? form) {
  return form?.toJson();
}
