// GENERATED CODE - DO NOT MODIFY BY HAND

part of '01_project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 1;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      seq: fields[0] as String?,
      license_seq: fields[1] as String?,
      user_seq: fields[2] as String?,
      name: fields[3] as String?,
      place_name: fields[4] as String?,
      pic_name: fields[5] as String?,
      pic_tel: fields[6] as String?,
      status: fields[7] as String?,
      jong: fields[8] as String?,
      facility_remark: fields[9] as String?,
      facility_seq: fields[10] as String?,
      check_type: fields[11] as String?,
      ceo_name: fields[12] as String?,
      bizno: fields[13] as String?,
      completion_dt: fields[14] as String?,
      gross_area: fields[15] as String?,
      sido: fields[16] as String?,
      sigungu: fields[17] as String?,
      addr: fields[18] as String?,
      tel: fields[19] as String?,
      contract_dt: fields[20] as String?,
      contract_pic: fields[21] as String?,
      contract_pic_tel: fields[22] as String?,
      contract_pic_email: fields[23] as String?,
      contract_price: fields[24] as String?,
      vat_inc_yn: fields[25] as String?,
      live_tour_url: fields[26] as String?,
      safety_grade: fields[27] as String?,
      color: fields[28] as String?,
      deleted: fields[29] as String?,
      bgn_dt: fields[30] as String?,
      end_dt: fields[31] as String?,
      field_bgn_dt: fields[32] as String?,
      field_end_dt: fields[33] as String?,
      report_dt: fields[34] as String?,
      done_dt: fields[35] as String?,
      requirement: fields[36] as String?,
      note: fields[37] as String?,
      sales_user_seq: fields[38] as String?,
      remark: fields[39] as String?,
      report_no: fields[40] as String?,
      reg_time: fields[41] as String?,
      license_name: fields[42] as String?,
      license_name_abbr: fields[43] as String?,
      facility_name: fields[44] as String?,
      user_seqs: fields[45] as String?,
      engineer_seqs: fields[46] as String?,
      engineer_names: fields[47] as String?,
      drawing_cnt: fields[48] as String?,
      fault_cnt: fields[49] as String?,
      picture_cnt: fields[50] as String?,
      deleted_picture_cnt: fields[51] as String?,
      ground_cnt: fields[52] as String?,
      underground_cnt: fields[53] as String?,
      picture: fields[54] as String?,
      before_list: (fields[55] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      manager_name: fields[56] as String?,
      attachment1: fields[57] as String?,
      attachment2: fields[58] as String?,
      picture_pid: fields[59] as String?,
      site_check_form: fields[60] as SiteCheckForm?,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(61)
      ..writeByte(0)
      ..write(obj.seq)
      ..writeByte(1)
      ..write(obj.license_seq)
      ..writeByte(2)
      ..write(obj.user_seq)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.place_name)
      ..writeByte(5)
      ..write(obj.pic_name)
      ..writeByte(6)
      ..write(obj.pic_tel)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.jong)
      ..writeByte(9)
      ..write(obj.facility_remark)
      ..writeByte(10)
      ..write(obj.facility_seq)
      ..writeByte(11)
      ..write(obj.check_type)
      ..writeByte(12)
      ..write(obj.ceo_name)
      ..writeByte(13)
      ..write(obj.bizno)
      ..writeByte(14)
      ..write(obj.completion_dt)
      ..writeByte(15)
      ..write(obj.gross_area)
      ..writeByte(16)
      ..write(obj.sido)
      ..writeByte(17)
      ..write(obj.sigungu)
      ..writeByte(18)
      ..write(obj.addr)
      ..writeByte(19)
      ..write(obj.tel)
      ..writeByte(20)
      ..write(obj.contract_dt)
      ..writeByte(21)
      ..write(obj.contract_pic)
      ..writeByte(22)
      ..write(obj.contract_pic_tel)
      ..writeByte(23)
      ..write(obj.contract_pic_email)
      ..writeByte(24)
      ..write(obj.contract_price)
      ..writeByte(25)
      ..write(obj.vat_inc_yn)
      ..writeByte(26)
      ..write(obj.live_tour_url)
      ..writeByte(27)
      ..write(obj.safety_grade)
      ..writeByte(28)
      ..write(obj.color)
      ..writeByte(29)
      ..write(obj.deleted)
      ..writeByte(30)
      ..write(obj.bgn_dt)
      ..writeByte(31)
      ..write(obj.end_dt)
      ..writeByte(32)
      ..write(obj.field_bgn_dt)
      ..writeByte(33)
      ..write(obj.field_end_dt)
      ..writeByte(34)
      ..write(obj.report_dt)
      ..writeByte(35)
      ..write(obj.done_dt)
      ..writeByte(36)
      ..write(obj.requirement)
      ..writeByte(37)
      ..write(obj.note)
      ..writeByte(38)
      ..write(obj.sales_user_seq)
      ..writeByte(39)
      ..write(obj.remark)
      ..writeByte(40)
      ..write(obj.report_no)
      ..writeByte(41)
      ..write(obj.reg_time)
      ..writeByte(42)
      ..write(obj.license_name)
      ..writeByte(43)
      ..write(obj.license_name_abbr)
      ..writeByte(44)
      ..write(obj.facility_name)
      ..writeByte(45)
      ..write(obj.user_seqs)
      ..writeByte(46)
      ..write(obj.engineer_seqs)
      ..writeByte(47)
      ..write(obj.engineer_names)
      ..writeByte(48)
      ..write(obj.drawing_cnt)
      ..writeByte(49)
      ..write(obj.fault_cnt)
      ..writeByte(50)
      ..write(obj.picture_cnt)
      ..writeByte(51)
      ..write(obj.deleted_picture_cnt)
      ..writeByte(52)
      ..write(obj.ground_cnt)
      ..writeByte(53)
      ..write(obj.underground_cnt)
      ..writeByte(54)
      ..write(obj.picture)
      ..writeByte(55)
      ..write(obj.before_list)
      ..writeByte(56)
      ..write(obj.manager_name)
      ..writeByte(57)
      ..write(obj.attachment1)
      ..writeByte(58)
      ..write(obj.attachment2)
      ..writeByte(59)
      ..write(obj.picture_pid)
      ..writeByte(60)
      ..write(obj.site_check_form);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      seq: json['seq'] as String?,
      license_seq: json['license_seq'] as String?,
      user_seq: json['user_seq'] as String?,
      name: json['name'] as String?,
      place_name: json['place_name'] as String?,
      pic_name: json['pic_name'] as String?,
      pic_tel: json['pic_tel'] as String?,
      status: json['status'] as String?,
      jong: json['jong'] as String?,
      facility_remark: json['facility_remark'] as String?,
      facility_seq: json['facility_seq'] as String?,
      check_type: json['check_type'] as String?,
      ceo_name: json['ceo_name'] as String?,
      bizno: json['bizno'] as String?,
      completion_dt: json['completion_dt'] as String?,
      gross_area: json['gross_area'] as String?,
      sido: json['sido'] as String?,
      sigungu: json['sigungu'] as String?,
      addr: json['addr'] as String?,
      tel: json['tel'] as String?,
      contract_dt: json['contract_dt'] as String?,
      contract_pic: json['contract_pic'] as String?,
      contract_pic_tel: json['contract_pic_tel'] as String?,
      contract_pic_email: json['contract_pic_email'] as String?,
      contract_price: json['contract_price'] as String?,
      vat_inc_yn: json['vat_inc_yn'] as String?,
      live_tour_url: json['live_tour_url'] as String?,
      safety_grade: json['safety_grade'] as String?,
      color: json['color'] as String?,
      deleted: json['deleted'] as String?,
      bgn_dt: json['bgn_dt'] as String?,
      end_dt: json['end_dt'] as String?,
      field_bgn_dt: json['field_bgn_dt'] as String?,
      field_end_dt: json['field_end_dt'] as String?,
      report_dt: json['report_dt'] as String?,
      done_dt: json['done_dt'] as String?,
      requirement: json['requirement'] as String?,
      note: json['note'] as String?,
      sales_user_seq: json['sales_user_seq'] as String?,
      remark: json['remark'] as String?,
      report_no: json['report_no'] as String?,
      reg_time: json['reg_time'] as String?,
      license_name: json['license_name'] as String?,
      license_name_abbr: json['license_name_abbr'] as String?,
      facility_name: json['facility_name'] as String?,
      user_seqs: json['user_seqs'] as String?,
      engineer_seqs: json['engineer_seqs'] as String?,
      engineer_names: json['engineer_names'] as String?,
      drawing_cnt: json['drawing_cnt'] as String?,
      fault_cnt: json['fault_cnt'] as String?,
      picture_cnt: json['picture_cnt'] as String?,
      deleted_picture_cnt: json['deleted_picture_cnt'] as String?,
      ground_cnt: json['ground_cnt'] as String?,
      underground_cnt: json['underground_cnt'] as String?,
      picture: json['picture'] as String?,
      before_list: (json['before_list'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      manager_name: json['manager_name'] as String?,
      attachment1: json['attachment1'] as String?,
      attachment2: json['attachment2'] as String?,
      picture_pid: json['picture_pid'] as String?,
      site_check_form: _parseSiteCheckForm(json['site_check_form']),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'seq': instance.seq,
      'license_seq': instance.license_seq,
      'user_seq': instance.user_seq,
      'name': instance.name,
      'place_name': instance.place_name,
      'pic_name': instance.pic_name,
      'pic_tel': instance.pic_tel,
      'status': instance.status,
      'jong': instance.jong,
      'facility_remark': instance.facility_remark,
      'facility_seq': instance.facility_seq,
      'check_type': instance.check_type,
      'ceo_name': instance.ceo_name,
      'bizno': instance.bizno,
      'completion_dt': instance.completion_dt,
      'gross_area': instance.gross_area,
      'sido': instance.sido,
      'sigungu': instance.sigungu,
      'addr': instance.addr,
      'tel': instance.tel,
      'contract_dt': instance.contract_dt,
      'contract_pic': instance.contract_pic,
      'contract_pic_tel': instance.contract_pic_tel,
      'contract_pic_email': instance.contract_pic_email,
      'contract_price': instance.contract_price,
      'vat_inc_yn': instance.vat_inc_yn,
      'live_tour_url': instance.live_tour_url,
      'safety_grade': instance.safety_grade,
      'color': instance.color,
      'deleted': instance.deleted,
      'bgn_dt': instance.bgn_dt,
      'end_dt': instance.end_dt,
      'field_bgn_dt': instance.field_bgn_dt,
      'field_end_dt': instance.field_end_dt,
      'report_dt': instance.report_dt,
      'done_dt': instance.done_dt,
      'requirement': instance.requirement,
      'note': instance.note,
      'sales_user_seq': instance.sales_user_seq,
      'remark': instance.remark,
      'report_no': instance.report_no,
      'reg_time': instance.reg_time,
      'license_name': instance.license_name,
      'license_name_abbr': instance.license_name_abbr,
      'facility_name': instance.facility_name,
      'user_seqs': instance.user_seqs,
      'engineer_seqs': instance.engineer_seqs,
      'engineer_names': instance.engineer_names,
      'drawing_cnt': instance.drawing_cnt,
      'fault_cnt': instance.fault_cnt,
      'picture_cnt': instance.picture_cnt,
      'deleted_picture_cnt': instance.deleted_picture_cnt,
      'ground_cnt': instance.ground_cnt,
      'underground_cnt': instance.underground_cnt,
      'picture': instance.picture,
      'before_list': instance.before_list,
      'manager_name': instance.manager_name,
      'attachment1': instance.attachment1,
      'attachment2': instance.attachment2,
      'picture_pid': instance.picture_pid,
      'site_check_form': _siteCheckFormToJson(instance.site_check_form),
    };
