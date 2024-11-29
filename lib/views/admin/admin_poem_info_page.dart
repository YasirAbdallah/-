import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/poem_controller.dart';
import 'package:paligolshir/models/poem_model.dart';
import 'package:paligolshir/views/admin/edit_poem_page.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';

class AdminPoemInfoPage extends StatelessWidget {
  final PoemController poemController = Get.put(PoemController());
  final Rx<Poem?> poem;

  AdminPoemInfoPage({super.key, required this.poem});
 
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
            data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.9)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
      
            floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFFC107),
                  Color(0xFFFFD700),
                  Color(0xFFCC8400),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: FloatingActionButton(
              onPressed: () async {
              if (poem.value != null) {
                  Get.to(() => EditPoemPage(poem: poem.value!));
                } // إيقاف التحميل
              },
              backgroundColor: Colors.transparent, // خلفية شفافة لإظهار التدرج
              elevation: 0, // إزالة الظل ليبدو أكثر تكاملاً مع التدرج
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  if (poem.value != null) {
                    Get.to(() => EditPoemPage(poem: poem.value!));
                  }
                },
              ),
            ),
          ),
          body: Obx(() {
            if (poemController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
      
            final currentPoem = poem.value;
      
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 223, 119),
                        Color(0xFFFFE1A8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: currentPoem == null
                      ? const Center(
                          child: CustomBodyText(
                        text:    'لا توجد قصيدة',
                          
                          ),
                        )
                      : ListView(
                          children: [
                            // عنوان القصيدة
                            CustomTitleText(
                            text:  ' ${currentPoem.title}',
                            
                            ),
                            const SizedBox(height: 16),
      
                            // معلومات المؤلف والوصف
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white.withOpacity(0.9),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.person, color: metallicBlue),
                                        const SizedBox(width: 8),
                                        CustomBodyText(
                                        text:  'المؤلف: ${currentPoem.author}',
                                        
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    CustomBodyText(
                                      text: currentPoem.description,
                                      
                                    ),
                                  ],
                                ),
                              ),
                            ),
      
                            // السعر
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white.withOpacity(0.9),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.monetization_on,
                                        color: metallicBlue),
                                    const SizedBox(width: 8),
                                      CustomBodyText(
                                      text:
                                          'السعر: ${currentPoem.price} جنيه سوداني',
                                    
                                    ),
                                  ],
                                ),
                              ),
                            ),
      
                            // طرق الدفع
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white.withOpacity(0.9),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.payment, color: metallicBlue),
                                        SizedBox(width: 8),
                                          CustomBodyText(
                                          text:  'طرق الدفع',
                                          
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: currentPoem.paymentMethods.entries
                                          .map((entry) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child:   CustomBodyText(
                                            text:  '${entry.key}: ${entry.value}',
                                          
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
