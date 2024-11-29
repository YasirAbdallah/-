class PaymentModel {
  final String? paymentImage;
  final bool? isUpgraded;
   String? adminRespond;
  final String userId;
  final String? userName;
  final String? userPhoto;
  final String? userEmail;

  PaymentModel({
    this.paymentImage,
     this.adminRespond,
    this.isUpgraded,
    required this.userId,
     this.userEmail,
    this.userPhoto,
    this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentImage': paymentImage,
      'adminRespond': adminRespond,
      'isUpgraded': isUpgraded,
      'userId': userId,
      'userEmail': userEmail,
      'userPhoto': userPhoto,
      'userName': userName,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      paymentImage: map['paymentImage'],
      adminRespond: map['adminRespond'],
      isUpgraded: map['isUpgraded'],
      userPhoto: map['userPhoto'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      userId: map['userId'],
    );
  }
}
