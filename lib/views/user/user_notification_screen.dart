import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/payment_controller.dart';
import 'package:paligolshir/models/payments_model.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';

class UserNotificationScreen extends StatelessWidget {
  final PaymentController paymentController = Get.put(PaymentController());
  final String userId; // معرف المستخدم

  UserNotificationScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
            data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.9)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // اللون الذهبي الأساسي
                    Color(0xFFFFC107), // لون ذهبي أفتح
                    Color(0xFFFFD700), // لون برتقالي ذهبي
                    Color(0xFFCC8400), // لون ذهبي داكن
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            title:  const CustomBodyText(
              text: 
              'رد المشرف',
            
            ),
          ),
          body: Obx(() {
            if (paymentController.isLoading.value) {
              return const Center(
                  child:
                      CircularProgressIndicator()); // مؤشر تحميل عند بدء التحميل
            }
            return StreamBuilder<PaymentModel?>(
              stream: paymentController.fetchUserPayment(userId),
              builder: (context, AsyncSnapshot<PaymentModel?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator()); // مؤشر تحميل
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: CustomBodyText(
                    text:  'لا يوجد رد من المشرف حتى الآن.',
                    
                    ),
                  );
                } else {
                  // إذا كان هناك بيانات من الدفق
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                         const CustomBodyText(
                          text: 
                          'آخر رد من المشرف:',
                          
                        ),
                        const SizedBox(height: 10),
                        // البطاقة التي تحتوي على رد المشرف
                        Container(
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(16),
                          child:  CustomBodyText(
                            text: 
                            snapshot.data!.adminRespond ?? 'لا توجد استجابة بعد.',
                          
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }),
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
              backgroundColor: Colors.transparent, // خلفية شفافة لإظهار التدرج
              elevation: 0,
              onPressed: () async {
                paymentController.isLoading.value = true; // بدء التحميل
                await paymentController.fetchAdminResponse(); // جلب رد المشرف
                paymentController.isLoading.value = false; // إنهاء التحميل
              },
              child: const Icon(Icons.refresh),
            ),
          ),
        ),
      ),
    );
  }
}
