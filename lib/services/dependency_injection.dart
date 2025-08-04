import 'package:get/get.dart';
import 'package:expenses_tracker/services/network_controller.dart';

class DependencyInjection {
  static void init(){
    Get.put<NetworkController>(NetworkController(),permanent:true);
  }
}
