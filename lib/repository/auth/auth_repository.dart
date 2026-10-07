import 'package:get/get.dart';
import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/store_client_metadata.dart';
import '../../core/model/otp_model.dart';

enum AuthFailureKind {
  offline,
  invalidCredentials,
  blocked,
  validation,
  otpInvalid,
  otpExpired,
  upgradeRequired,
  malformed,
  server,
}

enum AuthUiStatus {
  idle,
  submitting,
  validationError,
  success,
  offline,
  blocked,
  upgradeRequired,
  otpInvalid,
  otpExpired,
  failure,
}

sealed class AuthResult<T> {
  const AuthResult();
}

class AuthSuccess<T> extends AuthResult<T> {
  const AuthSuccess(this.data);

  final T data;
}

class AuthFailure<T> extends AuthResult<T> {
  const AuthFailure({required this.kind, required this.messageKey});

  final AuthFailureKind kind;
  final String messageKey;
}

class StoreAuthenticatedSession {
  const StoreAuthenticatedSession({
    required this.userId,
    required this.token,
    required this.displayName,
    required this.email,
    required this.accountRoles,
    this.typeUser,
  });

  final String userId;
  final String token;
  final String displayName;
  final String email;
  final List<String> accountRoles;
  final String? typeUser;
}

abstract interface class StoreAuthGateway {
  Future<AuthResult<StoreAuthenticatedSession>> authenticate({
    required String identifier,
    required String password,
    required String notificationToken,
  });

  Future<AuthResult<bool>> createAccount({
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    required DateTime timestamp,
  });

  Future<AuthResult<ForgotPasswordResponse>> requestPasswordReset({
    required String identifier,
  });

  Future<AuthResult<OtpVerificationResponse>> verifyPasswordResetOtp({
    required String identifier,
    required String otp,
  });

  Future<AuthResult<bool>> resetPassword({
    required String resetProof,
    required String newPassword,
    required String confirmPassword,
  });
}

class AuthRepository extends GetxService implements StoreAuthGateway {
  final ApiClient apiClient;
  AuthRepository({required this.apiClient, StoreClientMetadata? clientMetadata})
    : clientMetadata = clientMetadata ?? StoreClientMetadata();

  final StoreClientMetadata clientMetadata;

  @override
  Future<AuthResult<StoreAuthenticatedSession>> authenticate({
    required String identifier,
    required String password,
    required String notificationToken,
  }) async {
    final response = await login(identifier, password, notificationToken);
    if (response.statusCode != 200) {
      return _failureFromResponse(
        response,
        fallbackKey: 'storeAuthInvalidCredentials',
      );
    }

    final body = response.body;
    if (body is! Map || body['user'] is! Map) {
      return const AuthFailure(
        kind: AuthFailureKind.malformed,
        messageKey: 'storeAuthMalformedResponse',
      );
    }
    final user = Map<Object?, Object?>.from(body['user'] as Map);
    if (user['block'] == true) {
      return const AuthFailure(
        kind: AuthFailureKind.blocked,
        messageKey: 'storeAuthBlocked',
      );
    }

    final userId = _nonEmpty(user['id']);
    final token = _nonEmpty(body['token']);
    final email = _nonEmpty(user['email']);
    if (userId == null || token == null || email == null) {
      return const AuthFailure(
        kind: AuthFailureKind.malformed,
        messageKey: 'storeAuthMalformedResponse',
      );
    }

    final roles =
        user['accountRoles'] is List
            ? (user['accountRoles'] as List)
                .whereType<Object>()
                .map((role) => role.toString())
                .toList(growable: false)
            : const <String>[];
    return AuthSuccess(
      StoreAuthenticatedSession(
        userId: userId,
        token: token,
        displayName:
            _nonEmpty(user['fullName']) ?? _nonEmpty(user['userName']) ?? email,
        email: email,
        accountRoles: roles,
        typeUser: _nonEmpty(user['typeUser']),
      ),
    );
  }

  @override
  Future<AuthResult<bool>> createAccount({
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    required DateTime timestamp,
  }) async {
    final response = await register(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      passwordConfirmation: passwordConfirmation,
      date: timestamp.toUtc().toIso8601String(),
    );
    if (response.statusCode == 200) return const AuthSuccess(true);
    return _failureFromResponse(
      response,
      fallbackKey: 'storeRegistrationFailed',
    );
  }

  @override
  Future<AuthResult<ForgotPasswordResponse>> requestPasswordReset({
    required String identifier,
  }) async {
    final response = await forgotPassword(email: identifier);
    if (response.statusCode != 200) {
      return _failureFromResponse(
        response,
        fallbackKey: 'storeRecoveryRequestFailed',
      );
    }
    try {
      if (response.body is! Map) throw const FormatException();
      return AuthSuccess(
        ForgotPasswordResponse.fromJson(
          Map<String, dynamic>.from(response.body as Map),
        ),
      );
    } catch (_) {
      return const AuthFailure(
        kind: AuthFailureKind.malformed,
        messageKey: 'storeAuthMalformedResponse',
      );
    }
  }

  @override
  Future<AuthResult<OtpVerificationResponse>> verifyPasswordResetOtp({
    required String identifier,
    required String otp,
  }) async {
    final response = await verifyForgotPasswordOtp(email: identifier, otp: otp);
    if (response.statusCode != 200) {
      return _failureFromResponse(
        response,
        fallbackKey: 'storeOtpInvalid',
        otpResponse: true,
      );
    }
    try {
      if (response.body is! Map) throw const FormatException();
      final model = OtpVerificationResponse.fromJson(
        Map<String, dynamic>.from(response.body as Map),
      );
      if (model.resetProof.trim().isEmpty) throw const FormatException();
      return AuthSuccess(model);
    } catch (_) {
      return const AuthFailure(
        kind: AuthFailureKind.malformed,
        messageKey: 'storeAuthMalformedResponse',
      );
    }
  }

  @override
  Future<AuthResult<bool>> resetPassword({
    required String resetProof,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await changePasswordToForgot(
      resetProof: resetProof,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    if (response.statusCode == 200) return const AuthSuccess(true);
    return _failureFromResponse(response, fallbackKey: 'storeResetFailed');
  }

  AuthFailure<T> _failureFromResponse<T>(
    Response response, {
    required String fallbackKey,
    bool otpResponse = false,
  }) {
    if (response.statusCode == 1 || response.statusCode == 0) {
      return const AuthFailure(
        kind: AuthFailureKind.offline,
        messageKey: 'storeAuthOffline',
      );
    }
    if (response.statusCode == 426) {
      return const AuthFailure(
        kind: AuthFailureKind.upgradeRequired,
        messageKey: 'storeUpgradeRequiredRecovery',
      );
    }

    final message =
        response.body is Map
            ? (response.body as Map)['message']?.toString().toLowerCase() ?? ''
            : '';
    if (message.contains('block') || message.contains('closed')) {
      return const AuthFailure(
        kind: AuthFailureKind.blocked,
        messageKey: 'storeAuthBlocked',
      );
    }
    if (otpResponse && message.contains('expir')) {
      return const AuthFailure(
        kind: AuthFailureKind.otpExpired,
        messageKey: 'storeOtpExpired',
      );
    }
    if (otpResponse) {
      return const AuthFailure(
        kind: AuthFailureKind.otpInvalid,
        messageKey: 'storeOtpInvalid',
      );
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      return const AuthFailure(
        kind: AuthFailureKind.invalidCredentials,
        messageKey: 'storeAuthInvalidCredentials',
      );
    }
    if (response.statusCode == 400 || response.statusCode == 422) {
      return AuthFailure(
        kind: AuthFailureKind.validation,
        messageKey: fallbackKey,
      );
    }
    return AuthFailure(kind: AuthFailureKind.server, messageKey: fallbackKey);
  }

  String? _nonEmpty(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  Future<Response> login(email, password, userToken) async {
    return await apiClient.postData(
      "/Auth/login",
      body: {"email": email, "password": password, "userToken": userToken},
    );
  }

  Future<Response> register({
    required email,
    required phoneNumber,
    required password,
    required passwordConfirmation,
    required date,
  }) async {
    return await apiClient.postData(
      '/Users/Register',
      body: {
        "email": email,
        "phoneNumber": phoneNumber,
        "password": password,
        "confirmPassword": passwordConfirmation,
        "dateAdd": date,
        "userUpdate": "0",
        "dateUpdate": date,
      },
    );
  }

  Future<Response> userEdit({
    required String email,
    required String phoneNumber,
    required String address,
    required String fullName,
    required String phoneNumber2,
    required String cityId,
  }) async {
    return await apiClient.postData(
      "/Users/Edit",
      body: {
        "email": email,
        "phoneNumber": phoneNumber,
        "address": address,
        "fullName": fullName,
        "phoneNumber2": phoneNumber2,
        "cityId": cityId,
      },
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> getUser() async {
    String? id = await AppUsageService.getUserId();
    return await apiClient.postData(
      '/Users/GetById?id=$id',
      body: {
        "listRelatedObjects": ["<string>", "<string>"],
        "entity": {"nullable": true},
        "listOrderOptions": ["<string>", "<string>"],
        "paginationInfo": {"pageIndex": 0, "pageSize": 0},
      },
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> uploadProfileImage(String filePath) async =>
      apiClient.postMultipart(
        '/Users/ProfileImage',
        filePath: filePath,
        headers: {
          'authorization': 'Bearer ${await AppUsageService.getToken()}',
        },
      );

  Future<Map<String, String>> _storeHeaders() async => {
    'Content-Type': 'application/json',
    'authorization': 'Bearer ${await AppUsageService.getToken()}',
  };

  Future<Response> getStoreAddresses() async => apiClient.getData(
    '/OnlineStore/Addresses',
    headers: await _storeHeaders(),
  );

  Future<Response> createStoreAddress(Map<String, dynamic> body) async =>
      apiClient.postData(
        '/OnlineStore/Addresses',
        headers: await _storeHeaders(),
        body: body,
      );

  Future<Response> updateStoreAddress(Map<String, dynamic> body) async =>
      apiClient.postData(
        '/OnlineStore/Addresses/Update',
        headers: await _storeHeaders(),
        body: body,
      );

  Future<Response> deleteStoreAddress(int addressId) async =>
      apiClient.postData(
        '/OnlineStore/Addresses/Delete',
        headers: await _storeHeaders(),
        body: {'address_id': addressId},
      );

  Future<Response> getCity() async {
    return await apiClient.postData(
      '/Cities/GetAllCities',
      body: {
        "listRelatedObjects": ["City"],
        "entity": {"nullable": true},
        "listOrderOptions": ["<string>", "<string>"],
        "paginationInfo": {"pageIndex": 0, "pageSize": 0},
      },
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> forgotPassword({required String email}) async {
    return await apiClient.postData(
      '/Auth/ForgotPassword',
      body: {'Email': email, ...await clientMetadata.asJson()},
    );
  }

  Future<Response> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    return await apiClient.postData(
      '/Auth/VerifyForgotPasswordOtp',
      body: {'Email': email, 'otp': otp, ...await clientMetadata.asJson()},
    );
  }

  Future<Response> changePassword({
    required oldPassword,
    required newPassword,
    required confirmPassword,
    required dateUpdate,
  }) async {
    return await apiClient.postData(
      '/Auth/ChangePassword',
      body: {
        "userId": await AppUsageService.getUserId(),
        "oldPassword": oldPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
        "userUpdate": await AppUsageService.getUserId(),
        "dateUpdate": dateUpdate,
      },
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> getAllOrder(statusOrder) async {
    String? id = await AppUsageService.getUserId();
    return await apiClient.postData(
      '/Orders/GetAllOrdersByUserId?statusOrder=$statusOrder&userId=$id',
      body: {
        "listRelatedObjects": [
          "ViewImgs",
          "NormalImgs",
          "_3DImgs",
          "SupCategories",
          "ItemSize",
          "ItemColor",
          "OrderDetails",
        ],
        "entity": {"nullable": true},
        "listOrderOptions": ["<string>", "<string>"],
        "paginationInfo": {"pageIndex": 0, "pageSize": 0},
      },
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> editAllOrder(body) async {
    return await apiClient.postData(
      '/Orders/ManageOrder',
      body: body,
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> cancelOrder({required String orderId}) async {
    final userId = await AppUsageService.getUserId();
    return await apiClient.postData(
      '/Orders/CancelOrder?id=$orderId&userId=$userId',
      body: {
        "id": orderId,
        "userId": userId,
        "userUpdate": userId,
        "status": "Canceled",
      },
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> deleteUserAccount() async {
    String? userId = await AppUsageService.getUserId();
    return await apiClient.postData(
      '/Users/BlockUserAndNotActive?userId=$userId',

      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> changePasswordToForgot({
    required String resetProof,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await apiClient.patch(
      '/Auth/ChangePasswordToForgot',
      body: {
        "resetProof": resetProof,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
        ...await clientMetadata.asJson(),
      },
    );
  }

  Future<Response> checkUser() async {
    String? id = await AppUsageService.getUserId();
    return await apiClient.postData(
      '/Auth/CheckUser?UserId=$id',
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> checkSettingAndConactUs() async {
    return await apiClient.postData('/Settings/CheckSetting');
  }
}
