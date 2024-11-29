import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/views/admin/admin_page.dart';
import 'package:paligolshir/views/user/sign_in_page.dart';
import 'package:paligolshir/views/user/splash_page.dart';
import 'package:paligolshir/views/user/user_poem_page.dart';
import 'firebase_options.dart';
// import 'package:no_screenshot/no_screenshot.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
  // منع لقطات الشاشة عند بناء الواجهة بالكامل
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   disableScreenshot();
  // });
//  }
  // FirebaseFirestore.instance.settings =
  //     const Settings(persistenceEnabled: false);
}

// final NoScreenshot _noScreenshot = NoScreenshot.instance;

// Future<void> disableScreenshot() async {
//   bool result = await _noScreenshot.screenshotOff();
//   debugPrint('Screenshot Off: $result');
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // تأكد من تفعيل التأمين بعد بناء الواجهة

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بليغ الشعر',

      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashView()),
        GetPage(name: '/', page: () => SignInPage()),
        GetPage(name: '/admin', page: () => AdminPage()),
        GetPage(name: '/user', page: () => UserPoemPage()),
      ],
      //  initialBinding: AppBinding(),
    );
  }
}
