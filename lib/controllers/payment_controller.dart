// ignore_for_file: empty_catches

import 'dart:io';
import 'package:get/get.dart';
import 'package:paligolshir/models/pay_info_model.dart';
import 'package:paligolshir/models/payments_model.dart';
import 'package:paligolshir/models/poem_model.dart';
import 'package:paligolshir/services/payment_services.dart';
import 'package:paligolshir/services/poem_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentController extends GetxController {
  final PaymentServices _paymentServices = PaymentServices();
  final PoemService _poemService = PoemService();

  // المتغيرات المتحكمة في حالة التحميل
  var isLoading = false.obs;
  var isUpgraded = false.obs;
  var isAdminUpgradeUser = false.obs;
  var userPayments =
      <PaymentModel>[].obs; // قائمة المستخدمين الذين أرسلوا صور الدفع
  var userPastPayments =
      <PaymentModel>[].obs; // قائمة المستخدمين الذين أرسلوا صور الدفع
  var payInfo = Rxn<PayInfoModel>();
  var userPayment = Rx<PaymentModel?>(null); // كائن الدفع الخاص بالمستخدم

  // رابط صورة الدفع
  // RxString? paymentImageUrl;

  // الرسالة المستقبلة من المشرف
  var adminResponse = ''.obs;
  Rxn<File> selectedImage = Rxn<File>();

  RxBool paymentImageExists = false.obs; // متغير لحفظ حالة وجود صورة الدفع
  RxBool isPaid = false.obs;

  // دالة لاختيار صورة الدفع
  Future<File?> pickPaymentImage() async {
    isLoading(true);
    try {
      File? image = await _paymentServices.pickPaymentImage();
      if (image != null) {
        selectedImage.value = image;
        Get.snackbar('تم اختيار الصورة', 'تم اختيار صورة الدفع بنجاح.');
      }
      return image;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في اختيار الصورة: $e');
      return Future.error(e);
    } finally {
      isLoading(false);
    }
  }

  // دالة لتحميل الصورة إلى Firebase
  Future<void> uploadPaymentImage() async {
    isLoading(true);
    String userId = (await _getUserId())!;
    try {
      String? url = await _paymentServices.uploadPaymentImage(
          selectedImage.value!, userId);
      if (url != null) {
        Get.snackbar('تم التحميل', 'تم تحميل صورة الدفع بنجاح.');
      } else {
        Get.snackbar('خطأ', 'فشل في تحميل الصورة.');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحميل الصورة: $e');
    } finally {
      isLoading(false);
    }
  }

  // دالة لاسترجاع صورة الدفع من Firebase وإعادتها
  Future<String?> getPaymentImage() async {
    isLoading(true);
    String userId = (await _getUserId())!;

    String? imageUrl;
    try {
      imageUrl = await _paymentServices.getPaymentImage(userId);
      if (imageUrl != null) {
        Get.snackbar('تم جلب الصورة',
            'تم العثور على صورة الدفع. رابط الصورة: $imageUrl');
      } else {
        Get.snackbar('معلومة', 'لم يتم العثور على صورة الدفع.');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء جلب الصورة: $e');
    } finally {
      isLoading(false);
    }
    return imageUrl; // إعادة الرابط
  }

  // دالة لترقية المستخدم
  Future<void> upgradeUser(String userId) async {
    isLoading(true);
    try {
      await _paymentServices.upgradeUser(userId);
      isAdminUpgradeUser(true);
      Get.snackbar('تمت الترقية', 'تم ترقية الحساب بنجاح.');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في ترقية الحساب: $e');
    } finally {
      isLoading(false);
    }
  }

  // دالة لجلب رد المشرف من قاعدة البيانات
  Future<void> fetchAdminResponse() async {
    isLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if(userId != null){
          String? response = await _paymentServices.getAdminResponse(userId);

        if (response != null) {
          adminResponse.value = response;
        } else {}
      }
    
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء جلب رد المشرف: $e');
    } finally {
      isLoading(false);
    }
  }

  // جلب بيانات الدفع باستخدام الخدمات
  Future<void> fetchUserPayments() async {
    try {
      List<PaymentModel> payments = await _paymentServices.fetchPayments();
      userPayments.value = payments; // تحديث القائمة
    } catch (e) {}
  }

  // جلب بيانات الدفع باستخدام الخدمات
  Future<void> fetchPastUserPayments() async {
    try {
      List<PaymentModel> payments = await _paymentServices.fetchPastPayments();
      userPastPayments.value = payments; // تحديث القائمة
    } catch (e) {}
  }

// دالة للتحقق مما إذا كانت صورة الدفع موجودة
  Future<void> checkIfPaymentImageExists() async {
    
    String? userId = (await _getUserId());
    if(userId != null){
      paymentImageExists.value =
          await _paymentServices.doesPaymentImageExist(userId);
    }
  
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserPayments(); // جلب البيانات عند تهيئة المتحكم
    checkIfPaymentImageExists();
    checkIfUserUpgraded();
    fetchUserPayments();
    fetchPastUserPayments();
    fetchAdminResponse();
    fetchPayInfo();
  }

  Future<void> shiftPayPage() async {
    String userId = (await _getUserId())!;
    isPaid.value = await _paymentServices.doesPaymentImageExist(userId);
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    return userId;
  }

  // لإرسال رد الإدارة وتحديث البيانات
  Future<void> sendAdminRespond(String userId, String adminRespond) async {
    try {
      await _paymentServices.sendAdminRespond(userId, adminRespond);
      Get.snackbar('نجاح', 'تم إرسال الرد للمستخدم بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء إرسال الرد');
    }
  }

  // طريقة للتحقق مما إذا كان المستخدم قد تم ترقيته
  Future<void> checkIfUserUpgraded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if(userId != null){
      isUpgraded.value = await _paymentServices.isUserUpgraded(userId);

    }
  }

  Future<void> adminCheckIfUserUpgraded(String userId) async {
    isAdminUpgradeUser.value = await _paymentServices.isUserUpgraded(userId);
  }

  // رفع معلومات الدفع
  Future<void> uploadPayInfo(PayInfoModel payInfoModel, String userId) async {
    isLoading(true);
    try {
      await _paymentServices.uploadPayInfo(payInfoModel);
      Get.snackbar('Success', 'تم رفع معلومات الدفع بنجاح');
    } catch (e) {
      Get.snackbar('Error', 'حدث خطأ أثناء رفع معلومات الدفع');
    } finally {
      isLoading(false);
    }
  }

  // جلب معلومات الدفع
  Future<void> fetchPayInfo() async {
    isLoading(true);
    try {
      PayInfoModel? fetchedPayInfo = await _paymentServices.getPayInfo();
      if (fetchedPayInfo != null) {
        payInfo.value = fetchedPayInfo;
      } else {}
    } catch (e) {
      Get.snackbar('Error', 'حدث خطأ أثناء جلب معلومات الدفع');
    } finally {
      isLoading(false);
    }
  }

// في ملف payment_controller.dart
  Stream<Poem?> getPoemStream() {
    try {
      return _poemService.getPoemStream();
    } catch (e) {
      Get.snackbar('Error', 'حدث خطأ أثناء جلب القصيدة');
      // ignore: avoid_print
      print('Error in getPoemStream: $e');
      return Stream.error(e); // إعادة الخطأ كـ Stream
    }
  }

  // الدالة للحصول على دفعة مستخدم واحدة كـ Stream
  Stream<PaymentModel?> fetchUserPayment(String userId) {
    return _paymentServices.getUserPaymentStream(userId).map((payment) {
      userPayment.value = payment; // تحديث الكائن بالقيمة المرجعة
      return payment;
    });
  }
}
