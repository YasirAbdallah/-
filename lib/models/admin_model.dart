class Admin {
  final String name;
  final String email;

  Admin({required this.name, required this.email});

  // تحويل بيانات من خريطة إلى نموذج Admin
  factory Admin.fromMap(Map<String, dynamic> map) {
    // تحقق من أن القيم ليست null قبل تمريرها إلى Admin
    return Admin(
      name: map['name'] != null
          ? map['name'] as String
          : 'غير محدد', // أو يمكنك استخدام قيمة افتراضية
      email: map['email'] != null
          ? map['email'] as String
          : 'غير محدد', // أو استخدام قيمة افتراضية
    );
  }

  // تحويل نموذج Admin إلى خريطة
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }
}
