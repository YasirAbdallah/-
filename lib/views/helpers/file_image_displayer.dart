// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';
import 'package:skeletonizer/skeletonizer.dart';

class FileImageController extends GetxController {
  Rxn<File> imageFile = Rxn<File>(); // ملف الصورة
  RxBool isLoading = false.obs;

  Future<void> loadImage(String? imagePath) async {
    if (imagePath == null) {
      imageFile.value = null;
      return;
    }

    // تحميل  الصورة من المسار المحدد مباشرةً
    isLoading.value = true;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        imageFile.value = file;
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print(' error in imageFile.value = $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
}

class FileImageDisplayer extends StatefulWidget {
  final String? imagePath;

  const FileImageDisplayer({super.key, required this.imagePath});

  @override
  _FileImageDisplayerState createState() => _FileImageDisplayerState();
}

class _FileImageDisplayerState extends State<FileImageDisplayer> {
  late final FileImageController imageController;

  @override
  void initState() {
    super.initState();
    imageController = Get.put(FileImageController());
    // تحميل الصورة عند التهيئة
    if (widget.imagePath != null) {
      imageController.loadImage(widget.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.imagePath == null) {
        return const SizedBox(); // إذا لم يكن هناك مسار، عرض مربع فارغ
      } else if (imageController.isLoading.value) {
        return _buildSkeleton(
            context); // عرض عظام تحميل إذا كانت الصورة تحت التحميل
      } else if (imageController.imageFile.value != null) {
        return GestureDetector(
          onTap: () => _showPhotoViewer(imageController.imageFile.value!),
          child: Container(
            width: double.infinity, // استخدام عرض كامل المساحة
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), // حواف دائرية
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2, 2), // تأثير الظل
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8), // حواف دائرية
              child: Image.file(
                imageController.imageFile.value!,
                fit: BoxFit.cover, // ملاءمة الصورة لملء الـ Container
              ),
            ),
          ),
        );
      } else {
        return _buildSkeleton(context); // عرض عظام تحميل إذا لم يكن هناك صورة
      }
    });
  }

  Widget _buildSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        width: double.infinity, // يأخذ كامل العرض
        height: 200, // ارتفاع اختياري (يمكنك تغييره حسب احتياجك)
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  void _showPhotoViewer(File imageFile) {
    Get.dialog(
      Dialog(
        child: PhotoView(
          imageProvider: FileImage(
            imageFile,
          ),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
