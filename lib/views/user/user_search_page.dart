import 'package:arabic_font/arabic_font.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/poem_controller.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';

import '../helpers/font_adjuster.dart';

class UserSearchPage extends StatelessWidget {
  final PoemController poemController = Get.put(PoemController());

  UserSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    double fontSize = FontAdjuster.getAdjustedFontSize(context);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        poemController.clearSearchResults();
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
              title: const CustomTitleText(text:'البحث في الابيات'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // حقل البحث
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'ابحث هنا...',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFCC8400), // لون ذهبي داكن
                      ),
                      filled: true,
                      fillColor: Colors.grey[200], // خلفية الحقل
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0), // حواف دائرية
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFCC8400), // لون ذهبي داكن
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      hintText: 'ابحث عن الكلمة أو السطر...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    onChanged: (query) async {
                      // تنفيذ عملية البحث وحفظ query
                      await poemController.search(query);
                    },
                  ),
        
                  const SizedBox(height: 20),
                  // عرض نتائج البحث
                  Expanded(
                    child: Obx(() {
                      // متابعة المتغيرات باستخدام Obx لعرض النتائج مباشرة
                      final results = poemController.searchResults;
                      final query = poemController.searchQuery.value;
        
                      // التحقق من وجود نتائج
                      if (results.isEmpty) {
                        return const Center(
                            child: CustomBodyText(text: 'لا توجد نتائج مطابقة.'));
                      }
        
                      // عرض قائمة النتائج
                      return ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final line = results[index];
        
                          // تحديد مكان المطابقة حسب الحقل
                          String matchSource;
                          String matchingText;
        
                          // استخدام دالة removeDiacritics من PoemController
                          String normalizedQuery =
                              poemController.removeDiacritics(query);
        
                          if (poemController
                              .removeDiacritics(line.hemistich1)
                              .toLowerCase()
                              .contains(normalizedQuery.toLowerCase())) {
                            matchSource = 'صدر البيت';
                            matchingText = line.hemistich1;
                          } else if (poemController
                              .removeDiacritics(line.hemistich2)
                              .toLowerCase()
                              .contains(normalizedQuery.toLowerCase())) {
                            matchSource = 'عجز البيت';
                            matchingText = line.hemistich2;
                          } else if (poemController
                              .removeDiacritics(line.prose)
                              .toLowerCase()
                              .contains(normalizedQuery.toLowerCase())) {
                            matchSource = 'النثر';
                            matchingText = line.prose;
                          } else if (line.grammarAnalysis.keys.any((key) => poemController
                              .removeDiacritics(key)
                              .toLowerCase()
                              .contains(normalizedQuery.toLowerCase()))) {
                            matchSource = 'التحليل النحوي';
                            matchingText = line.grammarAnalysis.keys.firstWhere(
                                (key) => poemController
                                    .removeDiacritics(key)
                                    .toLowerCase()
                                    .contains(normalizedQuery.toLowerCase()));
                          } else if (line.grammarAnalysis.values.any((value) =>
                              poemController
                                  .removeDiacritics(value)
                                  .toLowerCase()
                                  .contains(normalizedQuery.toLowerCase()))) {
                            matchSource = 'التحليل النحوي';
                            matchingText = line.grammarAnalysis.values.firstWhere(
                                (value) => poemController
                                    .removeDiacritics(value)
                                    .toLowerCase()
                                    .contains(normalizedQuery.toLowerCase()));
                          } else if (line.rhetoricAnalysis.keys.any((key) =>
                              poemController
                                  .removeDiacritics(key)
                                  .toLowerCase()
                                  .contains(normalizedQuery.toLowerCase()))) {
                            matchSource = 'التحليل البلاغي';
                            matchingText = line.rhetoricAnalysis.keys.firstWhere(
                                (key) => poemController
                                    .removeDiacritics(key)
                                    .toLowerCase()
                                    .contains(normalizedQuery.toLowerCase()));
                          } else if (line.rhetoricAnalysis.values
                              .any((value) => poemController.removeDiacritics(value).toLowerCase().contains(normalizedQuery.toLowerCase()))) {
                            matchSource = 'التحليل البلاغي';
                            matchingText = line.rhetoricAnalysis.values
                                .firstWhere((value) => poemController
                                    .removeDiacritics(value)
                                    .toLowerCase()
                                    .contains(normalizedQuery.toLowerCase()));
                          } else if (line.wordMeanings.keys.any((key) => poemController.removeDiacritics(key).toLowerCase().contains(normalizedQuery.toLowerCase()))) {
                            matchSource = 'معاني الكلمات';
                            matchingText = line.wordMeanings.keys.firstWhere(
                                (key) => poemController
                                    .removeDiacritics(key)
                                    .toLowerCase()
                                    .contains(normalizedQuery.toLowerCase()));
                          } else if (line.wordMeanings.values.any((value) => poemController.removeDiacritics(value).toLowerCase().contains(normalizedQuery.toLowerCase()))) {
                            matchSource = 'معاني الكلمات';
                            matchingText = line.wordMeanings.values.firstWhere(
                                (value) => poemController
                                    .removeDiacritics(value)
                                    .toLowerCase()
                                    .contains(normalizedQuery.toLowerCase()));
                          } else {
                            matchSource = 'غير معروف';
                            matchingText = '';
                          }
        
                          // تمييز النص المطابق
                          TextSpan highlightText(String text, String query) {
                            int startIndex =
                                text.toLowerCase().indexOf(query.toLowerCase());
        
                            if (startIndex == -1 || query.isEmpty) {
                              return TextSpan(text: text , style:  ArabicTextStyle(
                                    color: const Color(0xFF32527B),
                                    arabicFont: ArabicFont.changa,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),);
                            }
        
                            final beforeQuery = text.substring(0, startIndex);
                            final queryText = text.substring(
                                startIndex, startIndex + query.length);
                            final afterQuery =
                                text.substring(startIndex + query.length);
                            return TextSpan(
                              children: [
                                TextSpan(
                                  text: beforeQuery,
                                  style: ArabicTextStyle(
                                    color: const Color(0xFF32527B),
                                    arabicFont: ArabicFont.changa,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: queryText,
                                  style: ArabicTextStyle(
                                    color: Colors.blue,
                                    arabicFont: ArabicFont.changa,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: afterQuery,
                                  style: ArabicTextStyle(
                                    color: const Color(0xFF32527B),
                                    arabicFont: ArabicFont.changa,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }
        
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
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
                                title: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AutoSizeText(
                                            maxLines: 1, // عدد الأسطر الأقصى
                                            minFontSize: 14, // الحجم الأدنى للنص
                                            maxFontSize: 15, // الحجم الأقصى للنص
                                            overflow: TextOverflow
                                                .ellipsis, // التعامل مع النص الزائد
                                            line.hemistich1,
                                            style: ArabicTextStyle(
                                              color: const Color(0xFF32527B),
                                              arabicFont: ArabicFont.changa,
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                      const SizedBox(height: 17),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          AutoSizeText(
                                            maxLines: 1, // عدد الأسطر الأقصى
                                            minFontSize: 14, // الحجم الأدنى للنص
                                            maxFontSize: 15, // الحجم الأقصى للنص
                                            overflow: TextOverflow
                                                .ellipsis, // التعامل مع النص الزائد
                                            line.hemistich2,
                                            style: ArabicTextStyle(
                                              color: const Color(0xFF32527B),
                                              arabicFont: ArabicFont.changa,
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                      Text(
                                        '(${index + 1})',
                                        style: ArabicTextStyle(
                                          arabicFont: ArabicFont.changa,
                                          fontSize: fontSize * 0.9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                isThreeLine: true,
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$matchSource :',
                                      style: ArabicTextStyle(
                                        color: const Color(0xFF32527B),
                                        arabicFont: ArabicFont.changa,
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    AutoSizeText.rich(
                                      highlightText(matchingText, query),
                                      minFontSize: 12,
                                      maxFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  await poemController.navigateToLineDetailsPage(
                                      line: line, index: index);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }),
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
