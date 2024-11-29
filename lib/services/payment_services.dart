// ignore_for_file: empty_catches, use_rethrow_when_possible

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paligolshir/models/pay_info_model.dart';
import 'dart:io';

import 'package:paligolshir/models/payments_model.dart';

class PaymentServices {
  // final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final cloudinary =
      CloudinaryPublic('dxjoxyu0f', 'we6aimfv', cache: false);


  // طريقة لاختيار الصورة من المعرض أو الكاميرا
  Future<File?> pickPaymentImage() async {
    ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery); // يمكن استبدال .gallery بـ .camera
    if (pickedImage != null) {
      return File(pickedImage.path);
    }
    return null;
  }

  // طريقة لتحميل الصورة إلى Firebase
  // Future<String?> uploadPaymentImage(File image, String userId) async {
  //   try {
  //     // تحديد مسار الصورة في Firebase Storage باستخدام معرف المستخدم
  //     Reference storageReference = FirebaseStorage.instance.ref().child(
  //         'paymentImages/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

  //     // رفع الصورة
  //     UploadTask uploadTask = storageReference.putFile(image);

  //     // الحصول على رابط الصورة بعد الرفع
  //     TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
  //     String downloadUrl = await snapshot.ref.getDownloadURL();

  //     // حفظ البيانات في Firestore
  //     await _updatePaymentImage(downloadUrl, userId);

  //     return downloadUrl; // رابط الصورة في Firebase
  //   } catch (e) {
  //     return null;
  //   }
  // }



  Future<String?> uploadPaymentImage(File image, String userId) async {
    try {
      // رفع الصورة إلى Cloudinary
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: 'paymentImages/$userId', // تحديد مسار الصورة
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      String downloadUrl = response.secureUrl;

      // حفظ البيانات في Firestore
      await _updatePaymentImage(downloadUrl, userId);

      return downloadUrl; // رابط الصورة في Cloudinary
    } catch (e) {
      print("Error uploading payment image: $e");
      return null;
    }
  }

  // دالة لتحديث صورة الدفع في Firestore
  Future<void> _updatePaymentImage(String paymentImage, String userId) async {
    try {
      // تحديث حقل paymentImage فقط في Firestore
      await _firestore
          .collection('payments') // تأكد من أن هذه هي المجموعة الصحيحة
          .doc(userId) // استخدام userId كمعرف فريد
          .update({
        'paymentImage': paymentImage, // تحديث فقط حقل صورة الدفع
      },);
    } catch (e) {}
  }

// جلب بيانات الدفع من Firebase
  Future<List<PaymentModel>> fetchPayments() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('payments').get();
      List<PaymentModel> payments = [];

      // تحويل الوثائق إلى كائنات PaymentModel مع التحقق من وجود paymentImage
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // التحقق من وجود paymentImage وعدم كونه فارغًا
        if (data.containsKey('paymentImage') &&
            data['paymentImage'] != null &&
            data['paymentImage'].toString().isNotEmpty) {
          if (data['isUpgraded'] == false || data['isUpgraded'] == null) {
            payments.add(PaymentModel.fromMap(data));
          }
        }
      }

      return payments;
    } catch (e) {
      return [];
    }
  }

  Future<void> sendAdminRespond(String userId, String adminRespond) async {
    try {
      await _firestore
          .collection('payments')
          .doc(userId)
          .update({'adminRespond': adminRespond});
    } catch (e) {
      throw e;
    }
  }

  // جلب بيانات الدفع من Firebase
  Future<List<PaymentModel>> fetchPastPayments() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('payments').get();
      List<PaymentModel> payments = [];

      // تحويل الوثائق إلى كائنات PaymentModel مع التحقق من وجود paymentImage
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // التحقق من وجود paymentImage وعدم كونه فارغًا
        if (data['paymentImage'] != null &&
            data['paymentImage'].toString().isNotEmpty) {
          payments.add(PaymentModel.fromMap(data));
        }
      }

      return payments;
    } catch (e) {
      return [];
    }
  }

// طريقة لاسترجاع رابط صورة الدفع من قاعدة البيانات (Cloud Firestore)
  Future<String?> getPaymentImage(String userId) async {
    try {

      // جلب وثيقة الدفع الخاصة بالمستخدم
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('payments') // تأكد من أن هذه هي المجموعة الصحيحة
          .doc(userId) // أو أي معرف متعلق بالمستخدم
          .get();

      if (doc.exists) {
        // الحصول على بيانات الوثيقة
        Map<String, dynamic>? data = doc.data();

        // استرجاع رابط صورة الدفع
        String? paymentImageUrl =
            data?['paymentImage']; // افتراض أن الحقل اسمه 'paymentImage'
        return paymentImageUrl;
      } else {
        return null; // إذا لم توجد أي بيانات دفع
      }
    } catch (e) {
      return null;
    }
  }

  // طريقة لترقية المستخدم في Firestore
  Future<void> upgradeUser(String userId) async {
    try {
      // تحديد مرجع المستخدم في Firestore
      DocumentReference userRef =
        _firestore.collection('payments').doc(userId);

      // تحديث حقل "isUpgraded" إلى true
      await userRef.update({'isUpgraded': true});
    } catch (e) {}
  }

  // دالة لاستقبال رد الإدارة بناءً على userId
  Future<String?> getAdminResponse(String userId) async {
    try {
      // جلب وثيقة رد الإدارة الخاصة بالمستخدم
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('adminResponses')
          .doc(userId) // أو أي معرف يتعلق بالمستخدم
          .get();

      if (doc.exists) {
        // جلب الرد إذا كان موجودًا
        Map<String, dynamic>? data = doc.data();
        String? adminResponse =
            data?['response']; // الافتراض أن الحقل اسمه 'response'
        return adminResponse;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> unUpgradeUser(String userId) async {
    try {
      // تحديد مرجع المستخدم في Firestore
      DocumentReference userRef =
        _firestore.collection('users').doc(userId);

      // تحديث حقل "isUpgraded" إلى true
      await userRef.update({'isUpgraded': false});
    } catch (e) {}
  }

  // دالة للتحقق مما إذا كانت صورة الدفع موجودة في Firestore
  Future<bool> doesPaymentImageExist(String userId) async {
    try {

      // جلب وثيقة الدفع الخاصة بالمستخدم
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('payments').doc(userId).get();

      // التحقق مما إذا كانت الوثيقة موجودة
      if (doc.exists) {
        // الحصول على بيانات الوثيقة
        Map<String, dynamic>? data = doc.data();

        // التحقق من وجود رابط الصورة
        String? paymentImageUrl = data?['paymentImage'];
        return paymentImageUrl != null && paymentImageUrl.isNotEmpty;
      } else {
        return false; // إذا لم توجد وثيقة
      }
    } catch (e) {
      return false; // في حالة حدوث خطأ
    }
  }

  // طريقة للتحقق مما إذا كان المستخدم قد تم ترقيته
  Future<bool> isUserUpgraded(String userId) async {
    int attempts = 0;
    while (attempts < 3) {
      // جرب 3 مرات كحد أقصى
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await _firestore
                .collection('payments')
                .doc(userId)
                .get();

        if (snapshot.exists) {
          PaymentModel payment = PaymentModel.fromMap(snapshot.data()!);
          return payment.isUpgraded ?? false;
        } else {
          return false;
        }
      } catch (e) {
        attempts++;
        await Future.delayed(
            Duration(seconds: 2 * attempts)); // زيادة وقت الانتظار مع كل محاولة
      }
    }
    return false;
  }

  // رفع معلومات الدفع
  Future<void> uploadPayInfo(PayInfoModel payInfo) async {
    try {
      await _firestore
          .collection('paymentInfo') // تعديل: حفظ في المجموعة الرئيسية
          .doc('payInfo')
          .set(payInfo.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // جلب معلومات الدفع
  Future<PayInfoModel?> getPayInfo() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('paymentInfo') // تعديل: جلب من المجموعة الرئيسية
          .doc('payInfo')
          .get();

      if (doc.exists) {
        return PayInfoModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // الدالة للحصول على دفعة مستخدم واحدة كمجموعة
  Stream<PaymentModel?> getUserPaymentStream(String userId) {
    return _firestore
        .collection('payments')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return PaymentModel.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        return null; // إرجاع null إذا لم يوجد المستند
      }
    });
  }
}
