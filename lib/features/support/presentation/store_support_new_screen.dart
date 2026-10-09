import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/helper/route_helper.dart';
import '../../../core/theme/store_tokens.dart';
import 'store_support_controller.dart';

class StoreSupportNewScreen extends StatefulWidget {
  const StoreSupportNewScreen({super.key});

  @override
  State<StoreSupportNewScreen> createState() => _StoreSupportNewScreenState();
}

class _StoreSupportNewScreenState extends State<StoreSupportNewScreen> {
  late final StoreSupportController controller = Get.find();
  late final int? listingId;
  late final String? productName;
  final message = TextEditingController();
  String? imagePath;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    listingId = args is Map ? int.tryParse('${args['listing_id']}') : null;
    productName = args is Map ? args['product_name']?.toString() : null;
    if (listingId != null) {
      message.text = 'مرحباً، أريد الاستفسار عن هذا المنتج.';
    }
  }

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: StorePalette.background,
    appBar: AppBar(
      title: Text(listingId == null ? 'محادثة دعم جديدة' : 'اسأل عن المنتج'),
    ),
    body: SafeArea(
      child: GetBuilder<StoreSupportController>(
        builder:
            (state) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (listingId != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.two_wheeler_outlined,
                        color: StorePalette.purple,
                      ),
                      title: const Text('الاستفسار مرتبط بهذا المنتج'),
                      subtitle: Text(productName ?? 'منتج المتجر'),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('support-message-field'),
                  controller: message,
                  minLines: 5,
                  maxLines: 9,
                  maxLength: 5000,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'كيف يمكننا مساعدتك؟',
                    hintText: 'اكتب تفاصيل سؤالك أو المشكلة...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 82,
                      maxWidth: 1800,
                    );
                    if (picked != null) setState(() => imagePath = picked.path);
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    imagePath == null ? 'إرفاق صورة' : 'تم اختيار صورة · تغيير',
                  ),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    state.error!,
                    style: const TextStyle(color: StorePalette.error),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  key: const Key('create-support-conversation'),
                  onPressed:
                      state.creating
                          ? null
                          : () async {
                            if (message.text.trim().isEmpty &&
                                imagePath == null) {
                              Get.snackbar('تنبيه', 'اكتب رسالة أو أرفق صورة');
                              return;
                            }
                            final conversation = await state.createConversation(
                              text: message.text,
                              listingId: listingId,
                              imagePath: imagePath,
                            );
                            if (conversation == null) return;
                            await Get.offNamed(
                              RouteHelper.supportConversation,
                              arguments: conversation.id,
                            );
                          },
                  icon:
                      state.creating
                          ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send_rounded),
                  label: const Text('بدء المحادثة'),
                ),
              ],
            ),
      ),
    ),
  );
}
