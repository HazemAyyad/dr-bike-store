class ForgotPasswordResponse {
  const ForgotPasswordResponse({required this.status, required this.message});

  final String status;
  final String message;

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResponse(
        status: json['status'] as String,
        message: json['message'] as String,
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
