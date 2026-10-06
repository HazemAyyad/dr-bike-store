import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/checkInternet.dart';
import '../../repository/auth/auth_repository.dart';

enum StartupDestination {
  onboarding,
  guestHome,
  authenticatedHome,
  offline,
  storeUnavailable,
  updateRequired,
  updateRecommended,
  error,
}

enum StartupSessionStatus { guest, valid, invalid, unchecked }

enum StartupUpdatePolicy { none, recommended, required }

class StartupSnapshot {
  const StartupSnapshot({
    required this.firstRunComplete,
    required this.isOnline,
    required this.sessionStatus,
    this.storeClosed = false,
    this.authoritativeMessage,
    this.supportContact,
    this.updatePolicy = StartupUpdatePolicy.none,
    this.recommendedUpdateSupported = false,
    this.updateUri,
    this.initializationFailed = false,
  });

  final bool firstRunComplete;
  final bool isOnline;
  final StartupSessionStatus sessionStatus;
  final bool storeClosed;
  final String? authoritativeMessage;
  final String? supportContact;
  final StartupUpdatePolicy updatePolicy;
  final bool recommendedUpdateSupported;
  final Uri? updateUri;
  final bool initializationFailed;
}

class StartupDecision {
  const StartupDecision({
    required this.destination,
    this.message,
    this.supportContact,
    this.updateUri,
    this.canRetry = false,
    this.canContinue = false,
    this.shouldClearInvalidSession = false,
  });

  final StartupDestination destination;
  final String? message;
  final String? supportContact;
  final Uri? updateUri;
  final bool canRetry;
  final bool canContinue;
  final bool shouldClearInvalidSession;
}

class StartupDecisionPolicy {
  const StartupDecisionPolicy();

  StartupDecision decide(StartupSnapshot snapshot) {
    final clearInvalid = snapshot.sessionStatus == StartupSessionStatus.invalid;

    if (snapshot.updatePolicy == StartupUpdatePolicy.required) {
      return StartupDecision(
        destination: StartupDestination.updateRequired,
        message: snapshot.authoritativeMessage,
        updateUri: snapshot.updateUri,
        canRetry: true,
        shouldClearInvalidSession: clearInvalid,
      );
    }

    if (snapshot.storeClosed) {
      return StartupDecision(
        destination: StartupDestination.storeUnavailable,
        message: snapshot.authoritativeMessage,
        supportContact: snapshot.supportContact,
        canRetry: true,
        shouldClearInvalidSession: clearInvalid,
      );
    }

    if (!snapshot.isOnline) {
      return StartupDecision(
        destination: StartupDestination.offline,
        canRetry: true,
        shouldClearInvalidSession: clearInvalid,
      );
    }

    if (snapshot.initializationFailed) {
      return StartupDecision(
        destination: StartupDestination.error,
        message: snapshot.authoritativeMessage,
        canRetry: true,
        shouldClearInvalidSession: clearInvalid,
      );
    }

    if (snapshot.updatePolicy == StartupUpdatePolicy.recommended &&
        snapshot.recommendedUpdateSupported) {
      return StartupDecision(
        destination: StartupDestination.updateRecommended,
        message: snapshot.authoritativeMessage,
        updateUri: snapshot.updateUri,
        canRetry: true,
        canContinue: true,
        shouldClearInvalidSession: clearInvalid,
      );
    }

    if (!snapshot.firstRunComplete) {
      return StartupDecision(
        destination: StartupDestination.onboarding,
        shouldClearInvalidSession: clearInvalid,
      );
    }

    return StartupDecision(
      destination:
          snapshot.sessionStatus == StartupSessionStatus.valid
              ? StartupDestination.authenticatedHome
              : StartupDestination.guestHome,
      shouldClearInvalidSession: clearInvalid,
    );
  }
}

abstract interface class StartupResolver {
  Future<StartupDecision> resolveStartup();
}

/// Resolves startup once per launch. It keeps remote policy and session checks
/// outside the splash presentation so every input can be tested deterministically.
class ApiService extends GetxService implements StartupResolver {
  ApiService({
    AuthRepository? authRepository,
    Future<bool> Function()? connectivityCheck,
    StartupDecisionPolicy decisionPolicy = const StartupDecisionPolicy(),
  }) : _providedRepository = authRepository,
       _connectivityCheck =
           connectivityCheck ??
           (() async => await CheckInternet.checkInternet() == true),
       _decisionPolicy = decisionPolicy;

  final AuthRepository? _providedRepository;
  final Future<bool> Function() _connectivityCheck;
  final StartupDecisionPolicy _decisionPolicy;
  Timer? _accountTimer;

  AuthRepository get _repository {
    final provided = _providedRepository;
    if (provided != null) return provided;
    if (Get.isRegistered<AuthRepository>()) return Get.find<AuthRepository>();
    return AuthRepository(apiClient: ApiClient(sharedPreferences: Get.find()));
  }

  @override
  Future<StartupDecision> resolveStartup() async {
    final firstRunComplete = await AppUsageService.getIsFirst() == true;
    final remembered = await AppUsageService.getIsLogin();
    final token = await AppUsageService.getToken();
    final userId = await AppUsageService.getUserId();
    final hasCompleteSession =
        remembered &&
        token != null &&
        token.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty;

    final online = await _connectivityCheck();
    if (!online) {
      return _decisionPolicy.decide(
        StartupSnapshot(
          firstRunComplete: firstRunComplete,
          isOnline: false,
          sessionStatus:
              hasCompleteSession
                  ? StartupSessionStatus.unchecked
                  : StartupSessionStatus.guest,
        ),
      );
    }

    final settings = await _repository.checkSettingAndConactUs();
    if (settings.statusCode == 1) {
      return _decisionPolicy.decide(
        StartupSnapshot(
          firstRunComplete: firstRunComplete,
          isOnline: false,
          sessionStatus:
              hasCompleteSession
                  ? StartupSessionStatus.unchecked
                  : StartupSessionStatus.guest,
        ),
      );
    }
    if (settings.statusCode == 426) {
      return _decisionPolicy.decide(
        StartupSnapshot(
          firstRunComplete: firstRunComplete,
          isOnline: true,
          sessionStatus: StartupSessionStatus.unchecked,
          updatePolicy: StartupUpdatePolicy.required,
          authoritativeMessage: _safeMessage(settings.body),
        ),
      );
    }
    if (settings.statusCode != 200) {
      return _failureDecision(firstRunComplete);
    }

    final settingsData = _settingsData(settings.body);
    if (settingsData == null) return _failureDecision(firstRunComplete);

    final isClosed = settingsData['isClose'] == true;
    final message = _safeText(settingsData['message']);
    final support = _safeText(settingsData['whatsApp']);
    if (isClosed) {
      return _decisionPolicy.decide(
        StartupSnapshot(
          firstRunComplete: firstRunComplete,
          isOnline: true,
          sessionStatus:
              hasCompleteSession
                  ? StartupSessionStatus.unchecked
                  : StartupSessionStatus.guest,
          storeClosed: true,
          authoritativeMessage: message,
          supportContact: support,
        ),
      );
    }

    var sessionStatus = StartupSessionStatus.guest;
    if (remembered && !hasCompleteSession) {
      sessionStatus = StartupSessionStatus.invalid;
    } else if (hasCompleteSession) {
      final account = await _repository.checkUser();
      if (account.statusCode == 1) {
        return _decisionPolicy.decide(
          StartupSnapshot(
            firstRunComplete: firstRunComplete,
            isOnline: false,
            sessionStatus: StartupSessionStatus.unchecked,
          ),
        );
      }
      if (account.statusCode == 426) {
        return _decisionPolicy.decide(
          StartupSnapshot(
            firstRunComplete: firstRunComplete,
            isOnline: true,
            sessionStatus: StartupSessionStatus.unchecked,
            updatePolicy: StartupUpdatePolicy.required,
            authoritativeMessage: _safeMessage(account.body),
          ),
        );
      }
      if (account.statusCode == 401 || account.statusCode == 403) {
        sessionStatus = StartupSessionStatus.invalid;
      } else if (account.statusCode != 200 || account.body is! Map) {
        return _failureDecision(firstRunComplete);
      } else {
        final body = Map<Object?, Object?>.from(account.body as Map);
        sessionStatus =
            body['isClose'] == true || body['block'] == true
                ? StartupSessionStatus.invalid
                : StartupSessionStatus.valid;
      }
    }

    final decision = _decisionPolicy.decide(
      StartupSnapshot(
        firstRunComplete: firstRunComplete,
        isOnline: true,
        sessionStatus: sessionStatus,
      ),
    );
    if (decision.shouldClearInvalidSession) {
      await _clearInvalidIdentity();
    }
    return decision;
  }

  StartupDecision _failureDecision(bool firstRunComplete) =>
      _decisionPolicy.decide(
        StartupSnapshot(
          firstRunComplete: firstRunComplete,
          isOnline: true,
          sessionStatus: StartupSessionStatus.unchecked,
          initializationFailed: true,
        ),
      );

  Map<Object?, Object?>? _settingsData(dynamic body) {
    if (body is! Map) return null;
    final data = body['data'];
    if (data is! Map || data['isClose'] is! bool) return null;
    return Map<Object?, Object?>.from(data);
  }

  String? _safeMessage(dynamic body) {
    if (body is! Map) return null;
    return _safeText(body['message']);
  }

  String? _safeText(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  Future<void> _clearInvalidIdentity() async {
    await AppUsageService.deleteIsLogin();
    await AppUsageService.deleteToken();
    await AppUsageService.deleteUserEmail();
    await AppUsageService.deleteUserId();
    await AppUsageService.deleteUserName();
    await AppUsageService.deleteTypeUser();
  }

  /// Retained for authenticated foreground checks, but deliberately bounded to
  /// a low-frequency interval instead of the previous 500 ms polling loop.
  void startAccountCheck() {
    _accountTimer?.cancel();
    _accountTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      if (!await AppUsageService.getIsLogin()) return;
      final response = await _repository.checkUser();
      if (response.statusCode == 401 || response.statusCode == 403) {
        await _clearInvalidIdentity();
      }
    });
  }

  Future<void> checkAccountStatus() async {
    if (!await AppUsageService.getIsLogin()) return;
    final response = await _repository.checkUser();
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _clearInvalidIdentity();
      return;
    }
    if (response.statusCode == 200 && response.body is Map) {
      final body = Map<Object?, Object?>.from(response.body as Map);
      if (body['isClose'] == true || body['block'] == true) {
        await _clearInvalidIdentity();
      }
    }
  }

  @override
  void onClose() {
    _accountTimer?.cancel();
    super.onClose();
  }
}

class ConnectivityController extends GetxController {
  final isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    Connectivity().onConnectivityChanged.listen((results) {
      isConnected.value = !results.contains(ConnectivityResult.none);
    });
  }

  Future<void> retryConnection() async {
    final results = await Connectivity().checkConnectivity();
    isConnected.value =
        !results.contains(ConnectivityResult.none) &&
        await CheckInternet.checkInternet();
  }
}
