// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/payment_controller.dart';
import 'package:paligolshir/views/admin/past_payment_list.dart';
import 'package:paligolshir/views/admin/user_payment_details_page.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';

class AdminReceivePaymentPage extends StatefulWidget {
  const AdminReceivePaymentPage({super.key});

  @override
  _AdminReceivePaymentPageState createState() =>
      _AdminReceivePaymentPageState();
}

class _AdminReceivePaymentPageState extends State<AdminReceivePaymentPage> {
  final PaymentController paymentController = Get.put(PaymentController());

  @override
  void initState() {
    super.initState();
    paymentController
        .fetchUserPayments(); // تحميل بيانات المستخدمين عند بدء الصفحة
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
            data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.9)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: () {
                      // الانتقال إلى صفحة PastPaymentList مع تمرير paymentController
                      Get.to(() =>
                          PastPaymentList(paymentController: paymentController));
                    },
                    icon: const Icon(
                      Icons.history,
                      size: 30,
                      color: metallicBlue,
                    )),
              )
            ],
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
            title: const CustomTitleText(
              text: 'مراجعة صور الدفع',
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CustomBodyText(
                  text: 'قائمة المستخدمين الذين أرسلوا صور الدفع:',
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(
                    () {
                      if (paymentController.isLoading.value) {
                        // عرض مؤشر التحميل عند تحميل البيانات
                        return const Center(child: CircularProgressIndicator());
                      } else if (paymentController.userPayments.isEmpty) {
                        return const Center(
                            child: CustomBodyText(
                                text: 'لا توجد صور دفع في الوقت الحالي.'));
                      } else {
                        return ListView.builder(
                          itemCount: paymentController.userPayments.length,
                          itemBuilder: (context, index) {
                            final userPayment =
                                paymentController.userPayments[index];
                            return Card(
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
                                  leading: CircleAvatar(
                                    backgroundImage: userPayment.userPhoto != null
                                        ? NetworkImage(userPayment.userPhoto!)
                                        : Container() as ImageProvider,
                                  ),
                                  title: Text(
                                      userPayment.userName ?? 'مستخدم غير معروف'),
                                  subtitle: CustomBodyText(
                                      text: userPayment.userEmail ?? ''),
                                  trailing: const Icon(Icons.payment),
                                  onTap: () {
                                    // عرض صفحة تفاصيل الدفع للمستخدم
                                    Get.to(() => UserPaymentDetailPage(
                                        userPayment: userPayment));
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // زر عائم لتحديث القائمة
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
                paymentController.isLoading.value = true; // بدء التحميل
                await paymentController.fetchUserPayments(); // تحديث البيانات
                paymentController.isLoading.value = false; // إيقاف التحميل
              },
              backgroundColor: Colors.transparent, // خلفية شفافة لإظهار التدرج
              elevation: 0, // إزالة الظل ليبدو أكثر تكاملاً مع التدرج
              child: Obx(() => paymentController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.refresh)),
            ),
          ),
        ),
      ),
    );
  }
}
