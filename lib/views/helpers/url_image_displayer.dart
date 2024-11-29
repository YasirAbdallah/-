import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shimmer/shimmer.dart';

class UrlImageDisplayer extends StatelessWidget {
  final String? imageUrl;

  const UrlImageDisplayer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return const SizedBox(); // عرض مربع فارغ إذا لم يكن هناك رابط للصورة
    }

    return GestureDetector(
      onTap: () =>
          _showPhotoViewer(imageUrl!), // عرض الصورة في PhotoView عند الضغط
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
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover, // ملاءمة الصورة لملء الـ Container
            placeholder: (context, url) =>
                _buildSkeleton(context), // عظام تحميل مع تأثير ذهبي
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Shimmer.fromColors(
        baseColor: Colors.amber[300]!, // اللون الأساسي (ذهبي فاتح)
        highlightColor: Colors.amber[100]!, // لون الوميض
        child: Container(
          width: double.infinity, // يأخذ كامل العرض
          height: 200, // ارتفاع اختياري (يمكنك تغييره حسب احتياجك)
          decoration: BoxDecoration(
            color: Colors.amber[300], // اللون الأساسي للهيكل العظمي (ذهبي)
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  void _showPhotoViewer(String imageUrl) {
    Get.dialog(
      Dialog(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(
              imageUrl), // استخدام CachedNetworkImageProvider
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
