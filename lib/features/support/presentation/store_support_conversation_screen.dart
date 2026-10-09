import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/store_tokens.dart';
import '../data/store_support_models.dart';
import '../data/store_support_realtime_service.dart';
import 'store_support_controller.dart';

class StoreSupportConversationScreen extends StatefulWidget {
  const StoreSupportConversationScreen({super.key});

  @override
  State<StoreSupportConversationScreen> createState() =>
      _StoreSupportConversationScreenState();
}

class _StoreSupportConversationScreenState
    extends State<StoreSupportConversationScreen> {
  late final StoreSupportController controller = Get.find();
  final input = TextEditingController();
  final scroll = ScrollController();
  String? imagePath;

  @override
  void initState() {
    super.initState();
    final id = int.tryParse('${Get.arguments}');
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.openConversation(id),
      );
    }
  }

  @override
  void dispose() {
    controller.stopTyping();
    input.dispose();
    scroll.dispose();
    controller.realtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GetBuilder<StoreSupportController>(
    builder: (state) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      final conversation = state.activeConversation;
      return Scaffold(
        backgroundColor: StorePalette.background,
        appBar: AppBar(
          title: Text(conversation?.subject ?? 'محادثة الدعم'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(24),
            child: _ConnectionLabel(state: state.connectionState),
          ),
        ),
        body:
            state.loadingConversation && conversation == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    if (conversation?.product != null)
                      _ProductContextCard(product: conversation!.product!),
                    Expanded(
                      child:
                          state.error != null && state.messages.isEmpty
                              ? Center(child: Text(state.error!))
                              : ListView.builder(
                                controller: scroll,
                                padding: const EdgeInsets.all(12),
                                itemCount: state.messages.length,
                                itemBuilder:
                                    (_, index) => _MessageBubble(
                                      message: state.messages[index],
                                      onRetry:
                                          () => state.retry(
                                            state.messages[index],
                                          ),
                                    ),
                              ),
                    ),
                    if (conversation?.isClosed == true)
                      const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text('تم إغلاق هذه المحادثة'),
                      )
                    else
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.supportIsTyping)
                            const _TypingLabel(text: 'الدعم يكتب الآن...'),
                          _Composer(
                            controller: input,
                            hasImage: imagePath != null,
                            onChanged: state.composerChanged,
                            onImage: () async {
                              final image = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 82,
                                maxWidth: 1800,
                              );
                              if (image != null) {
                                setState(() => imagePath = image.path);
                              }
                            },
                            onSend: () {
                              final text = input.text;
                              if (text.trim().isEmpty && imagePath == null) {
                                return;
                              }
                              state.send(text, imagePath: imagePath);
                              state.stopTyping();
                              input.clear();
                              setState(() => imagePath = null);
                            },
                          ),
                        ],
                      ),
                  ],
                ),
      );
    },
  );

  void _scrollToEnd() {
    if (!scroll.hasClients) return;
    scroll.animateTo(
      scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }
}

class _ConnectionLabel extends StatelessWidget {
  const _ConnectionLabel({required this.state});
  final StoreSupportConnectionState state;

  @override
  Widget build(BuildContext context) {
    final connected = state == StoreSupportConnectionState.connected;
    return Container(
      height: 24,
      alignment: Alignment.center,
      color:
          connected
              ? StorePalette.success.withValues(alpha: .08)
              : Colors.orange.withValues(alpha: .08),
      child: Text(
        connected ? 'متصل مباشرة' : 'جاري الاتصال · التحديث مستمر',
        style: TextStyle(
          fontSize: 11,
          color: connected ? StorePalette.success : Colors.orange.shade800,
        ),
      ),
    );
  }
}

class _ProductContextCard extends StatelessWidget {
  const _ProductContextCard({required this.product});
  final StoreSupportProductContext product;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: StorePalette.border),
    ),
    child: Row(
      children: [
        if (product.imageUrl?.isNotEmpty == true)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          )
        else
          const SizedBox.square(
            dimension: 48,
            child: Icon(Icons.two_wheeler_outlined),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('المحادثة حول المنتج', style: TextStyle(fontSize: 11)),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onRetry});
  final StoreSupportMessage message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Align(
    alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 310),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: message.isMine ? StorePalette.purple : StorePalette.surface,
        borderRadius: BorderRadius.circular(15),
        border: message.isMine ? null : Border.all(color: StorePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final attachment in message.attachments)
            if (attachment.type == 'image' && attachment.url.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(imageUrl: attachment.url),
                ),
              ),
          if (message.localImagePath != null && message.attachments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, size: 18),
                  SizedBox(width: 5),
                  Text('صورة مرفقة'),
                ],
              ),
            ),
          if (message.body.isNotEmpty)
            Text(
              message.body,
              style: TextStyle(
                color: message.isMine ? Colors.white : StorePalette.textPrimary,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            message.createdAt == null
                ? '--/--/---- --:--'
                : DateFormat(
                  'yyyy/MM/dd • HH:mm',
                ).format(message.createdAt!.toLocal()),
            style: TextStyle(
              fontSize: 10,
              color: message.isMine ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          if (message.delivery == StoreSupportDelivery.sending)
            Text(
              'جاري الإرسال...',
              style: TextStyle(
                fontSize: 10,
                color: message.isMine ? Colors.white70 : Colors.grey,
              ),
            )
          else if (message.delivery == StoreSupportDelivery.failed)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 15),
              label: const Text('تعذر الإرسال · إعادة المحاولة'),
            ),
        ],
      ),
    ),
  );
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.hasImage,
    required this.onChanged,
    required this.onImage,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool hasImage;
  final ValueChanged<String> onChanged;
  final VoidCallback onImage;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: const BoxDecoration(
        color: StorePalette.surface,
        border: Border(top: BorderSide(color: StorePalette.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onImage,
            icon: Icon(
              hasImage ? Icons.image : Icons.image_outlined,
              color: StorePalette.purple,
            ),
          ),
          Expanded(
            child: TextField(
              key: const Key('support-composer'),
              controller: controller,
              onChanged: onChanged,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hasImage ? 'أضف وصفاً للصورة...' : 'اكتب رسالة...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton.filled(
            key: const Key('support-send'),
            onPressed: onSend,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    ),
  );
}

class _TypingLabel extends StatelessWidget {
  const _TypingLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: StorePalette.surface,
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
    child: Text(
      text,
      style: const TextStyle(
        color: StorePalette.purple,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
