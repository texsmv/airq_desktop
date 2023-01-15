import 'package:airq_ui/app/modules/menu/controllers/menu_controller.dart';
import 'package:get/get.dart';

class MenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      MenuController(),
    );
  }
}
