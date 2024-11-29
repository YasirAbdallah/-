// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/poem_controller.dart';
import 'package:paligolshir/models/poem_model.dart';
import 'package:paligolshir/views/admin/admin_page.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';
import 'package:paligolshir/views/helpers/file_image_displayer.dart';
import 'package:paligolshir/views/helpers/file_voice_card.dart';
import 'package:paligolshir/views/helpers/url_image_displayer.dart';
import 'package:paligolshir/views/helpers/url_voice_card.dart';

class AdminLineEditPage extends StatefulWidget {
  final Line line;
  final int lineIndex;

  const AdminLineEditPage({
    super.key,
    required this.line,
    required this.lineIndex,
  });

  @override
  _AdminLineEditPageState createState() => _AdminLineEditPageState();
}

class _AdminLineEditPageState extends State<AdminLineEditPage> {
  final PoemController _controller = Get.find<PoemController>();
  final RxBool _isLoading = false.obs;

  late TextEditingController _hemistich1Controller;
  late TextEditingController _hemistich2Controller;
  late TextEditingController _proseController;
  final GlobalKey<FormState> _lineInfoFormKey = GlobalKey<FormState>();

  final RxList<TextEditingController> _grammarKeyControllers = RxList();
  final RxList<TextEditingController> _grammarValueControllers = RxList();
  final RxList<TextEditingController> _rhetoricKeyControllers = RxList();
  final RxList<TextEditingController> _rhetoricValueControllers = RxList();
  final RxList<TextEditingController> _wordMeaningKeyControllers = RxList();
  final RxList<TextEditingController> _wordMeaningValueControllers = RxList();

  @override
  void initState() {
    super.initState();

    _hemistich1Controller = TextEditingController(text: widget.line.hemistich1);
    _hemistich2Controller = TextEditingController(text: widget.line.hemistich2);
    _proseController = TextEditingController(text: widget.line.prose);

    _initializeControllers(widget.line.grammarAnalysis, _grammarKeyControllers,
        _grammarValueControllers);
    _initializeControllers(widget.line.rhetoricAnalysis,
        _rhetoricKeyControllers, _rhetoricValueControllers);
    _initializeControllers(widget.line.wordMeanings, _wordMeaningKeyControllers,
        _wordMeaningValueControllers);
  }

  void _initializeControllers(
    Map<String, String> data,
    RxList<TextEditingController> keyControllers,
    RxList<TextEditingController> valueControllers,
  ) {
    data.forEach((key, value) {
      keyControllers.add(TextEditingController(text: key));
      valueControllers.add(TextEditingController(text: value));
    });
  }

  @override
  void dispose() {
    _hemistich1Controller.dispose();
    _hemistich2Controller.dispose();
    _proseController.dispose();

    for (var controller in [
      ..._grammarKeyControllers,
      ..._grammarValueControllers,
      ..._rhetoricKeyControllers,
      ..._rhetoricValueControllers,
      ..._wordMeaningKeyControllers,
      ..._wordMeaningValueControllers,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _saveUpdatedLine() async {
    _isLoading.value = true;
    await _controller.uploadMedia();
    _controller.uploadMedia();

    String? savedImage;
    if (_controller.imageUrl!.isEmpty && widget.line.imageUrl != null) {
      savedImage = widget.line.imageUrl;
    } else if (_controller.imageUrl!.isNotEmpty) {
      savedImage = _controller.imageUrl!.value;
    } else {
      savedImage = null;
    }

    String? savedAudio;
    if (_controller.audioUrl!.isEmpty && widget.line.voiceUrl != null) {
      savedAudio = widget.line.voiceUrl;
    } else if (_controller.audioUrl!.isNotEmpty) {
      savedAudio = _controller.audioUrl!.value;
    } else {
      savedAudio = null; // Ensure savedAudio is not an empty string
    }
    try {
      Line updatedLine = Line(
        hemistich1: _hemistich1Controller.text,
        hemistich2: _hemistich2Controller.text,
        prose: _proseController.text,
        grammarAnalysis:
            _buildMap(_grammarKeyControllers, _grammarValueControllers),
        rhetoricAnalysis:
            _buildMap(_rhetoricKeyControllers, _rhetoricValueControllers),
        wordMeanings:
            _buildMap(_wordMeaningKeyControllers, _wordMeaningValueControllers),
        imageUrl: savedImage,
        voiceUrl: savedAudio,
      );
      await _controller.editLine(widget.lineIndex, updatedLine);
      Get.off(AdminPage());
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _controller.selectedImage.value = null;
        _controller.selectedAudio.value = null;
        return Future.value(true); // لضمان الإرجاع من النوع Future<bool>
      },
      child: MediaQuery(
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
                text: 'تعديل البيت',
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
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
                  child: Obx(
                    () {
                      if (_isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Form(
                        key: _lineInfoFormKey,
                        child: ListView(
                          children: [
                            _buildGradientCard(
                                'صدر البيت', _hemistich1Controller),
                            _buildGradientCard(
                                'عجز البيت', _hemistich2Controller),
                            _buildGradientCard('النثر', _proseController,
                                maxLines: 3),
                            _audioPickerWidget('إضافة تسجيل', Icons.audiotrack,
                                widget.line.voiceUrl),
                            const SizedBox(height: 30),
                            _imagePickerWidget('إضافة صورة', Icons.image, context,
                                widget.line.imageUrl),
                            _buildDynamicFields('علوم النحو', 'المفتاح', 'القيمة',
                                _grammarKeyControllers, _grammarValueControllers),
                            _buildDynamicFields(
                                'علوم البلاغة',
                                'المفتاح',
                                'القيمة',
                                _rhetoricKeyControllers,
                                _rhetoricValueControllers),
                            _buildDynamicFields(
                                'معاني الكلمات',
                                'المفتاح',
                                'القيمة',
                                _wordMeaningKeyControllers,
                                _wordMeaningValueControllers),
                            Obx(
                              () {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(
                                              0xFFFFD700), // اللون الذهبي الأساسي
                                          Color(0xFFFFC107), // لون ذهبي أفتح
                                          Color(0xFFFFD700), // لون برتقالي ذهبي
                                          Color(0xFFCC8400), // لون ذهبي داكن
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: TextButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: _isLoading.value
                                          ? null
                                          : () {
                                              _saveUpdatedLine();
                                              _controller.selectedImage.value =
                                                  null;
                                              _controller.selectedAudio.value =
                                                  null;
                                            },
                                      child: _isLoading.value
                                          ? const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            )
                                          : const CustomBodyText(
                                              text: 'حفظ التعديلات',
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientCard(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFD700),
                Color(0xFFFFC107),
                Color(0xFFFFA500),
                Color(0xFFCC8400)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBodyText(
                text: label,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller,
                maxLines: maxLines,
                decoration: InputDecoration(
                  hintText: label,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _buildMap(
    RxList<TextEditingController> keyControllers,
    RxList<TextEditingController> valueControllers,
  ) {
    Map<String, String> map = {};
    for (int i = 0; i < keyControllers.length; i++) {
      map[keyControllers[i].text] = valueControllers[i].text;
    }
    return map;
  }

  Widget _buildDynamicFields(
    String label,
    String keyLabel,
    String valueLabel,
    RxList<TextEditingController> keyControllers,
    RxList<TextEditingController> valueControllers,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Card(
              child: ListTile(
                title: CustomBodyText(
                  text: label,
                ),
                trailing: TextButton(
                    onPressed: () {
                      keyControllers.add(TextEditingController());
                      valueControllers.add(TextEditingController());
                    },
                    child: const Icon(
                      Icons.add_circle,
                      color: Color(0xFFCC8400),
                      size: 30,
                    )),
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
                          icon:
                              Icon(Icons.remove_circle, color: Colors.red[400]),
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
      }),
    );
  }

  Widget _buildDynamicTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      minLines: 1,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // دالة لاختيار الصوت
  Widget _audioPickerWidget(String label, IconData icon, String? audioUrl) {
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
                  if (_controller.selectedAudio.value != null) {
                    _controller.selectedAudio.value = null;
                  }
                  _controller.selectAudio(); // استدعاء دالة اختيار الصوت
                },
                child: Icon(icon),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // عرض الملف الصوتي إذا تم اختياره
        Obx(
          () {
            String? selectedAudioPath = _controller.selectedAudio.value?.path;

            // إذا كان هناك ملف صوتي جديد محدد
            if (selectedAudioPath != null && selectedAudioPath.isNotEmpty) {
              return _buildFileVoicePlayer(selectedAudioPath);
            }
            // إذا كان هناك صوت قديم موجود
            else if (audioUrl != null && audioUrl.isNotEmpty) {
              return _buildUrlVoicePlayer(audioUrl);
            } else {
              return const SizedBox(); // نص افتراضي إذا لم يكن هناك صوت
            }
          },
        ),
      ],
    );
  }

  // دالة لاختيار الصورة
  Widget _imagePickerWidget(
      String label, IconData icon, BuildContext context, String? imageUrl) {
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
                  if (_controller.selectedImage.value != null) {
                    _controller.selectedImage.value = null;
                  }
                  _controller.selectImage(); // استدعاء دالة اختيار الصورة
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
            String? selectedImagePath = _controller.selectedImage.value?.path;

            // تحديد الحالة الحالية بناءً على أولية العرض
            if (selectedImagePath != null && selectedImagePath.isNotEmpty) {
              // عرض صورة الملف الذي تم اختياره مؤخرًا
              return _buildFileImageDisplayer(selectedImagePath);
            } else if (imageUrl != null && imageUrl.isNotEmpty) {
              // إذا لم يتم اختيار ملف حديثاً، عرض صورة الرابط
              return _buildUrlImageDisplayer(imageUrl);
            } else {
              // عرض افتراضي إذا لم يكن هناك صورة
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }

  Widget _buildFileVoicePlayer(String? voiceFile) {
    if (voiceFile != null) {
      return FileVoiceCardPlayer(
        audioSource: voiceFile,
      );
    } else {
      return Container();
    }
  }

  Widget _buildUrlVoicePlayer(String? voiceUrl) {
    if (voiceUrl != null) {
      return UrlVoiceCardPlayer(
        audioSource: voiceUrl,
      );
    } else {
      return Container();
    }
  }

  Widget _buildUrlImageDisplayer(String? imageUrl) {
    if (imageUrl != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: UrlImageDisplayer(
          imageUrl: imageUrl,
        ),
      );
    } else {
      return Container();
    }
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
}
