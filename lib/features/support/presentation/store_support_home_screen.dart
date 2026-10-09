import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/helper/route_helper.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_states.dart';
import '../data/store_support_models.dart';
import 'store_support_controller.dart';

class StoreSupportHomeScreen extends StatefulWidget {
  const StoreSupportHomeScreen({super.key});

  @override
  State<StoreSupportHomeScreen> createState() => _StoreSupportHomeScreenState();
}

class _StoreSupportHomeScreenState extends State<StoreSupportHomeScreen> {
  late final StoreSupportController controller = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadInbox());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: StorePalette.background,
    appBar: AppBar(title: const Text('الدعم والمحادثات')),
    floatingActionButton: FloatingActionButton.extended(
      key: const Key('new-general-support'),
      backgroundColor: StorePalette.purple,
      foregroundColor: Colors.white,
      onPressed: () async {
        final created = await Get.toNamed(RouteHelper.supportNew);
        if (created == true) await controller.loadInbox();
      },
      icon: const Icon(Icons.add_comment_outlined),
      label: const Text('محادثة جديدة'),
    ),
    body: GetBuilder<StoreSupportController>(
      builder: (state) {
        if (state.loadingInbox && state.conversations.isEmpty) {
          return const StoreSkeletonList(itemCount: 5);
        }
        if (state.error != null && state.conversations.isEmpty) {
          return StoreMessageState(
            kind: StoreMessageKind.error,
            message: state.error!,
            actionLabel: 'إعادة المحاولة',
            onAction: state.loadInbox,
          );
        }
        if (state.conversations.isEmpty) {
          return const StoreMessageState(
            kind: StoreMessageKind.empty,
            message: 'لا توجد محادثات بعد\nابدأ محادثة وسيرد عليك فريق الدعم.',
          );
        }
        return RefreshIndicator(
          onRefresh: state.loadInbox,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: state.conversations.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder:
                (_, index) => _ConversationTile(
                  conversation: state.conversations[index],
                  onTap: () async {
                    await Get.toNamed(
                      RouteHelper.supportConversation,
                      arguments: state.conversations[index].id,
                    );
                    await state.loadInbox();
                  },
                ),
          ),
        );
      },
    ),
  );
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});
  final StoreSupportConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: StorePalette.surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: StorePalette.purple.withValues(alpha: .12),
              foregroundColor: StorePalette.purple,
              child: Icon(
                conversation.contextType == 'product'
                    ? Icons.two_wheeler_outlined
                    : Icons.support_agent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StoreTypography.title.copyWith(fontSize: 15),
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          DateFormat(
                            'dd/MM · HH:mm',
                          ).format(conversation.lastMessageAt!.toLocal()),
                          style: StoreTypography.caption.copyWith(fontSize: 10),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    conversation.lastMessage.isEmpty
                        ? 'ابدأ المحادثة'
                        : conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StoreTypography.body.copyWith(
                      color: StorePalette.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (conversation.unreadCount > 0) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 11,
                backgroundColor: StorePalette.purple,
                child: Text(
                  '${conversation.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
