class PayInfoModel {
  final double price; // سعر الدفع
  final Map<String, String>
      paymentMethods; // خريطة تحتوي على طريقة الدفع ورقمها

  PayInfoModel({
    required this.price,
    required this.paymentMethods,
  });

  // تحويل من Map إلى PayInfoModel
  factory PayInfoModel.fromMap(Map<String, dynamic> map) {
    return PayInfoModel(
      price: map['price']?.toDouble() ?? 0.0, // التأكد من أن السعر قيمة double
      paymentMethods: Map<String, String>.from(map['paymentMethods'] ?? {}),
    );
  }

  // تحويل من PayInfoModel إلى Map لتخزينه في Firestore أو أي قاعدة بيانات أخرى
  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'paymentMethods': paymentMethods,
    };
  }
}
