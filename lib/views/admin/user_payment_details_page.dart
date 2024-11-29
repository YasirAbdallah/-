// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/payment_controller.dart';
import 'package:paligolshir/models/payments_model.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';
import 'package:photo_view/photo_view.dart';

class UserPaymentDetailPage extends StatefulWidget {
  final PaymentModel userPayment;

  const UserPaymentDetailPage({super.key, required this.userPayment});

  @override
  _UserPaymentDetailPageState createState() => _UserPaymentDetailPageState();
}

class _UserPaymentDetailPageState extends State<UserPaymentDetailPage> {
  final PaymentController paymentController = Get.find();
  final List<String> responses = [
    'تمت الترقية بنجاح',
    'المبلغ الذي قمت بدفعه غير كافي، يرجى دفع مبلغ إضافي',
    'صورة الدفع غير صالحة',
  ];

  String? selectedResponse;
  String? defaultResponse = 'تمت الترقية بنجاح';
  bool isProcessing = false;
  Stream<PaymentModel?>? paymentModelStream;

  @override
  void initState() {
    super.initState();
    paymentModelStream =
        paymentController.fetchUserPayment(widget.userPayment.userId);
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
              text: 'تفاصيل الدفع للمستخدم',
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
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
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.dialog(
                            Dialog(
                              child: PhotoView(
                                imageProvider: NetworkImage(
                                    widget.userPayment.paymentImage!),
                                backgroundDecoration:
                                    const BoxDecoration(color: Colors.black),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade400,
                                blurRadius: 5,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: DecorationImage(
                              image:
                                  NetworkImage(widget.userPayment.paymentImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
      
                      // عرض الرد السابق
                      StreamBuilder<PaymentModel?>(
                        stream: paymentModelStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child:  CustomBodyText(
                                    text: 'حدث خطأ يرجى إعادة المحاولة '));
                          } else if (!snapshot.hasData || snapshot.data == null) {
                            return const Center(
                                child: CustomBodyText(text: 'لا توجد بيانات.'));
                          }
      
                          final payment = snapshot.data!;
                          return CustomBodyText(
                            text:
                                'الرد السابق: ${payment.adminRespond ?? "لا يوجد رد سابق"}',
                          );
                        },
                      ),
                      const SizedBox(height: 20),
      
                      // اختيار الرد
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          hint: const CustomBodyText(text: 'اختر الرد للمستخدم'),
                          value: selectedResponse,
                          style: const ArabicTextStyle(
                            arabicFont: ArabicFont.changa,
                            fontSize: 18,
                            color: metallicBlue,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedResponse = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                          items: responses
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
      
                      // زر إرسال الرد
                    ],
                  ),
                  Container(
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
                    child: ElevatedButton(
                      onPressed: selectedResponse == null || isProcessing
                          ? null
                          : () async {
                              setState(() => isProcessing = true);
                              await paymentController.sendAdminRespond(
                                  widget.userPayment.userId, selectedResponse!);
                              await paymentController.fetchUserPayments();
                              setState(() => isProcessing = false);
      
                              Get.snackbar('نجاح', 'تم إرسال الرد بنجاح');
                              setState(() {
                                selectedResponse = null;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor:
                            Colors.transparent, // تعيين الخلفية كـ شفاف
                        shadowColor: Colors.transparent, // لإزالة الظل الافتراضي
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const   CustomBodyText(
                              text: 'إرسال الرد',
                            ),
                      ),
                    ),
                  
                  const SizedBox(height: 30),
      
                  // زر ترقية المستخدم
                  Obx(
                    () => paymentController.isLoading.value || isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                          
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
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() => isProcessing = true);
                                await paymentController
                                    .upgradeUser(widget.userPayment.userId);
                                await paymentController.sendAdminRespond(
                                    widget.userPayment.userId, defaultResponse!);
                                await paymentController.fetchUserPayments();
      
                                setState(() => isProcessing = false);
      
                                Get.snackbar('نجاح', 'تمت الترقية بنجاح');
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor:
                                    Colors.transparent, // تعيين الخلفية كـ شفاف
                                shadowColor:
                                    Colors.transparent, // لإزالة الظل الافتراضي
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                               child: const CustomBodyText(
                              text: 'ترقية المستخدم',
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
    );
  }
}
