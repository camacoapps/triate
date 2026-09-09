// lib/widgets/custom_button2.dart - MODIFICADO
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';

class CustomButton2 extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color frontColor;
  final Color backColor;
  final Color textColor;
  final Color? selectedFrontColor;
  final Color? selectedBackColor;
  final Color? selectedTextColor;
  final double? height;
  final double? fontSize;
  final TextAlign textAlign;
  final bool wrapText;
  final EdgeInsetsGeometry? padding;
  final int? maxLines;
  final double? width;

  const CustomButton2({
    super.key,
    required this.text,
    required this.onPressed,
    required this.frontColor,
    required this.backColor,
    required this.textColor,
    this.isSelected = false,
    this.selectedFrontColor,
    this.selectedBackColor,
    this.selectedTextColor,
    this.height,
    this.fontSize,
    this.textAlign = TextAlign.center,
    this.wrapText = true,
    this.padding,
    this.maxLines = 2,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    const double defaultHeight = 62;
    const double radius = 14;
    const double pressedOffset = 6;

    final topOffset = isSelected ? pressedOffset : 0.0;
    final actualFrontColor = isSelected
        ? (selectedFrontColor ?? colorGreen)
        : frontColor;
    final actualBackColor = isSelected
        ? (selectedBackColor ?? colorGreenDark)
        : backColor;
    final actualTextColor = isSelected
        ? (selectedTextColor ?? Colors.white)
        : textColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: text,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onPressed();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox(
            height: height ?? defaultHeight,
            width: width,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: actualBackColor,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 150),
                  top: topOffset,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: actualFrontColor,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    padding:
                        padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                    child: Text(
                      text,
                      textAlign: textAlign,
                      maxLines: wrapText ? maxLines : 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: actualTextColor,
                        fontFamily: 'VarelaRound',
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize ?? 16,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
