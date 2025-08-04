import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity connectivity = Connectivity();

  var isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();

    // Initial check
    connectivity.checkConnectivity().then((result) {
      isOnline.value = (result != ConnectivityResult.none);
    });

    // Listen to changes
    connectivity.onConnectivityChanged.listen((results) {

      isOnline.value = !(results.isEmpty || results.contains(ConnectivityResult.none));

    });
  }
}
