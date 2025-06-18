import 'package:flutter/material.dart';

class KeyboardManager extends StatelessWidget {
  final Widget child;
  final bool dismissOnTapOutside;

  const KeyboardManager({
    super.key,
    required this.child,
    this.dismissOnTapOutside = true,
  });

  static void dismiss(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (!dismissOnTapOutside) return child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => KeyboardManager.dismiss(context),
      child: child,
    );
  }
}