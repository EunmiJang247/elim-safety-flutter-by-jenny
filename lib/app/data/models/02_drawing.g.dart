// GENERATED CODE - DO NOT MODIFY BY HAND

part of '02_drawing.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawingAdapter extends TypeAdapter<Drawing> {
  @override
  final int typeId = 2;

  @override
  Drawing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Drawing(
      seq: fields[0] as String?,
      project_seq: fields[1] as String?,
      dong: fields[2] as String?,
      floor: fields[3] as String?,
      file_path: fields[4] as String?,
      file_name: fields[5] as String?,
      file_size: fields[6] as String?,
      thumb: fields[7] as String?,
      deleted: fields[8] as String?,
      reg_time: fields[9] as String?,
      update_time: fields[10] as String?,
      marker_size: fields[11] as String?,
      floor_name: fields[12] as String?,
      name: fields[13] as String?,
      memo_list: (fields[14] as List).cast<DrawingMemo>(),
    );
  }

  @override
  void write(BinaryWriter writer, Drawing obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.seq)
      ..writeByte(1)
      ..write(obj.project_seq)
      ..writeByte(2)
      ..write(obj.dong)
      ..writeByte(3)
      ..write(obj.floor)
      ..writeByte(4)
      ..write(obj.file_path)
      ..writeByte(5)
      ..write(obj.file_name)
      ..writeByte(6)
      ..write(obj.file_size)
      ..writeByte(7)
      ..write(obj.thumb)
      ..writeByte(8)
      ..write(obj.deleted)
      ..writeByte(9)
      ..write(obj.reg_time)
      ..writeByte(10)
      ..write(obj.update_time)
      ..writeByte(11)
      ..write(obj.marker_size)
      ..writeByte(12)
      ..write(obj.floor_name)
      ..writeByte(13)
      ..write(obj.name)
      ..writeByte(14)
      ..write(obj.memo_list);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Drawing _$DrawingFromJson(Map<String, dynamic> json) => Drawing(
      seq: json['seq'] as String?,
      project_seq: json['project_seq'] as String?,
      dong: json['dong'] as String?,
      floor: json['floor'] as String?,
      file_path: json['file_path'] as String?,
      file_name: json['file_name'] as String?,
      file_size: json['file_size'] as String?,
      thumb: json['thumb'] as String?,
      deleted: json['deleted'] as String?,
      reg_time: json['reg_time'] as String?,
      update_time: json['update_time'] as String?,
      marker_size: json['marker_size'] as String?,
      floor_name: json['floor_name'] as String?,
      name: json['name'] as String?,
      memo_list: (json['memo_list'] as List<dynamic>?)
              ?.map((e) => DrawingMemo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DrawingToJson(Drawing instance) => <String, dynamic>{
      'seq': instance.seq,
      'project_seq': instance.project_seq,
      'dong': instance.dong,
      'floor': instance.floor,
      'file_path': instance.file_path,
      'file_name': instance.file_name,
      'file_size': instance.file_size,
      'thumb': instance.thumb,
      'deleted': instance.deleted,
      'reg_time': instance.reg_time,
      'update_time': instance.update_time,
      'marker_size': instance.marker_size,
      'floor_name': instance.floor_name,
      'name': instance.name,
      'memo_list': instance.memo_list,
    };
