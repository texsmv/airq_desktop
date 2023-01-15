import 'package:airq_ui/app/routes/app_pages.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    _initSettings();
    super.onReady();
  }

  Future<void> _initSettings() async {
    await datasetController.loadDatasets();

    route();
  }

  void route() {
    Get.offAllNamed(Routes.MENU);
  }

  final DatasetController datasetController = Get.find();
}
