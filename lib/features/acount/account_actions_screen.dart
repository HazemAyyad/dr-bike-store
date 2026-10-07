import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/account/account_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../core/widget/store_states.dart';

class AccountActionsScreen extends StatelessWidget {
  const AccountActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AccountControllerImp>()) {
      return const Scaffold(
        body: StoreMessageState(
          kind: StoreMessageKind.error,
          message: 'تعذر تحميل إجراءات الحساب. أعد تشغيل التطبيق وحاول مجددًا.',
        ),
      );
    }
    return GetBuilder<AccountControllerImp>(
      builder:
          (c) => Scaffold(
            backgroundColor: StorePalette.background,
            appBar: AppBar(
              title: Text('إجراءات الحساب', style: StoreTypography.title),
              centerTitle: true,
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(StoreSpacing.md),
                children: [
                  _ActionCard(
                    icon: Icons.logout_rounded,
                    title: 'تسجيل الخروج',
                    subtitle: 'إنهاء الجلسة الحالية على هذا الجهاز.',
                    onTap: () async {
                      final confirmed = await _confirm(
                        context,
                        'تسجيل الخروج',
                        'هل تريد إنهاء الجلسة على هذا الجهاز؟',
                      );
                      if (!confirmed) return;
                      try {
                        await c.logout(confirmed: true);
                        Get.offAllNamed(RouteHelper.homePage);
                      } catch (_) {
                        showCustomSnackBar(
                          'تعذر تسجيل الخروج. حاول مجددًا.',
                          isError: true,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.person_off_outlined,
                    title: 'حذف/تعطيل الحساب',
                    subtitle: 'يتم تعطيل الحساب على الخادم قبل حذف الجلسة.',
                    danger: true,
                    loading:
                        c.mutationStatus == AccountMutationStatus.submitting,
                    onTap: () async {
                      final confirmed = await _confirm(
                        context,
                        'حذف/تعطيل الحساب',
                        'سيُرسل الطلب إلى الخادم أولًا، ولن تُحذف جلستك إذا فشل الطلب.',
                      );
                      if (!confirmed) return;
                      try {
                        if (await c.deactivateAccount(confirmed: true)) {
                          Get.offAllNamed(RouteHelper.homePage);
                        } else {
                          showCustomSnackBar(
                            'تعذر تعطيل الحساب. لم يتم حذف جلستك.',
                            isError: true,
                          );
                        }
                      } catch (_) {
                        showCustomSnackBar(
                          'تعذر تعطيل الحساب. لم يتم حذف جلستك.',
                          isError: true,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String body,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('تأكيد'),
                ),
              ],
            ),
      ) ??
      false;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  final bool loading;

  @override
  Widget build(BuildContext context) => Material(
    color: StorePalette.surface,
    borderRadius: BorderRadius.circular(StoreRadii.lg),
    child: InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(StoreRadii.lg),
          border: Border.all(
            color: danger ? StorePalette.error : StorePalette.border,
          ),
        ),
        child: Row(
          children: [
            if (loading)
              const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                icon,
                color: danger ? StorePalette.error : StorePalette.purple,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: StoreTypography.bodyMedium.copyWith(
                      color: danger ? StorePalette.error : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: StoreTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
