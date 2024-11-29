import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/payment_controller.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';

class PastPaymentList extends StatelessWidget {
  final PaymentController paymentController;
  const PastPaymentList({super.key, required this.paymentController});

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
                    Color(0xFFFFD700),
                    Color(0xFFFFC107),
                    Color(0xFFFFD700),
                    Color(0xFFCC8400),
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
                  text: 'قائمة المستخدمين الذين أرسلوا صور الدفع وتمت ترقيتهم:',
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() {
                    if (paymentController.isLoading.value) {
                      // عرض مؤشر التحميل في حال بدء عملية التحديث
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
      
                    // تصفية المستخدمين المرقين فقط
                    final upgradedUsers = paymentController.userPastPayments
                        .where((user) => user.isUpgraded ?? false)
                        .toList();
      
                    if (upgradedUsers.isEmpty) {
                      return const Center(
                        child: CustomBodyText(
                            text:
                                'لا توجد صور دفع للمستخدمين المرقين في الوقت الحالي.'),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: upgradedUsers.length,
                        itemBuilder: (context, index) {
                          final userPastPayments = upgradedUsers[index];
                          return Card(
                            child: Container(
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
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: userPastPayments.userPhoto !=
                                          null
                                      ? NetworkImage(userPastPayments.userPhoto!)
                                      : Container() as ImageProvider,
                                ),
                                title: CustomBodyText(
                                    text: userPastPayments.userName ??
                                        'مستخدم غير معروف'),
                                subtitle: CustomBodyText(
                                    text: userPastPayments.userEmail ?? ''),
                                trailing: const Icon(Icons.payment),
                                onTap: () {
                                  // الانتقال لعرض صورة الدفع
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
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
                await paymentController.fetchPastUserPayments(); // تحديث البيانات
                paymentController.isLoading.value = false; // إيقاف التحميل
              },
              backgroundColor: Colors.transparent, // خلفية شفافة لإظهار التدرج
              elevation: 0, // إزالة الظل ليبدو أكثر تكاملاً مع التدرج
              child: Obx(
                () => paymentController.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.refresh),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
