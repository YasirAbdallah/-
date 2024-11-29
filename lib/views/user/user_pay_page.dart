import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/payment_controller.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';
import 'package:paligolshir/views/user/user_poem_page.dart';
import 'package:photo_view/photo_view.dart';

import '../../models/poem_model.dart';

class UserPayPage extends StatelessWidget {
  final PaymentController paymentController = Get.put(PaymentController());

  UserPayPage({
    super.key,
  });

//  File? selectedImage; // متغير لحفظ الصورة محليًا في الواجهة فقط

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // حالة التحميل
      if (paymentController.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        // تحقق من حالة الترقية
        if (paymentController.isUpgraded.value) {
          // إضافة تأخير بسيط قبل فتح الصفحة
          Future.delayed(const Duration(milliseconds: 500), () {
            paymentController.isLoading.value = false;
            Get.off(() => const UpGradeDone());
          });
          paymentController.isLoading.value = true;
        }
        // تحقق من وجود صورة الدفع
        else if (paymentController.paymentImageExists.value) {
          // إذا كانت صورة الدفع موجودة
          Future.delayed(const Duration(milliseconds: 500), () {
            paymentController.isLoading.value = false;
            Get.off(
                () => PaymentReConform(paymentController: paymentController));
          });
          paymentController.isLoading.value = true;
        } else {
          // إذا لم تكن صورة الدفع موجودة
          Future.delayed(const Duration(milliseconds: 500), () {
            paymentController.isLoading.value = false;
            Get.off(() => PaymentImagePage());
          });
          paymentController.isLoading.value = true;
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    });
  }
}

class PaymentImagePage extends StatelessWidget {
  final PaymentController paymentController = Get.put(PaymentController());

  PaymentImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
            data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.9)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const CustomBodyText(
              text: 'تحميل صورة الدفع',
            ),
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
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomBodyText(
                    text: 'الرجاء اتباع التعليمات التالية لتحميل صورة الدفع:',
                  ),
                  const SizedBox(height: 10),
                  const CustomBodyText(
                    text: '- تأكد من أن صورة الدفع واضحة.\n'
                        '- يجب أن تحتوي الصورة على تفاصيل الدفع الكاملة.\n'
                        '- يمكن تحميل الصورة بصيغة JPG أو PNG فقط.\n',
                  ),
                  const SizedBox(height: 20),
      
                  StreamBuilder<Poem?>(
                    stream: paymentController.getPoemStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const CustomBodyText(
                            text: 'حدث خطأ أثناء جلب طرق الدفع.');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const CustomBodyText(
                            text: 'لا توجد معلومات عن طرق الدفع.');
                      } else {
                        final poem = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomBodyText(
                                text: 'مبلغ الدفع: ${poem.price} جنيه سوداني'),
                            const SizedBox(height: 15),
                            const CustomBodyText(text: 'طرق الدفع:'),
                            const SizedBox(height: 10),
                            for (var entry in poem.paymentMethods.entries)
                              CustomBodyText(
                                  text: '${entry.key}: ${entry.value}'),
                            const SizedBox(height: 10),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
      
                  // عرض الصورة المختارة قبل التحميل
                  paymentController.selectedImage.value == null
                      ? Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CustomBodyText(text: 'لم يتم اختيار صورة بعد'),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Get.dialog(
                              Dialog(
                                child: PhotoView(
                                  imageProvider: FileImage(
                                    paymentController.selectedImage.value!,
                                  ),
                                  minScale: PhotoViewComputedScale.contained,
                                  maxScale: PhotoViewComputedScale.covered * 2,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 200,
                            decoration: const BoxDecoration(),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                paymentController.selectedImage.value!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
      
                  const SizedBox(height: 20),
      
                  ElevatedButton(
                    onPressed: () async {
                      File? image = await paymentController.pickPaymentImage();
                      if (image != null) {
                        (context as Element).markNeedsBuild();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
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
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(minHeight: 50),
                        child: const CustomBodyText(text: 'اختيار صورة الدفع'),
                      ),
                    ),
                  ),
      
                  const SizedBox(height: 20),
      
                  Obx(
                    () => paymentController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (paymentController.selectedImage.value != null) {
                                await paymentController.uploadPaymentImage();
                                Get.offAll(UserPoemPage());
                              } else {
                                Get.snackbar('خطأ', 'يرجى اختيار صورة أولاً');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Ink(
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
                              child: Container(
                                alignment: Alignment.center,
                                constraints: const BoxConstraints(minHeight: 50),
                                child: const CustomBodyText(
                                    text: 'تحميل صورة الدفع'),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
      
                  const CustomBodyText(
                    text:
                        'سيتم مراجعة صورة الدفع بواسطة الإدارة وسيتم إبلاغك بردهم في أقرب وقت',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentReConform extends StatelessWidget {
  final PaymentController paymentController;

  const PaymentReConform({
    super.key,
    required this.paymentController,
  });

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
            title: const CustomBodyText(
              text: 'تحميل صورة الدفع',
            ),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFC107),
                            Color(0xFFFFD700),
                            Color(0xFFCC8400),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds);
                      },
                      child: const Icon(
                        Icons.check_circle,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const CustomBodyText(
                      text: 'لقد قمت برفع صورة الدفع بنجاح!',
                    ),
                    const SizedBox(height: 10),
                    const CustomBodyText(
                      text: 'سيتم الرد قريبًا بواسطة المسؤولين.',
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: CustomBodyText(
                        text:
                            'نحن نقدر تعاونك! سيتم مراجعة صورة الدفع الخاصة بك قريبًا. يرجى التحقق من بريدك الإلكتروني للحصول على أي تحديثات أو معلومات إضافية. شكرًا لك على ثقتك بنا!',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => PaymentImagePage());
                        paymentController.selectedImage.value = null;
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Ink(
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(
                            minHeight: 50,
                          ),
                          child: const CustomBodyText(
                            text: 'إعادة رفع صورة الدفع',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UpGradeDone extends StatelessWidget {
  const UpGradeDone({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
            data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.9)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const CustomBodyText(
              text: 'ترقية الحساب',
            ),
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
          ),
          // ignore: prefer_const_constructors
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 300,
                          child: Image.asset('assets/photos/king.png')),
                      const SizedBox(height: 20),
                      const CustomBodyText(
                        text: 'لقد تم ترقية حسابك بنجاح!',
                      ),
                      const SizedBox(height: 10),
                      const CustomBodyText(
                        text:
                            'يمكنك الآن الاستمتاع بجميع الميزات الجديدة والمميزة التي يوفرها حسابك.\n'
                            'شكرًا لك على ثقتك بنا، ونتمنى لك تجربة رائعة.\n'
                            'إذا كان لديك أي استفسارات، لا تتردد في التواصل معنا!',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
