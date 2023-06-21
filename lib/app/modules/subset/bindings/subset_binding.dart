import 'package:get/get.dart';

import '../controllers/subset_controller.dart';

class SubsetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubsetController>(
      () => SubsetController(),
    );
  }
}
