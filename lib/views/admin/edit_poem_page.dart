// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/poem_controller.dart';
import 'package:paligolshir/models/poem_model.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';

class EditPoemPage extends StatefulWidget {
  final Poem poem;

  const EditPoemPage({super.key, required this.poem});

  @override
  _EditPoemPageState createState() => _EditPoemPageState();
}

class _EditPoemPageState extends State<EditPoemPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();


  final RxList<TextEditingController> paymentKeyControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> paymentValueControllers =
      <TextEditingController>[].obs;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.poem.title;
    authorController.text = widget.poem.author;
    descriptionController.text = widget.poem.description;
    priceController.text = widget.poem.price!;

    widget.poem.paymentMethods.forEach((key, value) {
      paymentKeyControllers.add(TextEditingController(text: key));
      paymentValueControllers.add(TextEditingController(text: value));
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    for (var controller in paymentKeyControllers) {
      controller.dispose();
    }
    for (var controller in paymentValueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildDynamicFields(
    String label,
    String keyLabel,
    String valueLabel,
    RxList<TextEditingController> keyControllers,
    RxList<TextEditingController> valueControllers,
  ) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFCC8400),
                ),
              ),
              GestureDetector(
                onTap: () {
                  keyControllers.add(TextEditingController());
                  valueControllers.add(TextEditingController());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFC107),
                        Color(0xFFFFA500),
                        Color(0xFFCC8400),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'إضافة حقل',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: keyControllers.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDynamicTextField(
                          controller: keyControllers[index],
                          hint: keyLabel,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDynamicTextField(
                          controller: valueControllers[index],
                          hint: valueLabel,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red[400]),
                        onPressed: () {
                          keyControllers.removeAt(index);
                          valueControllers.removeAt(index);
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildDynamicTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      minLines: 1,
      maxLines: 3,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
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
                text: 'تعديل القصيدة', 
          
          ),),
          body: Card(
            child: Container(
                decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [
                    Color(0xFFFFF9E5), // ذهبي فاتح جداً
                    Color(0xFFFFE1A8), // لون ذهبي أفتح
                    Color(0xFFFFE1A8), // لون ذهبي أفتح
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    children: [
                      _buildTextField(titleController, 'العنوان'),
                      _buildTextField(authorController, 'المؤلف'),
                      _buildTextField(descriptionController, 'الوصف'),
                      _buildTextField(priceController, 'السعر'),
                      const SizedBox(height: 20),
                      _buildDynamicFields(
                        'طرق الدفع',
                        'أدخل اسم طريقة الدفع',
                        'أدخل قيمة طريقة الدفع',
                        paymentKeyControllers,
                        paymentValueControllers,
                      ),
                      const SizedBox(height: 20),
                      Container(
                          decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFD700),
                              Color(0xFFFFC107),
                              Color(0xFFFFA500),
                              Color(0xFFCC8400),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () {
                            final updatedPoem = Poem(
                              title: titleController.text,
                              author: authorController.text,
                              description: descriptionController.text,
                              price: priceController.text,
                              paymentMethods: {
                                for (int i = 0; i < paymentKeyControllers.length; i++)
                                  paymentKeyControllers[i].text:
                                      paymentValueControllers[i].text,
                              },
                            );
                            Get.find<PoemController>().updatePoem(updatedPoem);
                            
                            Get.back();
                          },
      
                        
                          child: const Text('تحديث المعلومات',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        validator: (value) =>
            value == null || value.isEmpty ? 'يرجى ملء الحقل' : null,
        controller: controller,
        minLines: 1,
        maxLines: 10,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
