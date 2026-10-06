import 'package:get/get.dart';

String? upgradeRequiredMessage(Response response) {
  if (response.statusCode != 426) return null;
  return 'storeUpgradeRequiredRecovery';
}

String? missingResetProofMessage(String? resetProof) {
  if (resetProof != null && resetProof.isNotEmpty) return null;
  return 'storeResetProofMissing';
}
