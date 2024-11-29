// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:paligolshir/models/poem_model.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class PoemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
    final cloudinary = CloudinaryPublic('dxjoxyu0f', 'we6aimfv', cache: false);

  final String poemDocumentId = "single_poem"; // معرف ثابت للوثيقة

  // 1. رفع بيانات القصيدة (استخدام وثيقة واحدة فقط)
  Future<void> uploadPoem(Poem poem) async {
    try {
      // تحويل القصيدة إلى JSON ورفعها
      await _firestore
          .collection('poem')
          .doc(poemDocumentId)
          .set(poem.toJson());
      print("تم رفع القصيدة بنجاح");
    } catch (e) {
      print("خطأ في رفع القصيدة: $e");
    }
  }

  // 2. استرجاع بيانات القصيدة (استخدام وثيقة واحدة فقط)
  Future<Poem?> fetchPoem() async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('poem').doc(poemDocumentId).get();

      if (docSnapshot.exists) {
        // تحويل البيانات من JSON إلى كائن Poem
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        Poem poem = Poem.fromJson(data);
        return poem;
      } else {
        print("القصيدة غير موجودة");
        return null;
      }
    } catch (e) {
      print("خطأ في استرجاع القصيدة: $e");
      return null;
    }
  }

  Future<void> updatePoemInfo(Poem updatedPoem) async {
    try {
      // Assuming you have a collection called "poems"
      await _firestore.collection('poem').doc(poemDocumentId).update({
        'title': updatedPoem.title,
        'author': updatedPoem.author,
        'description': updatedPoem.description,
        'price': updatedPoem.price,
        'paymentMethods': updatedPoem.paymentMethods,
      });
    } catch (e) {
      throw Exception('Failed to update poem: $e');
    }
  }

  // 3. استرجاع بيانات القصيدة كـ Stream (استخدام وثيقة واحدة فقط)
  Stream<Poem?> getPoemStream() {
    return _firestore
        .collection('poem')
        .doc(poemDocumentId)
        .snapshots()
        .map((DocumentSnapshot docSnapshot) {
      if (docSnapshot.exists) {
        // تحويل البيانات من JSON إلى كائن Poem
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        return Poem.fromJson(data);
      } else {
        print("القصيدة غير موجودة");
        return null;
      }
    });
  }

  Stream<Poem?> getPoemFreeStream() {
    return _firestore.collection('poem').doc(poemDocumentId).snapshots().map(
      (DocumentSnapshot docSnapshot) {
        if (docSnapshot.exists) {
          // تحويل البيانات من JSON إلى كائن Poem
          Map<String, dynamic> data =
              docSnapshot.data() as Map<String, dynamic>;

          // استخراج الأسطر وتحويلها إلى قائمة من كائنات Line
          List<dynamic> linesData = data['lines'] ?? [];

          // تحويل كل عنصر من القائمة إلى كائن Line
          List<Line> allLines = linesData.map(
            (lineData) {
              return Line(
                hemistich1: lineData['hemistich1'] ?? '',
                hemistich2: lineData['hemistich2'] ?? '',
                prose: lineData['prose'] ?? '',
                grammarAnalysis:
                    Map<String, String>.from(lineData['grammarAnalysis'] ?? {}),
                rhetoricAnalysis: Map<String, String>.from(
                    lineData['rhetoricAnalysis'] ?? {}),
                wordMeanings:
                    Map<String, String>.from(lineData['wordMeanings'] ?? {}),
                imageUrl: lineData['imageUrl'] ?? '',
                voiceUrl: lineData['voiceUrl'] ?? '',
              );
            },
          ).toList();

          // أخذ أول سطرين فقط
          List<Line> firstTwoLines = allLines.take(10).toList();

          // تحديث البيانات مع السطرين الأولين فقط
          data['lines'] = firstTwoLines
              .map(
                (line) => {
                  'hemistich1': line.hemistich1,
                  'hemistich2': line.hemistich2,
                  'prose': line.prose,
                  'grammarAnalysis': line.grammarAnalysis,
                  'rhetoricAnalysis': line.rhetoricAnalysis,
                  'wordMeanings': line.wordMeanings,
                  'imageUrl': line.imageUrl,
                  'voiceUrl': line.voiceUrl,
                },
              )
              .toList();

          return Poem.fromJson(data);
        } else {
          print("القصيدة غير موجودة");
          return null;
        }
      },
    );
  }

  // 4. حذف بيت من القصيدة
  Future<void> deleteLine(int lineIndex) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('poem').doc(poemDocumentId).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        Poem poem = Poem.fromJson(data);

        if (lineIndex >= 0 && lineIndex < poem.lines!.length) {
          // حذف البيت من القائمة
          poem.lines!.removeAt(lineIndex);

          // رفع القصيدة المحدثة مرة أخرى إلى Firestore
          await uploadPoem(poem);

          print("تم حذف البيت بنجاح");
        } else {
          print("البيت غير موجود في الفهرس المحدد");
        }
      } else {
        print("القصيدة غير موجودة");
      }
    } catch (e) {
      print("خطأ في حذف البيت: $e");
    }
  }

  // استرجاع قائمة الأسطر مباشرة من وثيقة القصيدة في Firestore
  Future<List<Line>?> fetchLines() async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('poem').doc(poemDocumentId).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // تحويل قائمة الأسطر من JSON إلى كائنات Line
        List<Line> lines = (data['lines'] as List)
            .map((lineJson) => Line.fromJson(lineJson))
            .toList();

        return lines;
      } else {
        print("القصيدة غير موجودة");
        return null;
      }
    } catch (e) {
      print("خطأ في استرجاع الأسطر: $e");
      return null;
    }
  }

  String removeDiacritics(String input) {
    final diacritics = RegExp(r'[\u064B-\u0652]');
    return input.replaceAll(diacritics, '');
  }

  // دالة البحث في قائمة الأسطر
  List<Line> searchLines(List<Line> lines, String query) {
    final lowerQuery = removeDiacritics(query.toLowerCase());

    return lines.where((line) {
      // إزالة التشكيل من الخصائص النصية للمقارنة
      final hemistich1 = removeDiacritics(line.hemistich1.toLowerCase());
      final hemistich2 = removeDiacritics(line.hemistich2.toLowerCase());
      final prose = removeDiacritics(line.prose.toLowerCase());
      if (hemistich1.toLowerCase().contains(lowerQuery) ||
          hemistich2.toLowerCase().contains(lowerQuery) ||
          prose.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      if (line.grammarAnalysis.entries.any((entry) =>
          removeDiacritics(entry.key.toLowerCase()).contains(lowerQuery) ||
          removeDiacritics(entry.value.toLowerCase()).contains(lowerQuery))) {
        return true;
      }

      if (line.rhetoricAnalysis.entries.any((entry) =>
          removeDiacritics(entry.key.toLowerCase()).contains(lowerQuery) ||
          removeDiacritics(entry.value.toLowerCase()).contains(lowerQuery))) {
        return true;
      }

      if (line.wordMeanings.entries.any((entry) =>
          removeDiacritics(entry.key.toLowerCase()).contains(lowerQuery) ||
          removeDiacritics(entry.value.toLowerCase()).contains(lowerQuery))) {
        return true;
      }

      return false;
    }).toList();
  }

  // استرجاع أول 10 أسطر فقط من وثيقة القصيدة في Firestore
  Future<List<Line>?> fetchLimitedLines(int limit) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('poem').doc(poemDocumentId).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // تحويل قائمة الأسطر من JSON إلى كائنات Line واختيار أول 10 أسطر فقط
        List<Line> lines = (data['lines'] as List)
            .map((lineJson) => Line.fromJson(lineJson))
            .take(limit)
            .toList();

        return lines;
      } else {
        print("القصيدة غير موجودة");
        return null;
      }
    } catch (e) {
      print("خطأ في استرجاع الأسطر: $e");
      return null;
    }
  }

  // Pick an image and return File
  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  // Pick an audio file and return File
  Future<File?> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null) return null;
    return File(result.files.single.path!);
  }

  // Upload file to Firebase Storage and return download URL
  // Future<String?> uploadFile(File file, String folder) async {
  //   try {
  //     String fileName = basename(file.path);
  //     Reference storageRef = _firebaseStorage.ref().child('$folder/$fileName');
  //     await storageRef.putFile(file);
  //     return await storageRef.getDownloadURL();
  //   } catch (e) {
  //     print("Error uploading file: $e");
  //     return null;
  //   }
  // }





  Future<String?> uploadFile(File file, String folder) async {
    try {
    //  String fileName = basename(file.path);

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, folder: folder),
      );

      return response.secureUrl;
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  // حفظ رابط الصورة في قاعدة البيانات فقط
  Future<void> saveImageUrl(String docId, String imageUrl) async {
    await _firestore.collection('poems').doc(docId).update({
      'imageUrl': imageUrl,
    });
  }

  // حفظ رابط الصوت في قاعدة البيانات فقط
  Future<void> saveAudioUrl(String docId, String audioUrl) async {
    await _firestore.collection('poems').doc(docId).update({
      'audioUrl': audioUrl,
    });
  }
}
