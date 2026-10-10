import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/model/online_store_home_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_media.dart';

enum StorePopupCampaignResult { action, dismiss }

Future<StorePopupCampaignResult> showStorePopupCampaignDialog(
  BuildContext context,
  OnlineStorePopupCampaign campaign,
) async {
  final result = await showDialog<StorePopupCampaignResult>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: .62),
    builder: (context) => _StorePopupCampaignDialog(campaign: campaign),
  );
  return result ?? StorePopupCampaignResult.dismiss;
}

class _StorePopupCampaignDialog extends StatelessWidget {
  const _StorePopupCampaignDialog({required this.campaign});

  final OnlineStorePopupCampaign campaign;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final colors = _theme(campaign.theme);
    final campaignTitle = campaign.title(language);
    final title =
        campaignTitle.isEmpty ? 'storePopupDefaultTitle'.tr : campaignTitle;
    final content = campaign.content(language);
    final campaignButton = campaign.button(language);
    final button =
        campaignButton.isEmpty ? 'storePopupDefaultAction'.tr : campaignButton;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: StorePalette.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 34,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      height: campaign.imagePath.isEmpty ? 92 : 210,
                      width: double.infinity,
                      color: colors.background,
                      child:
                          campaign.imagePath.isEmpty
                              ? Icon(
                                Icons.campaign_rounded,
                                size: 48,
                                color: colors.foreground,
                              )
                              : StoreNetworkMedia(
                                url: campaign.imagePath,
                                semanticLabel: title,
                                fit: BoxFit.cover,
                              ),
                    ),
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: Material(
                        color: Colors.black.withValues(alpha: .52),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'storePopupClose'.tr,
                          onPressed:
                              () => Navigator.pop(
                                context,
                                StorePopupCampaignResult.dismiss,
                              ),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 21, 22, 22),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 15,
                              color: colors.foreground,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'storePopupSelectedForYou'.tr,
                              style: StoreTypography.caption.copyWith(
                                color: colors.foreground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: StoreTypography.title.copyWith(
                          fontSize: 22,
                          height: 1.3,
                        ),
                      ),
                      if (content.isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Text(
                          content,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: StoreTypography.body.copyWith(
                            color: StorePalette.textSecondary,
                            height: 1.55,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.foreground,
                            foregroundColor: colors.onForeground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed:
                              () => Navigator.pop(
                                context,
                                StorePopupCampaignResult.action,
                              ),
                          icon: const Icon(Icons.arrow_back_rounded, size: 20),
                          label: Text(
                            button,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      TextButton(
                        onPressed:
                            () => Navigator.pop(
                              context,
                              StorePopupCampaignResult.dismiss,
                            ),
                        child: Text('storePopupDismiss'.tr),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _PopupTheme _theme(String value) => switch (value) {
    'success' => const _PopupTheme(
      Color(0xFFE6F7EF),
      Color(0xFF147A50),
      Colors.white,
    ),
    'warm' => const _PopupTheme(
      Color(0xFFFFF2DC),
      Color(0xFFB96710),
      Colors.white,
    ),
    'dark' => const _PopupTheme(
      Color(0xFFE9EAF0),
      Color(0xFF272A38),
      Colors.white,
    ),
    _ => const _PopupTheme(
      Color(0xFFF0EAFE),
      StorePalette.purple,
      Colors.white,
    ),
  };
}

class _PopupTheme {
  const _PopupTheme(this.background, this.foreground, this.onForeground);
  final Color background;
  final Color foreground;
  final Color onForeground;
}
