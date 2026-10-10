import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/account/account_controller.dart';
import '../../controller/auth/forgetpassword.controller.dart';
import '../../controller/auth/login.controller.dart';
import '../../controller/auth/signupController.dart';
import '../../controller/categores/categores_controller.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/favorites/favorites_controller.dart';
import '../../controller/notification/notification_controller.dart';
import '../../controller/order/order_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/product/review_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../repository/auth/auth_repository.dart';
import '../../repository/categories/categories_repository.dart';
import '../../repository/home/home_repository.dart';
import '../../repository/favorites/favorites_repository.dart';
import '../../repository/shop/shop_repository.dart';
import '../../repository/product/review_repository.dart';
import '../../features/support/data/store_support_repository.dart';
import '../../features/support/presentation/store_support_controller.dart';
import '../api_client.dart';

class Mybinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance(),
      permanent: true,
    );

    Get.lazyPut(() => ApiClient(sharedPreferences: Get.find()), fenix: true);
    Get.lazyPut(
      () => LoginControllerImp(
        authRepository: AuthRepository(apiClient: Get.find()),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => FavoritesController(
        repository: FavoritesRepository(apiClient: Get.find()),
        isAuthenticated: () => Get.find<HomeControllerImp>().isAuthenticated,
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => ForgetPasswordControllerImp(
        authRepository: AuthRepository(apiClient: Get.find()),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => SignUpControllerImp(
        authRepository: AuthRepository(apiClient: Get.find()),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => HomeControllerImp(
        homeRepository: HomeRepository(apiClient: Get.find()),
        authRepository: AuthRepository(apiClient: Get.find()),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => CategoresControllerImp(
        categoriesRepository: CategoriesRepository(apiClient: Get.find()),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => AccountControllerImp(
        authRepository: AuthRepository(apiClient: Get.find()),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => OrderController(repository: AuthRepository(apiClient: Get.find())),
      fenix: true,
    );
    Get.lazyPut(
      () => ProductControllerImp(
        categoriesRepository: CategoriesRepository(apiClient: Get.find()),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => ReviewController(
        repository: ReviewRepository(apiClient: Get.find()),
        isAuthenticated: () => Get.find<HomeControllerImp>().isAuthenticated,
        accountRoles: () => Get.find<ShopController>().userModel?.accountRoles,
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => NotificationController(
        repository: HomeRepository(apiClient: Get.find()),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => StoreSupportController(
        repository: StoreSupportRepository(apiClient: Get.find()),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () =>
          ShopController(shopRepository: ShopRepository(apiClient: Get.find())),
      fenix: true,
    );
  }
}
