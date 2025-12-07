import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;

  const AppHeader({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title ?? '관상은 과학'),
      automaticallyImplyLeading: showBackButton,
      actions: actions
    );
  }
}