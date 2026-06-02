import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_panel.dart';

class GlassTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final List<TextInputFormatter>? inputFormatters;

  const GlassTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.validator,
    this.autovalidateMode,
    this.inputFormatters,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final accent = hasError
        ? scheme.error
        : (_hasFocus ? scheme.primary : Colors.white.withOpacity(0.45));

    return GlassPanel(
      radius: 14,
      blur: 14,
      isFrostedGlass: true,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        minLines: widget.minLines,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction,
        autofocus: widget.autofocus,
        validator: widget.validator,
        autovalidateMode: widget.autovalidateMode,
        inputFormatters: widget.inputFormatters,
        style: TextStyle(color: scheme.onSurface, fontSize: 15),
        cursorColor: scheme.primary,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          labelText: widget.label,
          hintText: widget.hint,
          helperText: widget.helper,
          errorText: widget.errorText,
          labelStyle: TextStyle(color: scheme.onSurfaceVariant),
          floatingLabelStyle: TextStyle(
            color: hasError ? scheme.error : scheme.primary,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: scheme.onSurfaceVariant.withOpacity(0.6),
          ),
          helperStyle: TextStyle(color: scheme.onSurfaceVariant),
          errorStyle: TextStyle(color: scheme.error),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: accent,
                  size: 20,
                )
              : null,
          suffix: widget.suffix,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }
}
