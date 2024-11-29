// ignore_for_file: public_member_api_docs, sort_constructors_first
class Poem {
  String title;
  String author;
  String description;
  String? price;

  Map<String, String> paymentMethods; // خريطة تحتوي على طريقة الدفع ورقمها
  List<Line>? lines;

  Poem({
    required this.title,
    required this.author,
    required this.description,
    required this.paymentMethods,
     this.price,
    this.lines,
  });

  // لتحويل بيانات من JSON إلى Object
  factory Poem.fromJson(Map<String, dynamic> json) {
    return Poem(
      title: json['title'],
      author: json['author'],
      description: json['description'],
      lines: (json['lines'] as List)
          .map((lineJson) => Line.fromJson(lineJson))
          .toList(),
      price: json['price'],
      paymentMethods: Map<String, String>.from(json['paymentMethods'] ?? {}),
    );
  }

  // لتحويل بيانات من Object إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'paymentMethods': paymentMethods,
      'lines': lines?.map((line) => line.toJson()).toList(),
    };
  }
}

class Line {
  final String hemistich1; // الشطر الأول
  final String hemistich2; // الشطر الثاني
  final String prose; // النثر
  final Map<String, String> grammarAnalysis; // التحليل النحوي
  final Map<String, String> rhetoricAnalysis; // التحليل البلاغي
  final Map<String, String> wordMeanings; // معاني الكلمات
  final String? imageUrl;
  final String? voiceUrl;
  
  Line({
    required this.hemistich1,
    required this.hemistich2,
    required this.prose,
    required this.grammarAnalysis,
    required this.rhetoricAnalysis,
    required this.wordMeanings,
    this.imageUrl,
    this.voiceUrl,
  });

  // لتحويل البيانات إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'hemistich1': hemistich1,
      'hemistich2': hemistich2,
      'prose': prose,
      'grammarAnalysis': grammarAnalysis,
      'rhetoricAnalysis': rhetoricAnalysis,
      'wordMeanings': wordMeanings,
      'voiceUrl': voiceUrl,
      'imageUrl': imageUrl,
    };
  }

  // لتحويل البيانات من JSON
  factory Line.fromJson(Map<String, dynamic> map) {
    return Line(
      hemistich1: map['hemistich1'],
      hemistich2: map['hemistich2'],
      prose: map['prose'],
      imageUrl: map['imageUrl'],
      voiceUrl: map['voiceUrl'],
      grammarAnalysis: Map<String, String>.from(map['grammarAnalysis']),
      rhetoricAnalysis: Map<String, String>.from(map['rhetoricAnalysis']),
      wordMeanings: Map<String, String>.from(map['wordMeanings']),
    );
  }
}
