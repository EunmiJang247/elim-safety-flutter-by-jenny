// ignore_for_file: non_constant_identifier_names

// import 'package:device_information/device_information.dart';

import 'package:dio/dio.dart';
import 'package:safety_check/app/data/models/04_fault.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/models/09_appended.dart';
import 'package:safety_check/app/data/models/11_drawing_memo.dart';

import '../../utils/log.dart';
import '../api/app_api.dart';
import '../models/03_marker.dart';
import '../models/base_response.dart';
import '../models/02_drawing.dart';
import '../models/01_project.dart';
import 'dart:convert';

class AppRepository {
  AppRepository({required AppAPI appAPI}) : _appAPI = appAPI;
  final AppAPI _appAPI;

  // Map<String, dynamic> readAndroidBuildData() {
  //   return <String, dynamic>{
  //     'platformVersion': DeviceInformation.platformVersion,
  //     'apiLevel': DeviceInformation.apiLevel,
  //     'cpuName': DeviceInformation.cpuName,
  //     'deviceIMEINumber': DeviceInformation.deviceIMEINumber,
  //     'deviceManufacturer': DeviceInformation.deviceManufacturer,
  //     'deviceModel': DeviceInformation.deviceModel,
  //     'deviceName': DeviceInformation.deviceName,
  //     'hardware': DeviceInformation.hardware,
  //     'productName': DeviceInformation.productName,
  //   };
  // }

  // 시작
  Future<BaseResponse?> init() async {
    BaseResponse? response;
    try {
      var body = <String, dynamic>{};
      response = await _appAPI.client.init(body);
    } catch (err) {
      logError(err, des: 'AppRepository.init()');
    }
    return response;
  }

  Future<BaseResponse?> test() async {
    BaseResponse? response;
    try {
      var body = <String, dynamic>{};
      response = await _appAPI.client.test(body);
    } catch (err) {
      logError(err, des: 'AppRepository.test()');
    }
    return response;
  }

  // 로그인
  Future<BaseResponse?> signIn({
    required String email,
    required String password,
  }) async {
    //String sha1Pw = sha1Encode(password);
    BaseResponse? response;
    try {
      Map<String, dynamic> body = {
        "email": email,
        "passwd": password,
      };
      response = await _appAPI.client.signIn(body);
    } catch (err) {
      logError(err, des: 'AppRepository.signIn(email:$email)');
    }
    return response;
  }

  // 로그아웃
  Future<BaseResponse?> logOut() async {
    BaseResponse? response;
    try {
      response = await _appAPI.client.logOut();
    } catch (err) {
      logError(err, des: 'AppRepository.logOut()');
    }
    return response;
  }

  // 비밀번호 찾기
  Future<String?> findPw({
    required String email,
  }) async {
    String? result;
    try {
      Map<String, dynamic> body = {
        "email": email,
      };
      BaseResponse? response = await _appAPI.client.findPw(body);
      result = response?.result?.message;
    } catch (err) {
      logError(err, des: 'AppRepository.findPw(email:$email)');
    }
    return result;
  }

  // 현장 목록 불러오기
  Future<List<Project>?> searchProjectList(
      {required String? q, int my = 0}) async {
    List<Project>? result;
    try {
      Map<String, dynamic> body = {"my": my};
      if (q != null) {
        body["q"] = q;
      }
      BaseResponse? response = await _appAPI.client.getProjectList(body);
      result =
          (response?.data as List).map((e) => Project.fromJson(e)).toList();
    } catch (err) {
      logError(err, des: 'AppRepository.searchProjectList(my: $my, q:$q)');
    }

    // 현장투입 시작일 기준 정렬
    if (result != null) {
      result.sort((a, b) => DateTime.parse(b.field_bgn_dt ?? '2000-01-01')
          .millisecondsSinceEpoch
          .compareTo(DateTime.parse(a.field_bgn_dt ?? '2000-01-01')
              .millisecondsSinceEpoch));
    }
    return result;
  }

  Future<Map?> submitProject({required Project project}) async {
    Map result = {};
    try {
      Map<String, dynamic> body = {
        "seq": project.seq,
        "requirement": project.requirement,
        "siteCheckForm": jsonEncode(project.site_check_form?.toJson()),
      };
      BaseResponse? response = await _appAPI.client.submitProject(body);
      project = Project.fromJson(response?.data);
    } catch (err) {
      logError(err, des: 'AppRepository.submitProject()');
    }

    return result;
  }

  Future<List<Drawing>?> searchDrawingList(
      {required String? projectSeq}) async {
    List<Drawing>? result;
    try {
      Map<String, dynamic> body = {"project_seq": projectSeq};
      BaseResponse? response = await _appAPI.client.getDrawingList(body);
      result =
          (response?.data as List).map((e) => Drawing.fromJson(e)).toList();
    } catch (err) {
      logError(err,
          des: 'AppRepository.searchDrawingList(project_seq: $projectSeq)');
    }

    // 현장투입 시작일 기준 정렬
    if (result != null) {
      result.sort((a, b) => DateTime.parse(b.reg_time ?? '2000-01-01')
          .millisecondsSinceEpoch
          .compareTo(DateTime.parse(a.reg_time ?? '2000-01-01')
              .millisecondsSinceEpoch));
    }
    return result;
  }

  // 도면 메모 저장
  Future<DrawingMemo?> submitDrawingMemo({required DrawingMemo memo}) async {
    DrawingMemo? result;
    try {
      Map<String, dynamic> body = {
        "seq": memo.seq,
        "drawing_seq": memo.drawing_seq,
        "pid": memo.pid,
        "memo": memo.memo,
        "x": memo.x,
        "y": memo.y,
      };
      BaseResponse? response = await _appAPI.client.submitDrawingMemo(body);
      if (response?.result?.code != 100) {
        throw Exception(response!.result!.message);
      }
      result = DrawingMemo.fromJson(response?.data);
    } catch (err) {
      logError(err, des: 'AppRepository.submitDrawingMemo()');
    }

    return result;
  }

  // 도면 메모 삭제
  Future<List<Drawing>?> deleteDrawingMemo({required String? memoSeq}) async {
    List<Drawing>? result;
    try {
      Map<String, dynamic> body = {"seq": memoSeq};
      await _appAPI.client.deleteDrawingMemo(body);
    } catch (err) {
      logError(err, des: 'AppRepository.searchDrawingList(seq: $memoSeq)');
    }
    return result;
  }

  Future<String?> copyDrawing({required String? seq}) async {
    String? result;
    try {
      Map<String, dynamic> body = {"seq": seq};
      BaseResponse? response = await _appAPI.client.copyDrawing(body);
      result = response?.result?.message;
    } catch (err) {
      logError(err, des: 'AppRepository.searchDrawingList(seq: $seq)');
    }
    return result;
  }

  Future<List<Marker>?> searchMarkerList({
    String? projectSeq,
    String? drawingSeq,
    String? mid,
  }) async {
    List<Marker>? result;
    try {
      Map<String, dynamic> body = {
        "project_seq": projectSeq ?? "",
        "drawing_seq": drawingSeq ?? "",
      };
      if (mid != null) {
        body["mid"] = mid;
      }
      BaseResponse? response = await _appAPI.client.getMarkerList(body);
      result = (response?.data as List).map((e) => Marker.fromJson(e)).toList();
    } catch (err) {
      logError(err,
          des:
              'AppRepository.searchMarkerList(project_seq: $projectSeq, drawing_seq: $drawingSeq, mid: $mid)');
    }

    // 현장투입 시작일 기준 정렬
    if (result != null) {
      result.sort((a, b) => DateTime.parse(b.reg_time ?? '2000-01-01')
          .millisecondsSinceEpoch
          .compareTo(DateTime.parse(a.reg_time ?? '2000-01-01')
              .millisecondsSinceEpoch));
    }
    return result;
  }

  Future<String?> sortMarker({required String? drawingSeq}) async {
    String? result;
    try {
      Map<String, dynamic> body = {"drawing_seq": drawingSeq};
      BaseResponse? response = await _appAPI.client.sortMarker(body);
      result = response?.result?.message;
    } catch (err) {
      logError(err, des: 'AppRepository.searchDrawingList(seq: $drawingSeq)');
    }
    return result;
  }

  Future<Map?> submitMarker(
      {required bool isNew,
      required Marker marker,
      String? lastFaultSeq,
      String? markerSize}) async {
    Map result = {};
    try {
      Map<String, dynamic> body = {
        "x": marker.x,
        "y": marker.y,
        "outline_color": marker.outline_color,
        "foreground_color": marker.foreground_color,
        "no": marker.no,
        "last_fault_seq": lastFaultSeq,
        "marker_size": markerSize
      };
      if (isNew) {
        body["drawing_seq"] = marker.drawing_seq;
        body["mid"] = marker.mid;
      } else {
        body["seq"] = marker.seq;
      }
      BaseResponse? response = await _appAPI.client.submitMarker(body);
      result["marker"] = Marker.fromJson(response?.data["marker"]);
      if (response?.data["appended"] != null) {
        result["appended"] = Appended.fromJson(response?.data["appended"]);
      }
    } catch (err) {
      logError(err,
          des:
              'AppRepository.submitMarker(drawing_seq: ${marker.drawing_seq}, x: ${marker.x}, y: ${marker.y}, last_fault_seq: $lastFaultSeq)');
    }

    return result;
  }

  Future<Appended?> deleteMarker(
      {required String seq, String? lastFaultSeq}) async {
    Appended? result;
    try {
      Map<String, dynamic> body = {
        "seq": seq,
        "last_fault_seq": lastFaultSeq,
      };
      BaseResponse? response = await _appAPI.client.deleteMarker(body);
      result = Appended.fromJson(response?.data["appended"]);
    } catch (err) {
      logError(err,
          des:
              'AppRepository.deleteMarker(drawing_seq: $seq, last_fault_seq: $lastFaultSeq)');
    }

    return result;
  }

  Future<Appended?> overrideMarker(
      {required String fromSeq,
      required String toSeq,
      String? lastFaultSeq}) async {
    Appended? result;
    try {
      Map<String, dynamic> body = {
        "from_seq": fromSeq,
        "to_seq": toSeq,
        "last_fault_seq": lastFaultSeq,
      };
      BaseResponse? response = await _appAPI.client.overrideMarker(body);
      result = Appended.fromJson(response?.data["appended"]);
    } catch (err) {
      logError(err,
          des:
              'AppRepository.overrideMarker(from_seq: $fromSeq, to_seq: $toSeq, last_fault_seq: $lastFaultSeq)');
    }

    return result;
  }

  Future<Map?> mergeMarker(
      {required String fromSeq,
      required String toSeq,
      String? lastFaultSeq}) async {
    Map? result;
    try {
      Map<String, dynamic> body = {
        "from_seq": fromSeq,
        "to_seq": toSeq,
        "last_fault_seq": lastFaultSeq,
      };
      BaseResponse? response = await _appAPI.client.mergeMarker(body);
      result?["marker"] = Marker.fromJson(response?.data["marker"]);
      result?["fault"] = Fault.fromJson(response?.data["fault"]);
      if (response?.data["appended"] != null) {
        result?["appended"] = Appended.fromJson(response?.data["appended"]);
      }
    } catch (err) {
      logError(err,
          des:
              'AppRepository.mergeMarker(from_seq: $fromSeq, to_seq: $toSeq, last_fault_seq: $lastFaultSeq)');
    }

    return result;
  }

  Future<Map> submitFault(
      {required bool isNew,
      required Fault fault,
      String? mid,
      String? lastFaultSeq}) async {
    Map result = {};
    try {
      Map<String, dynamic> body = {
        "mid": mid,
        "x": fault.x,
        "y": fault.y,
        "color": fault.color,
        "location": fault.location,
        "elem": fault.elem,
        "elem_seq": fault.elem_seq,
        "cate1_seq": fault.cate1_seq,
        "cate2": fault.cate2,
        "width": fault.width,
        "length": fault.length,
        "qty": fault.qty,
        "structure": fault.structure,
        "status": fault.status,
        "ing_yn": fault.ing_yn,
        "group_fid": fault.group_fid ?? fault.fid,
        "cause": fault.cause,
        "fid": fault.fid,
        "note": fault.note,
        "last_fault_seq": lastFaultSeq,
      };
      if (isNew) {
        body["drawing_seq"] = fault.drawing_seq;
      } else {
        body["seq"] = fault.seq;
      }

      BaseResponse? response = await _appAPI.client.submitFault(body);
      result["fault"] = Fault.fromJson(response?.data["fault"]);
      if (response?.data["marker"] != null) {
        result["marker"] = Marker.fromJson(response?.data["marker"]);
      }
      if (response?.data["appended"] != null) {
        result["appended"] = Appended.fromJson(response?.data["appended"]);
      }
    } catch (err) {
      logError(err,
          des:
              'AppRepository.submitFault(drawing_seq: ${fault.drawing_seq}, x: ${fault.x}, y: ${fault.y}, last_fault_seq: $lastFaultSeq)');
    }

    return result;
  }

  Future<Appended?> deleteFault(
      {required String seq, String? lastFaultSeq}) async {
    Appended? result;
    try {
      Map<String, dynamic> body = {
        "seq": seq,
        "last_fault_seq": lastFaultSeq,
      };
      BaseResponse? response = await _appAPI.client.deleteFault(body);
      result = Appended.fromJson(response?.data["appended"]);
    } catch (err) {
      logError(err,
          des:
              'AppRepository.deleteFault(fault_seq: $seq, last_fault_seq: $lastFaultSeq)');
    }

    return result;
  }

  // 현장 목록 불러오기
  Future<List<CustomPicture>?> searchPicture(
      {required String? projectSeq}) async {
    List<CustomPicture>? result;
    try {
      Map<String, dynamic> body = {"project_seq": projectSeq};
      BaseResponse? response = await _appAPI.client.getPicture(body);
      result = (response?.data as List)
          .map((e) => CustomPicture.fromJson(e))
          .toList();
    } catch (err) {
      logError(err,
          des: 'AppRepository.searchProjectList(project_seq: $projectSeq)');
    }

    return result;
  }

  Future<BaseResponse?> uploadPicture({
    required CustomPicture newPicture,
  }) async {
    BaseResponse? result;
    try {
      Map<String, dynamic> data = {
        'pid': newPicture.pid,
        'project_seq': newPicture.project_seq,
        'drawing_seq': newPicture.drawing_seq,
        'userfile': await MultipartFile.fromFile(newPicture.file_path!,
            filename: newPicture.file_name),
        'fid': newPicture.fid,
        'kind': newPicture.kind,
        'location': newPicture.location
      };
      FormData formData = FormData.fromMap(data);

      result = await _appAPI.client.uploadPicture(formData);
    } catch (err) {
      logError(err,
          des:
              'AppRepository.uploadPicture(file_name:${newPicture.file_name}, fid:${newPicture.fid})');
    }
    return result;
  }

  Future<BaseResponse?> updatePicture(
      {required String seq,
      required String? kind,
      required String? pid,
      String? drawingSeq,
      String? location}) async {
    BaseResponse? result;
    try {
      Map<String, dynamic> body = {
        "seq": seq,
        "kind": kind,
        "pid": pid,
        "drawing_seq": drawingSeq,
        "location": location
      };
      result = await _appAPI.client.updatePicture(body);
    } catch (err) {
      logError(err,
          des:
              'AppRepository.updatePicture(seq: $seq, kind: $kind, pid: $pid)');
    }

    return result;
  }

  Future<BaseResponse?> deletePicture({required String seq}) async {
    BaseResponse? result;
    try {
      Map<String, dynamic> body = {
        "seq": seq,
      };
      BaseResponse? response = await _appAPI.client.deletePicture(body);
      result = response;
    } catch (err) {
      logError(err, des: 'AppRepository.deletePicture(seq: $seq)');
    }

    return result;
  }

  Future<int?> addFaultCate1({required String name}) async {
    int? result;
    try {
      BaseResponse? response =
          await _appAPI.client.addFaultCate1({"name": name});
      result = response?.data;
    } catch (err) {
      logError(err, des: 'AppRepository.addFaultCate1(name: $name)');
    }
    return result;
  }

  Future<int?> addFaultCate2({required String name}) async {
    int? result;
    try {
      BaseResponse? response =
          await _appAPI.client.addFaultCate2({"name": name});
      result = response?.data;
    } catch (err) {
      logError(err, des: 'AppRepository.addFaultCate2(name: $name)');
    }
    return result;
  }

  Future<int?> addFaultElem({required String name}) async {
    int? result;
    try {
      BaseResponse? response =
          await _appAPI.client.addFaultElem({"name": name});
      result = response?.data;
    } catch (err) {
      logError(err, des: 'AppRepository.addFaultElem(name: $name)');
    }
    return result;
  }
}
