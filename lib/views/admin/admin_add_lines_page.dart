// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/poem_controller.dart';
import 'package:paligolshir/models/poem_model.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';
import 'package:paligolshir/views/helpers/file_image_displayer.dart';
import 'package:paligolshir/views/helpers/file_voice_card.dart';

class AdminAddLinesPage extends StatelessWidget {
  final PoemController poemController = Get.put(PoemController());

  final GlobalKey<FormState> _PoemInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _LineInfoFormKey = GlobalKey<FormState>();

  // قوائم ديناميكية للإدخال
  final RxList<TextEditingController> grammarKeyControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> grammarValueControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> rhetoricKeyControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> rhetoricValueControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> meaningKeyControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> meaningValueControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> paymentMethodKeyControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> paymentMethodValueControllers =
      <TextEditingController>[].obs;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController hemistich1Controller = TextEditingController();
  final TextEditingController hemistich2Controller = TextEditingController();
  final TextEditingController proseController = TextEditingController();

  AdminAddLinesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const CustomTitleText(text: 'إضافة بيت'),
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFFFE1A8), // لون ذهبي أفتح
          onPressed: () {
            Get.forceAppUpdate();
            poemController.selectedImage.value = null;
            poemController.selectedAudio.value = null;
          },
          child: const Icon(Icons.refresh),
        ),
        body: Obx(() {
          if (poemController.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator()); // مؤشر التحميل
          } else if (!poemController.isPoemInfoAdded.value) {
            return _buildPoemInfoForm(); // نموذج إضافة معلومات القصيدة
          } else {
            return _buildAddLineForm(context); // نموذج إضافة بيت
          }
        }),
      ),
    );
  }

  // تصميم نموذج إضافة معلومات القصيدة
  Widget _buildPoemInfoForm() {
    return SingleChildScrollView(
      child: Form(
        key: _PoemInfoFormKey,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 6,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF9E5), // ذهبي فاتح جداً
                  Color(0xFFFFE1A8), // لون ذهبي أفتح
                  Color(0xFFFFE1A8), // لون ذهبي أفتح
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomBodyText(
                  text: 'معلومات القصيدة',
                ),
                const SizedBox(height: 10),
                _buildPoemInfoTextField(
                    controller: titleController, label: 'عنوان القصيدة'),
                const SizedBox(height: 10),
                _buildPoemInfoTextField(
                    controller: authorController, label: 'اسم المؤلف'),
                const SizedBox(height: 10),
                _buildPoemInfoTextField(
                    controller: descriptionController, label: 'وصف القصيدة'),
                const SizedBox(height: 10),
                _buildPoemInfoTextField(
                    controller: priceController, label: 'السعر'),
                const SizedBox(height: 20),

                // حقول إدخال طرق الدفع
                _buildDynamicFields(
                  'طرق الدفع',
                  'طريقة الدفع',
                  'رقم الحساب',
                  paymentMethodKeyControllers,
                  paymentMethodValueControllers,
                ),

                const SizedBox(height: 20),
                Center(
                  child: Obx(() => poemController.isLoading.value
                      ? const CircularProgressIndicator()
                      : Container(
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
                          child: TextButton(
                            onPressed: () async {
                              if (_PoemInfoFormKey.currentState!.validate()) {
                                poemController.isLoading.value =
                                    true; // بدء التحميل
                                try {
                                  final paymentMethods = Map.fromIterables(
                                      paymentMethodKeyControllers
                                          .map((e) => e.text),
                                      paymentMethodValueControllers
                                          .map((e) => e.text));

                                  final newPoem = Poem(
                                    title: titleController.text,
                                    author: authorController.text,
                                    description: descriptionController.text,
                                    price: priceController.text,
                                    lines: [],
                                    paymentMethods: paymentMethods,
                                  );

                                  await poemController
                                      .uploadPoemInfo(newPoem); // رفع المعلومات
                                } finally {
                                  poemController.isLoading.value =
                                      false; // إيقاف المؤشر بعد التحميل
                                }
                              }
                            },
                            child: const Text(
                              'إضافة معلومات القصيدة',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddLineForm(BuildContext context) {
    return Obx(
      () {
        return poemController.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // عنوان
                            const CustomTitleText(
                              text: 'إضافة بيت جديد',
                            ),
                            const SizedBox(height: 16.0),

                            // حقل صدر البيت
                            Form(
                              key: _LineInfoFormKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: hemistich1Controller,
                                    label: 'صدر البيت',
                                    icon: Icons.short_text,
                                  ),
                                  const SizedBox(height: 12.0),

                                  // حقل عجز البيت
                                  _buildTextField(
                                    controller: hemistich2Controller,
                                    label: 'عجز البيت',
                                    icon: Icons.short_text_rounded,
                                  ),
                                  const SizedBox(height: 12.0),

                                  // حقل نثر البيت
                                  _buildTextField(
                                    controller: proseController,
                                    label: 'نثر البيت',
                                    icon: Icons.description,
                                  ),

                                  const SizedBox(height: 20.0),
                                ],
                              ),
                            ),

                            // الحقول الديناميكية
                            _buildDynamicFields(
                                'التحليل النحوي',
                                'النص',
                                'التحليل النحوي',
                                grammarKeyControllers,
                                grammarValueControllers),
                            _buildDynamicFields(
                                'التحليل البلاغي',
                                'النص',
                                'التحليل البلاغي',
                                rhetoricKeyControllers,
                                rhetoricValueControllers),
                            _buildDynamicFields(
                                'معاني الكلمات',
                                'الكلمة',
                                'المعنى',
                                meaningKeyControllers,
                                meaningValueControllers),

                            const SizedBox(height: 30.0),
                            _audioPickerWidget('إضافة تسجيل', Icons.audiotrack),
                            const SizedBox(height: 30),
                            _imagePickerWidget(
                                'إضافة صورة', Icons.image, context),
                            const SizedBox(height: 50),
                            // زر إضافة
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
                              child: TextButton(
                                onPressed: poemController.isLoading.value
                                    ? null // تعطيل الزر أثناء التحميل
                                    : () async {
                                        poemController.isLoading.value = true;
                                        await poemController.uploadMedia();
                                        // التحقق من صحة المدخلات
                                        // if (_LineInfoFormKey.currentState!
                                        //     .validate()) {
                                        // تحويل القيم المدخلة إلى Map
                                        final grammarAnalysis =
                                            Map.fromIterables(
                                                grammarKeyControllers
                                                    .map((e) => e.text),
                                                grammarValueControllers
                                                    .map((e) => e.text));
                                        final rhetoricAnalysis =
                                            Map.fromIterables(
                                                rhetoricKeyControllers
                                                    .map((e) => e.text),
                                                rhetoricValueControllers
                                                    .map((e) => e.text));
                                        final wordMeanings = Map.fromIterables(
                                            meaningKeyControllers
                                                .map((e) => e.text),
                                            meaningValueControllers
                                                .map((e) => e.text));

                                        // إنشاء خط جديد (بيت شعر) وإضافته
                                        final newLine = Line(
                                          hemistich1: hemistich1Controller.text,
                                          hemistich2: hemistich2Controller.text,
                                          prose: proseController.text,
                                          grammarAnalysis: grammarAnalysis,
                                          rhetoricAnalysis: rhetoricAnalysis,
                                          wordMeanings: wordMeanings,
                                          imageUrl:
                                              poemController.imageUrl?.value,
                                          voiceUrl:
                                              poemController.audioUrl?.value,
                                        );
                                        await poemController.addLine(newLine);
                                        //    }
                                        //  Get.forceAppUpdate();
                                        // تفريغ المدخلات بعد الإضافة
                                        grammarKeyControllers.clear();
                                        grammarValueControllers.clear();
                                        rhetoricKeyControllers.clear();
                                        rhetoricValueControllers.clear();
                                        meaningKeyControllers.clear();
                                        meaningValueControllers.clear();
                                        proseController.clear();
                                        hemistich1Controller.clear();
                                        hemistich2Controller.clear();
                                        poemController.selectedImage.value =
                                            null;
                                        poemController.selectedAudio.value =
                                            null;
                                        poemController.isLoading.value = false;
                                      },
                                child: poemController.isLoading
                                        .value // عرض مؤشر التحميل إذا كان قيد التحميل
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : const CustomBodyText(
                                        text: 'إضافة البيت',
                                      ),
                              ),
                            )
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

  // حقل إدخال مع أيقونة
  Widget _buildPoemInfoTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      minLines: 1,
      maxLines: 10,
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'يرجى ملء الحقل' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.brown[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  // طريقة بناء الحقول الديناميكية
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
          Card(
            child: ListTile(
              title: CustomBodyText(
                text: label,
              ),
              trailing: Container(
                height: 35,
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
                child: TextButton(
                    onPressed: () {
                      keyControllers.add(TextEditingController());
                      valueControllers.add(TextEditingController());
                    },
                    child: const Icon(Icons.add_circle)),
              ),
            ),
          ),

          const SizedBox(height: 10),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: keyControllers.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      // الحقل الأول
                      Expanded(
                        child: _buildDynamicTextField(
                          controller: keyControllers[index],
                          hint: keyLabel,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // الحقل الثاني
                      Expanded(
                        child: _buildDynamicTextField(
                          controller: valueControllers[index],
                          hint: valueLabel,
                        ),
                      ),
                      // أيقونة الإزالة
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
          // زر إضافة حقل جديد
        ],
      );
    });
  }

  // حقل إدخال ديناميكي معزّز
  Widget _buildDynamicTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      minLines: 1,
      maxLines: 10,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // حقل إدخال ثابت مع أيقونة
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى ملئ الحقل';
        }
        return null; // المدخل صحيح
      },
      minLines: 1,
      maxLines: 10,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFCC8400),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  // دالة لاختيار الصورة
  Widget _imagePickerWidget(String label, IconData icon, BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            title: CustomBodyText(
              text: label,
            ),
            trailing: Container(
              height: 35,
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
              child: TextButton(
                onPressed: () {
                  if (poemController.selectedImage.value != null) {
                    poemController.selectedImage.value = null;
                  }
                  poemController.selectImage(); // استدعاء دالة اختيار الصورة
                },
                child: Icon(icon),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),
        // عرض الصورة إذا تم اختيارها
        Obx(
          () {
            String? image = poemController.selectedImage.value?.path;
            return poemController.selectedImage.value != null
                ? _buildFileImageDisplayer(image)
                : const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildFileImageDisplayer(String? imagePath) {
    if (imagePath != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FileImageDisplayer(
          imagePath: imagePath,
        ),
      );
    } else {
      return Container();
    }
  }

  // دالة لاختيار الصوت
  Widget _audioPickerWidget(String label, IconData icon) {
    return Column(
      children: [
        Card(
          child: ListTile(
            title: CustomBodyText(
              text: label,
            ),
            trailing: Container(
              height: 35,
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
              child: TextButton(
                onPressed: () {
                  if (poemController.selectedAudio.value != null) {
                    poemController.selectedAudio.value = null;
                  }
                  poemController.selectAudio(); // استدعاء دالة اختيار الصوت
                },
                child: Icon(icon),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // عرض الملف الصوتي إذا تم اختياره
        Obx(() {
          return poemController.selectedAudio.value != null
              ? FileVoiceCardPlayer(
                  audioSource: poemController.selectedAudio.value!.path,
                )
              : const SizedBox();
        }),
      ],
    );
  }
}
