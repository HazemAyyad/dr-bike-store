import 'package:doctor_bike/controller/check_account/account_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = StartupDecisionPolicy();

  test('first run enters onboarding after successful initialization', () {
    final decision = policy.decide(
      const StartupSnapshot(
        firstRunComplete: false,
        isOnline: true,
        sessionStatus: StartupSessionStatus.guest,
      ),
    );

    expect(decision.destination, StartupDestination.onboarding);
    expect(decision.shouldClearInvalidSession, isFalse);
  });

  test('returning guest enters the existing guest home', () {
    final decision = policy.decide(
      const StartupSnapshot(
        firstRunComplete: true,
        isOnline: true,
        sessionStatus: StartupSessionStatus.guest,
      ),
    );

    expect(decision.destination, StartupDestination.guestHome);
  });

  test('valid retained session enters authenticated home', () {
    final decision = policy.decide(
      const StartupSnapshot(
        firstRunComplete: true,
        isOnline: true,
        sessionStatus: StartupSessionStatus.valid,
      ),
    );

    expect(decision.destination, StartupDestination.authenticatedHome);
  });

  test('invalid retained session becomes guest and clears identity only', () {
    final decision = policy.decide(
      const StartupSnapshot(
        firstRunComplete: true,
        isOnline: true,
        sessionStatus: StartupSessionStatus.invalid,
      ),
    );

    expect(decision.destination, StartupDestination.guestHome);
    expect(decision.shouldClearInvalidSession, isTrue);
  });

  test('offline initialization never falls through to catalog success', () {
    final decision = policy.decide(
      const StartupSnapshot(
        firstRunComplete: true,
        isOnline: false,
        sessionStatus: StartupSessionStatus.unchecked,
      ),
    );

    expect(decision.destination, StartupDestination.offline);
    expect(decision.canRetry, isTrue);
  });

  test('maintenance authority blocks the normal store', () {
    final decision = policy.decide(
      const StartupSnapshot(
        firstRunComplete: true,
        isOnline: true,
        sessionStatus: StartupSessionStatus.valid,
        storeClosed: true,
        authoritativeMessage: 'Scheduled maintenance',
      ),
    );

    expect(decision.destination, StartupDestination.storeUnavailable);
    expect(decision.message, 'Scheduled maintenance');
  });

  test('required update fails closed before every normal destination', () {
    final decision = policy.decide(
      const StartupSnapshot(
        firstRunComplete: true,
        isOnline: true,
        sessionStatus: StartupSessionStatus.valid,
        updatePolicy: StartupUpdatePolicy.required,
      ),
    );

    expect(decision.destination, StartupDestination.updateRequired);
    expect(decision.canContinue, isFalse);
  });

  test('recommended update exists only behind an explicit capability', () {
    final disabled = policy.decide(
      const StartupSnapshot(
        firstRunComplete: true,
        isOnline: true,
        sessionStatus: StartupSessionStatus.guest,
        updatePolicy: StartupUpdatePolicy.recommended,
      ),
    );
    final supported = policy.decide(
      const StartupSnapshot(
        firstRunComplete: true,
        isOnline: true,
        sessionStatus: StartupSessionStatus.guest,
        updatePolicy: StartupUpdatePolicy.recommended,
        recommendedUpdateSupported: true,
      ),
    );

    expect(disabled.destination, StartupDestination.guestHome);
    expect(supported.destination, StartupDestination.updateRecommended);
    expect(supported.canContinue, isTrue);
  });

  test('initialization failure is an honest retryable error', () {
    final decision = policy.decide(
      const StartupSnapshot(
        firstRunComplete: true,
        isOnline: true,
        sessionStatus: StartupSessionStatus.unchecked,
        initializationFailed: true,
      ),
    );

    expect(decision.destination, StartupDestination.error);
    expect(decision.canRetry, isTrue);
  });
}
