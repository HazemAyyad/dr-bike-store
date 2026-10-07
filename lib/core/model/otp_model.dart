class ForgotPasswordResponse {
  const ForgotPasswordResponse({
    required this.status,
    required this.message,
    this.developmentOtp,
  });

  final String status;
  final String message;
  final String? developmentOtp;

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResponse(
        status: json['status'] as String,
        message: json['message'] as String,
        developmentOtp: json['developmentOtp']?.toString(),
      );
}

class OtpVerificationResponse {
  const OtpVerificationResponse({
    required this.status,
    required this.resetProof,
    required this.message,
  });

  final String status;
  final String resetProof;
  final String message;

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) =>
      OtpVerificationResponse(
        status: json['status'] as String,
        resetProof: json['resetProof'] as String,
        message: json['message'] as String,
      );
}
