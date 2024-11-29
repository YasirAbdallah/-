// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// Future<void> requestPermission(Permission permission) async {
//   final status = await permission.status;

//   if (status.isGranted) {
//     debugPrint('Permission already granted');
//   } else if (status.isDenied) {
//     // إذا كان الإذن مرفوضًا، نطلب الإذن
//     if (await permission.request().isGranted) {
//       debugPrint('Permission granted');
//     } else {
//       debugPrint('Permission denied');
//     }
//   } else {
//     debugPrint('Permission denied');
//   }
// }
