import 'package:get/get.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';

import '../../project_checks/controllers/project_checks_controller.dart';

class ProjectChecksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectChecksController>(
      () => ProjectChecksController(
        appService: Get.find<AppService>(),
        localGalleryDataService: Get.find<LocalGalleryDataService>(),
      ),
    );
  }
}
