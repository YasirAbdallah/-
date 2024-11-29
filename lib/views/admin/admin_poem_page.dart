import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/poem_controller.dart';
import 'package:paligolshir/models/poem_model.dart';
import 'package:paligolshir/views/admin/admin_line_detail_page.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';

class AdminPoemPage extends StatelessWidget {
  final PoemController poemController = Get.put(PoemController());

  AdminPoemPage({super.key}); // الوصول إلى PoemController

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.9)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Obx(() {
            if (poemController.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator()); // عرض مؤشر تحميل
            } else if (!poemController.isPoemInfoAdded.value) {
              return const Center(
                  child:
                      Text('لا توجد معلومات متاحة ')); // إذا لم تكن هناك قصيدة
            } else {
              return StreamBuilder<Poem?>(
                stream: poemController
                    .getPoemStream(), // استدعاء الدالة التي ترجع Stream
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // عرض مؤشر التحميل إذا كان الاتصال قيد الانتظار
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: CustomBodyText(
                            text:
                                'حدث خطأ يرجى إعادة المحاولة:')); // عرض رسالة الخطأ إذا حدث خطأ
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                        child: CustomBodyText(
                            text:
                                'لا توجد قصيدة متاحة')); // عرض رسالة إذا لم توجد بيانات
                  } else {
                    final Poem poem = snapshot.data!; // البيانات موجودة

                    // إنشاء ListView.builder لعرض الأبيات
                    return ListView.builder(
                      itemCount: poem.lines!.length,
                      itemBuilder: (context, index) {
                        final line =
                            poem.lines![index]; // الوصول إلى البيت المحدد
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 0.5),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700), // اللون الذهبي الأساسي
                                    Color(0xFFFFC107), // لون ذهبي أفتح
                                    Color(0xFFFFD700), // لون برتقالي ذهبي
                                    Color(0xFFCC8400), // لون ذهبي داكن
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                onTap: () {
                                  // الانتقال إلى صفحة تفاصيل البيت عند الضغط
                                  Get.to(AdminLineDetailsPage(
                                      line: line, lineIndex: index));
                                },
                                title: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CustomBodyText(
                                            text: line.hemistich1,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          CustomBodyText(
                                            text: line.hemistich2,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomBodyText(
                                        text: '(${index + 1})',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              );
            }
          }),
        ),
      ),
    );
  }

  // بناء قسم لعرض المحتويات من Map
}
