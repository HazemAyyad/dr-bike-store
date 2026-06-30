class ConactUsModel {
  Data data;
  bool isSuccess;
  dynamic error;
  bool isFailure;

  ConactUsModel({
    required this.data,
    required this.isSuccess,
    required this.error,
    required this.isFailure,
  });

  factory ConactUsModel.fromJson(Map<String, dynamic> json) {
    return ConactUsModel(
      data: Data.fromJson(json['data']),
      isSuccess: json['isSuccess'],
      error: json['error'] ?? '',
      isFailure: json['isFailure'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'isSuccess': isSuccess,
      'error': error,
      'isFailure': isFailure,
    };
  }
}

class Data {
  int? id;
  bool isClose;
  String? message;
  String? call;
  String? whatsApp;
  String? instagram;
  String? twitter;

  Data({
    required this.id,
    required this.isClose,
    this.message,
    this.call,
    this.whatsApp,
    this.instagram,
    this.twitter,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      isClose: json['isClose'],
      message: json['message'] ?? '',
      call: json['call'] ?? '',
      whatsApp: json['whatsApp'] ?? '',
      instagram: json['instagram'] ?? '',
      twitter: json['twitter'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isClose': isClose,
      'message': message,
      'call': call,
      'whatsApp': whatsApp,
      'instagram': instagram,
      'twitter': twitter,
    };
  }
}
///////////////////

class ApiResponse {
  final Data data;
  final bool isSuccess;
  final String? error;
  final bool isFailure;

  ApiResponse({
    required this.data,
    required this.isSuccess,
    this.error,
    required this.isFailure,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      data: Data.fromJson(json['data']),
      isSuccess: json['isSuccess'],
      error: json['error'],
      isFailure: json['isFailure'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'isSuccess': isSuccess,
      'error': error,
      'isFailure': isFailure,
    };
  }
}

class Data2 {
  final int id;
  final bool isClose;
  final String? message;
  final String? call;
  final String? whatsApp;
  final String? instagram;
  final String? twitter;

  Data2({
    required this.id,
    required this.isClose,
    this.message,
    this.call,
    this.whatsApp,
    this.instagram,
    this.twitter,
  });

  factory Data2.fromJson(Map<String, dynamic> json) {
    return Data2(
      id: json['id'],
      isClose: json['isClose'],
      message: json['message'],
      call: json['call'],
      whatsApp: json['whatsApp'],
      instagram: json['instagram'],
      twitter: json['twitter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isClose': isClose,
      'message': message,
      'call': call,
      'whatsApp': whatsApp,
      'instagram': instagram,
      'twitter': twitter,
    };
  }
}
