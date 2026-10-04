import 'package:get/get.dart';
import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/store_client_metadata.dart';

class AuthRepository extends GetxService {
  final ApiClient apiClient;
  AuthRepository({required this.apiClient, StoreClientMetadata? clientMetadata})
    : clientMetadata = clientMetadata ?? StoreClientMetadata();

  final StoreClientMetadata clientMetadata;

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
    required email,
    required phoneNumber,
    required address,
    required block,
    required fullName,
    required phoneNumber2,
    required typeUser,
    required cityId,
    required userUpdate,
  }) async {
    return await apiClient.postData(
      "/Users/Edit",
      body: {
        "id": await AppUsageService.getUserId(),
        "email": email,
        "phoneNumber": phoneNumber,
        "address": address,
        "block": block,
        "fullName": fullName,
        "phoneNumber2": phoneNumber2,
        "typeUser": typeUser,
        "userUpdate": await AppUsageService.getUserId(),
        "dateUpdate": userUpdate,
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
