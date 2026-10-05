import 'package:flutter/material.dart';

import '../theme/store_tokens.dart';
import '../theme/store_typography.dart';

enum StoreFieldStatus { neutral, error, success }

class StoreTextField extends StatefulWidget {
  const StoreTextField({
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.successText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.semanticLabel,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? successText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final int maxLines;
  final String? semanticLabel;

  @override
  State<StoreTextField> createState() => _StoreTextFieldState();
}

class _StoreTextFieldState extends State<StoreTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final isError = widget.errorText != null;
    final isSuccess = !isError && widget.successText != null;
    final statusColor =
        isError
            ? StorePalette.error
            : isSuccess
            ? StorePalette.success
            : StorePalette.border;
    final statusText =
        widget.errorText ?? widget.successText ?? widget.helperText;

    final field = TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: _obscured,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textDirection: widget.textDirection,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: StoreTypography.body,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon:
            widget.obscureText
                ? IconButton(
                  tooltip:
                      _obscured ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
                  onPressed: () => setState(() => _obscured = !_obscured),
                  icon: Icon(
                    _obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                )
                : widget.suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StoreRadii.md),
          borderSide: BorderSide(color: statusColor),
        ),
      ),
    );

    return Semantics(
      textField: true,
      label: widget.semanticLabel ?? widget.label ?? widget.hint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: StoreCalibration.controlHeight, child: field),
          if (statusText != null) ...[
            const SizedBox(height: StoreSpacing.xxs),
            Text(
              statusText,
              style: StoreTypography.caption.copyWith(
                color:
                    isError
                        ? StorePalette.error
                        : isSuccess
                        ? StorePalette.success
                        : StorePalette.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StoreSelectField<T> extends StatelessWidget {
  const StoreSelectField({
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                overflow: TextOverflow.ellipsis,
                style: StoreTypography.body,
              ),
            ),
          )
          .toList(growable: false),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
      ),
    );
  }
}
