// ignore_for_file: non_constant_identifier_names

import 'package:safety_check/app/data/models/00_user.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/01_project.dart';
import 'package:safety_check/app/data/models/02_drawing.dart';
import 'package:safety_check/app/data/models/03_marker.dart';
import 'package:safety_check/app/data/models/04_fault.dart';
// import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/models/06_engineer.dart';
import 'package:safety_check/app/data/models/07_fault_cate1_list.dart';
import 'package:safety_check/app/data/models/08_fault_cate2_list.dart';
import 'package:safety_check/app/data/models/11_drawing_memo.dart';

import '../../utils/converter.dart';
import '../models/update_history.dart';

class LocalAppDataService extends GetxService {
  late Box<User> user_box;
  late Box<String?> setting_box;
  late Box<List> template_box;
  late Box<List> project_box;
  late Box<List> drawing_box;
  late Box<Marker> marker_box;
  late Box<List> fault_box;
  late Box<List> picture_box;
  late Box<List> engineer_box;
  late Box<List> fault_cate1_box;
  late Box<List> fault_cate2_box;

  @override
  Future<void> onInit() async {
    await Hive.initFlutter();

    Hive.registerAdapter(UpdateHistoryItemAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(DrawingAdapter());
    Hive.registerAdapter(MarkerAdapter());
    Hive.registerAdapter(FaultAdapter());
    Hive.registerAdapter(EngineerAdapter());
    Hive.registerAdapter(FaultCate1ListAdapter());
    Hive.registerAdapter(FaultCate2ListAdapter());
    Hive.registerAdapter(DrawingMemoAdapter());

    setting_box = await Hive.openBox<String?>('setting_box_1_0_0');
    user_box = await Hive.openBox('user_box_1_0_1');
    template_box = await Hive.openBox('template_box_1_0_1');
    project_box = await Hive.openBox('project_box_1_0_1');
    marker_box = await Hive.openBox('marker_box_1_0_1');
    fault_box = await Hive.openBox('fault_box_1_0_1');
    engineer_box = await Hive.openBox('engineer_box_1_0_0');
    fault_cate1_box = await Hive.openBox('fault_cate1_box_1_0_1');
    fault_cate2_box = await Hive.openBox('fault_cate2_box_1_0_1');

    super.onInit();
  }

  Future<void> writeLastLoginUser(User userData) async {
    await user_box.put('last_logged_in_user', userData);
  }

  User? getLastLoginUser() {
    return user_box.get('last_logged_in_user');
  }

  Future<void> setConfigValue(String name, String value) async {
    await setting_box.put(name, value);
  }

  String? getConfigValue(String name) {
    return setting_box.get(name);
  }

  Future<void> putProject(String user_seq, Project prj) async {
    List<Project> previousProjects = getProjectList(user_seq);
    int? index = previousProjects
        .indexWhere((element) => isSameValue(element.seq, prj.seq));
    if (index != -1) {
      previousProjects[index] = prj;
    } else {
      previousProjects.add(prj);
    }
    await project_box.put(user_seq, previousProjects);
  }

  List<Project> getProjectList(String user_seq) {
    return (project_box.get(user_seq) ?? []).cast<Project>();
  }

  Future<void> putLocationList(List<String> location_list) async {
    await template_box.put('location_list', location_list);
  }

  List<String>? getLocationList() {
    return template_box.get('location_list')?.cast<String>();
  }

  Future<void> putUpdateHistory(List<UpdateHistoryItem?> history_list) async {
    await template_box.put('update_history', history_list);
  }

  List<UpdateHistoryItem>? getUpdateHistory() {
    return template_box.get('update_history')?.cast<UpdateHistoryItem>();
  }

  Future<void> putMarker(Marker marker) async {
    await marker_box.put(marker.mid, marker);
  }

  List<Marker> get MarkerList => marker_box.values.cast<Marker>().toList();
}
