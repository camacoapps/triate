// lib/widgets/custom_button.dart - TAMBIÉN CORREGIDO
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color frontColor;
  final Color backColor;
  final Color textColor;
  final double? height;
  final double? fontSize;
  final TextAlign textAlign;
  final bool wrapText;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final int? maxLines;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.frontColor,
    required this.backColor,
    required this.textColor,
    this.height,
    this.fontSize,
    this.textAlign = TextAlign.center,
    this.wrapText = true,
    this.padding,
    this.borderRadius,
    this.maxLines = 2,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double defaultHeight = 60;
    const double shadowHeight = 6;
    const double defaultRadius = 14;

    final double height = widget.height ?? defaultHeight;
    final double radius = widget.borderRadius is BorderRadius
        ? (widget.borderRadius as BorderRadius).topLeft.x
        : defaultRadius;

    final double topOffset = _isPressed ? shadowHeight : 0;

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.text,
      child: FocusableActionDetector(
        enabled: widget.onPressed != null,
        mouseCursor: widget.onPressed == null
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.onPressed == null
              ? null
              : (_) => setState(() => _isPressed = true),
          onTapUp: widget.onPressed == null
              ? null
              : (_) {
                  setState(() => _isPressed = false);
                  widget.onPressed?.call();
                },
          onTapCancel: () => setState(() => _isPressed = false),
          child: Opacity(
            opacity: widget.onPressed == null ? 0.5 : 1.0,
            child: SizedBox(
              width: double.infinity,
              height: height + shadowHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: shadowHeight,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: widget.backColor,
                        borderRadius:
                            widget.borderRadius ??
                            BorderRadius.circular(radius),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 90),
                    curve: Curves.easeInOut,
                    top: topOffset,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: height,
                      alignment: Alignment.center,
                      padding:
                          widget.padding ??
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                      decoration: BoxDecoration(
                        color: widget.frontColor,
                        borderRadius:
                            widget.borderRadius ??
                            BorderRadius.circular(radius),
                      ),
                      child: Text(
                        widget.text,
                        textAlign: widget.textAlign,
                        maxLines: widget.wrapText ? widget.maxLines : 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: widget.textColor,
                          fontFamily: 'VarelaRound',
                          fontWeight: FontWeight.bold,
                          fontSize: widget.fontSize ?? 20,
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
      ),
    );
  }
}
