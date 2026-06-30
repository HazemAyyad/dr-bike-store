class OtpModel {
  final String email;
  final String userId;
  final int otp;

  OtpModel({required this.email, required this.userId, required this.otp});

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      email: json['email'],
      userId: json['userId'],
      otp: json['otp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userId': userId,
      'otp': otp,
    };
  }
}
