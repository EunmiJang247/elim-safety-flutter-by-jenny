import 'package:get/get.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';

import '../controllers/project_list_controller.dart';

class ProjectListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectListController>(
      () => ProjectListController(
        appService: Get.find(),
        localGalleryDataService: Get.find<LocalGalleryDataService>(),
      ),
    );
  }
}
