import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/widget/store_states.dart';

enum StoreUnavailableKind { offline, maintenance }

class StoreUnavailableScreen extends StatelessWidget {
  const StoreUnavailableScreen({
    required this.kind,
    this.authoritativeMessage,
    this.supportContact,
    this.onRetry,
    this.onSupport,
    super.key,
  });

  final StoreUnavailableKind kind;
  final String? authoritativeMessage;
  final String? supportContact;
  final VoidCallback? onRetry;
  final VoidCallback? onSupport;

  factory StoreUnavailableScreen.fromArguments(dynamic arguments) {
    final values = arguments is Map ? arguments : const <Object?, Object?>{};
    final kind =
        values['kind'] == 'maintenance'
            ? StoreUnavailableKind.maintenance
            : StoreUnavailableKind.offline;
    final message = values['message']?.toString().trim();
    final support = values['support']?.toString().trim();
    final normalizedSupport = support?.replaceAll(RegExp(r'[^0-9+]'), '');
    final supportUri =
        normalizedSupport != null && normalizedSupport.length >= 7
            ? Uri.parse(
              'https://wa.me/${normalizedSupport.replaceAll('+', '')}',
            )
            : null;
    return StoreUnavailableScreen(
      kind: kind,
      authoritativeMessage: message == null || message.isEmpty ? null : message,
      supportContact: supportUri?.toString(),
      onRetry: () => Get.offAllNamed(RouteHelper.initial),
      onSupport:
          supportUri == null
              ? null
              : () =>
                  launchUrl(supportUri, mode: LaunchMode.externalApplication),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offline = kind == StoreUnavailableKind.offline;
    return Scaffold(
      backgroundColor: StorePalette.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: StoreCalibration.authContentMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(StoreSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StoreMessageState(
                    kind:
                        offline
                            ? StoreMessageKind.offline
                            : StoreMessageKind.error,
                    title:
                        offline
                            ? 'storeOfflineTitle'.tr
                            : 'storeMaintenanceTitle'.tr,
                    message:
                        authoritativeMessage ??
                        (offline
                            ? 'storeOfflineMessage'.tr
                            : 'storeMaintenanceMessage'.tr),
                    actionLabel: onRetry == null ? null : 'storeRetry'.tr,
                    onAction: onRetry,
                  ),
                  if (!offline && onSupport != null) ...[
                    const SizedBox(height: StoreSpacing.xs),
                    TextButton.icon(
                      onPressed: onSupport,
                      icon: const Icon(Icons.support_agent_outlined),
                      label: Text('storeContactSupport'.tr),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
