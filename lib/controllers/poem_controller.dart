// ignore_for_file: avoid_print

import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:get/get.dart';
import 'package:paligolshir/models/poem_model.dart';
import 'package:paligolshir/services/payment_services.dart';
import 'package:paligolshir/services/poem_services.dart';
import 'package:paligolshir/views/admin/admin_line_detail_page.dart';
import 'package:paligolshir/views/user/user_line_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PoemController extends GetxController {
  final PoemService _poemService = PoemService();
  final PaymentServices _paymentServices = PaymentServices();
  var userId = '';
  var isLoading = false.obs; // حالة التحميل
  var isPoemInfoAdded = false.obs; // للتحقق من وجود معلومات القصيدة
  var isLineEditMode = false.obs; // تتبع حالة التعديل
  var isUpgraded = false.obs;
  var poem = Rx<Poem?>(null);
  Stream<Poem?>? poemStream; // تخزين الـ Stream الخاص بالقصيدة
  var allLines = <Line>[].obs; // قائمة الأسطر المحملة من Firestore
  var limitedLines = <Line>[].obs; // قائمة الأسطر المحملة من Firestore
  var searchResults = <Line>[].obs;
  RxString searchQuery = ''.obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  Rx<File?> selectedAudio = Rx<File?>(null);
  RxString? imageUrl = ''.obs;
  RxString? audioUrl = ''.obs;
  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  @override
  void onInit() {
    super.onInit();
    getUserId();
    listenToPoemUpdates(); // الاستماع للتحديثات عند تحميل الصفحة
    checkIfUserUpgraded();
    fetchLinesFromFirestore(10);
  }

// طريقة للتحقق من صحة المدخلات
  bool validatePoemInfo(
      String title, String author, String description, String price) {
    if (title.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال عنوان القصيدة');
      return false;
    }
    if (author.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم المؤلف');
      return false;
    }
    if (description.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال وصف القصيدة');
      return false;
    }
    if (price.isEmpty || double.tryParse(price) == null) {
      Get.snackbar('خطأ', 'يرجى إدخال سعر صحيح');
      return false;
    }
    return true; // كل المدخلات صحيحة
  }

  bool validateLineInput(String hemistich1, String hemistich2, String prose) {
    if (hemistich1.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال صدر البيت');
      return false;
    }
    if (hemistich2.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال عجز البيت');
      return false;
    }
    if (prose.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال نثر البيت');
      return false;
    }
    return true; // كل المدخلات صحيحة
  }

  // الاستماع إلى التحديثات الحية من Firebase باستخدام Stream
  void listenToPoemUpdates() {
    try {
      isLoading.value = true; // بدء التحميل

      // الحصول على Stream للبيانات
      poemStream = _poemService.getPoemStream();
      poemStream = _poemService.getPoemFreeStream();

      // الاستماع إلى التحديثات
      poemStream?.listen((Poem? updatedPoem) {
        if (updatedPoem != null) {
          isPoemInfoAdded.value =
              true; // إذا كانت القصيدة موجودة، قم بتحديث الحالة
          poem.value = updatedPoem;
        } else {
          isPoemInfoAdded.value = false; // إذا لم توجد القصيدة
        }
        isLoading.value = false; // إيقاف التحميل بعد جلب البيانات
      });
    } catch (e) {
      Get.snackbar('Error', 'حدث خطأ أثناء التحديث من القصيدة');
      isLoading.value = false; // إيقاف التحميل
    }
  }

// Method to update the poem information
  Future<void> updatePoem(Poem updatedPoem) async {
    try {
      isLoading.value = true; // Start loading
      await _poemService.updatePoemInfo(updatedPoem);
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  // رفع معلومات القصيدة لمرة واحدة فقط
  Future<void> uploadPoemInfo(Poem poemInfo) async {
    try {
      if (isPoemInfoAdded.value) {
        Get.snackbar('Info', 'معلومات القصيدة موجودة بالفعل');
        return; // لا حاجة لرفع معلومات القصيدة مرة أخرى
      }

      isLoading.value = true; // بدء التحميل
      await _poemService.uploadPoem(poemInfo); // رفع المعلومات
      isPoemInfoAdded.value = true; // تحديث الحالة إلى أن القصيدة مضافة
      Get.snackbar('Success', 'تم رفع معلومات القصيدة بنجاح');
    } catch (e) {
      Get.snackbar('Error', 'حدث خطأ في رفع معلومات القصيدة');
    } finally {
      isLoading.value = false; // إيقاف التحميل
    }
  }

  // إضافة بيت جديد للقصيدة
  Future<void> addLine(Line newLine) async {
    try {
      isLoading.value = true; // بدء التحميل

      // التأكد من أن القصيدة موجودة
      Poem? currentPoem = await _poemService.fetchPoem();
      if (currentPoem != null) {
        currentPoem.lines!.add(newLine); // إضافة البيت الجديد
        await _poemService.uploadPoem(currentPoem); // رفع القصيدة المحدثة
        Get.snackbar('Success', 'تم إضافة البيت بنجاح');
      } else {
        Get.snackbar('Error', 'يجب إضافة معلومات القصيدة أولاً');
      }
    } catch (e) {
      Get.snackbar('Error', 'حدث خطأ في إضافة البيت');
    } finally {
      isLoading.value = false; // إيقاف التحميل
    }
  }

  // تعديل بيت موجود في القصيدة
  Future<void> editLine(int index, Line updatedLine) async {
    try {
      isLoading.value = true; // بدء التحميل

      // التأكد من أن القصيدة موجودة
      Poem? currentPoem = await _poemService.fetchPoem();
      if (currentPoem != null && currentPoem.lines!.length > index) {
        currentPoem.lines![index] = updatedLine; // تعديل البيت الموجود
        await _poemService.uploadPoem(currentPoem); // رفع القصيدة المحدثة
        Get.snackbar('Success', 'تم تعديل البيت بنجاح');
      } else {
        Get.snackbar('Error', 'البيت المحدد غير موجود');
      }
    } catch (e) {
      Get.snackbar('Error', 'حدث خطأ في تعديل البيت');
    } finally {
      isLoading.value = false; // إيقاف التحميل
    }
  }
  //  // حفظ رابط الصورة في قاعدة البيانات فقط
  // Future<void> saveImageUrlToFirestore(String docId, String url) async {
  //   imageUrl.value = url; // تحديث imageUrl
  //   await _poemService.saveImageUrl(docId, url);
  // }

  // // حفظ رابط الصوت في قاعدة البيانات فقط
  // Future<void> saveAudioUrlToFirestore(String docId, String url) async {
  //   if (audioUrl.value != null && audioUrl!.value.isNotEmpty){

  //   }
  //   await _poemService.saveAudioUrl(docId, audioUrl!.value);
  // }

  // الحصول على Stream لبيانات القصيدة مع try-catch
  Stream<Poem?> getPoemStream() {
    try {
      return _poemService.getPoemStream();
    } catch (e) {
      Get.snackbar('Error', 'حدث خطأ أثناء جلب القصيدة');
      return Stream.error(e); // إعادة الخطأ كـ Stream
    }
  }

  Stream<Poem?> getPoemFreeStream() {
    try {
      return _poemService.getPoemFreeStream();
    } catch (e) {
      Get.snackbar('Error', 'حدث خطأ أثناء جلب القصيدة');
      print('Error in getPoemStream: $e');
      return Stream.error(e); // إعادة الخطأ كـ Stream
    }
  }

  Future<void> deleteLine(int lineIndex) async {
    isLoading.value = true; // بدء التحميل
    await _poemService.deleteLine(lineIndex);
    isLoading.value = false; // بدء التحميل
  }

  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('userId');
    if (uid != null) {
      userId = uid;
    }
  }

  Future<void> checkIfUserUpgraded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      isUpgraded.value = await _paymentServices.isUserUpgraded(userId);
    }
  }

  Future<bool?> isUserUpgraded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      return await _paymentServices.isUserUpgraded(userId);
    }
    return null;
  }

  // تحميل الأسطر من Firestore
  void fetchLinesFromFirestore(int limit) async {
    final fetchedAllLines = await _poemService.fetchLines();
    final fetchedLimitedLines = await _poemService.fetchLimitedLines(limit);
    if (fetchedLimitedLines != null && fetchedAllLines != null) {
      limitedLines.value = fetchedLimitedLines;
      allLines.value = fetchedAllLines;
    }
  }

  String removeDiacritics(String input) {
    // هذه الدالة تزيل التشكيل من النص العربي
    final diacritics = RegExp(r'[\u064B-\u0652]');
    return input.replaceAll(diacritics, '');
  }

  // البحث ضمن قائمة الأسطر المحملة، بناءً على حالة الترقية
  Future<void> search(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isAdmin = prefs.getBool('isAdmin');
    if (isAdmin == null || isAdmin == false) {
      if (isUpgraded.value) {
        searchQuery.value = query; // حفظ نص البحث
        searchResults.value = _poemService.searchLines(allLines, query);
      } else {
        searchQuery.value = query; // حفظ نص البحث
        searchResults.value = _poemService.searchLines(limitedLines, query);
      }
    } else {
      searchQuery.value = query; // حفظ نص البحث
      searchResults.value = _poemService.searchLines(allLines, query);
    }
  }

  Future<void> navigateToLineDetailsPage(
      {required line, required int index}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isAdmin = prefs.getBool('isAdmin');

    if (isAdmin == null || isAdmin == false) {
      // إذا لم يكن المستخدم Admin، انقله إلى صفحة UserLineDetailsPage
      Get.to(UserLineDetailsPage(
        line: line,
        lineIndex: index,
      ));
    } else {
      // إذا كان المستخدم Admin، انقله إلى صفحة AdminLineDetailsPage
      Get.to(AdminLineDetailsPage(
        line: line,
        lineIndex: index,
      ));
    }
  }

  // دالة لإعادة تعيين نتائج البحث
  void clearSearchResults() {
    searchResults.value = []; // إعادة تعيين النتائج
    searchQuery.value = ''; // إعادة تعيين نص البحث
  }

  // Pick an image
  Future<void> selectImage() async {
    selectedImage.value = await _poemService.pickImage();
  }

  // Pick an audio file
  Future<void> selectAudio() async {
    selectedAudio.value = await _poemService.pickAudio();
  }

  // Upload the selected image
  Future<void> uploadMedia() async {
    if (selectedImage.value != null && selectedAudio.value != null) {
      imageUrl!.value =
          (await _poemService.uploadFile(selectedImage.value!, 'images'))!;
      audioUrl!.value =
          (await _poemService.uploadFile(selectedAudio.value!, 'audios'))!;
    } else if (selectedImage.value != null && selectedAudio.value == null) {
      imageUrl!.value =
          (await _poemService.uploadFile(selectedImage.value!, 'images'))!;
    } else if (selectedImage.value == null && selectedAudio.value != null) {
      audioUrl!.value =
          (await _poemService.uploadFile(selectedAudio.value!, 'audios'))!;
    } else {
      //  Get.snackbar("Error", "No image selected.");
    }
  }
}
