import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';


class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.hasError = false,
  });


  final int length;


  final ValueChanged<String>? onCompleted;


  final ValueChanged<String>? onChanged;


  final bool hasError;

  @override
  State<OtpInput> createState() => OtpInputState();
}


class OtpInputState extends State<OtpInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _value = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  void clear() {
    _controller.clear();
    setState(() => _value = '');
  }


  void fill(String code) {
    final clamped = code.length > widget.length
        ? code.substring(0, widget.length)
        : code;
    _controller.text = clamped;
  }


  void focusFirst() {
    _focusNode.requestFocus();
  }


  String get value => _value;


  void _onTextChanged() {
    final text = _controller.text;
    if (text == _value) return;

    setState(() => _value = text);
    widget.onChanged?.call(text);

    if (text.length == widget.length) {
      _focusNode.unfocus();
      widget.onCompleted?.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [

          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                autofocus: false,
                enableSuggestions: false,
                autocorrect: false,
                showCursor: false,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
              ),
            ),
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              return _buildBox(index);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(int index) {
    final isFilled = index < _value.length;
    final isActive = index == _value.length && _focusNode.hasFocus;
    final digit = isFilled ? _value[index] : '';


    Color borderColor;
    double borderWidth;

    if (widget.hasError) {
      borderColor = AppColors.error;
      borderWidth = 1.5;
    } else if (isActive) {
      borderColor = AppColors.cyan;
      borderWidth = 2;
    } else if (isFilled) {
      borderColor = AppColors.cyan.withValues(alpha: 0.3);
      borderWidth = 1;
    } else {
      borderColor = AppColors.border;
      borderWidth = 1;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 56,
      margin: EdgeInsets.only(
        right: index < widget.length - 1 ? AppSpacing.sm : 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: Text(
          digit,
          key: ValueKey('$index-$digit'),
          style: AppTypography.h2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
