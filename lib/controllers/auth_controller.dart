// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin_model.dart';
import '../models/auth_model.dart';

class UserController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;
  var admins = <Admin>[].obs;

  UserModel? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    loadUserFromPreferences();
    _authService.getAdmins().listen((adminList) {
      admins.value = adminList; // تحديث قائمة المدراء
    });
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      UserModel? user = await _authService.signInWithGoogle();
      isLoading.value = false;

      if (user != null) {
        _currentUser.value = user;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        String initialRoute = user.isAdmin ? '/admin' : '/user';
        Get.offNamed(initialRoute); // Navigate to '/admin' or '/user'
      } else {
        Get.snackbar('تسجيل الدخول', 'فشل تسجيل الدخول بواسطة Google');
      }
    } catch (error) {
      isLoading.value = false;
      print('Error occurred during sign-in: $error');
      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول.';

      if (error is PlatformException) {
        switch (error.code) {
          case 'network_error':
            errorMessage = 'خطأ في الشبكة. يرجى التحقق من الاتصال بالإنترنت.';
            break;
          case 'account_exists_with_different_credentials':
            errorMessage =
                'هناك حساب بنفس البريد الإلكتروني مع اعتمادات مختلفة.';
            break;
          default:
            errorMessage = 'حدث خطأ أثناء تسجيل الدخول.';
            break;
        }
      }

      Get.snackbar('تسجيل الدخول', errorMessage);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser.value = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void loadUserFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('userId');
    String? email = prefs.getString('email');
    bool? isAdmin = prefs.getBool('isAdmin');
    String? photoURL = prefs.getString('photoURL');
    String? username = prefs.getString('username');

    if (uid != null && email != null && isAdmin != null) {
      _currentUser.value = UserModel(
        uid: uid,
        email: email,
        isAdmin: isAdmin,
        photoURL: photoURL,
        username: username,
      );
    }
  }

  // إضافة مدير
  Future<void> addAdmin(String email, String name) async {
    final admin = Admin(name: name, email: email);
    await _authService.addAdmin(admin);
  }


  Future<void> deleteAdmin(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localUid =
        prefs.getString('userId'); // استرجاع userId المخزن محلياً
        String? localEmail = prefs.getString('email');
    String? targetUserId = await _authService
        .getUidByEmail(email); // الحصول على userId المستهدف بناءً على البريد

    // التحقق من أن المستخدم المستهدف ليس المستخدم الحالي
    if (targetUserId != null && targetUserId != localUid) {
      await _authService.deleteAdmin(email); // احذف المدير المستهدف فقط
    } else if( localEmail != null)  {
      // إذا كان المستخدم الحالي هو المستهدف، احذفه وقم بتسجيل الخروج
      await _authService.deleteAdmin(localEmail);

      // تأكد من تسجيل الخروج بعد الحذف
      // await Future.delayed(
      //     Duration(milliseconds: 500)); // تأخير بسيط لضمان الحذف
      await signOut();
      Get.offNamed('/'); // الانتقال إلى الصفحة الرئيسية بعد تسجيل الخروج
    }
  }

  
}
