import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  var message = "Checking user status...".obs;

  @override
  void onInit() {
    super.onInit();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulating a wait time
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    bool? isAdmin = prefs.getBool('isAdmin');

    if (isLoggedIn == true) {
      if (isAdmin == true) {
        message.value = "Navigating to Admin Page";
        Get.offNamed('/admin'); // Navigate to '/admin' page
      } else {
        message.value = "Navigating to User Page";
        Get.offNamed('/user'); // Navigate to '/user' page
      }
    } else {
      message.value = "Navigating to SignIn Page";
      Get.offNamed('/signin'); // Navigate to '/signin' page
    }
  }
}
