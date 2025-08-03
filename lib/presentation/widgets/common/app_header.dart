import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;

  const AppHeader({
    Key? key,
    this.title,
    this.actions,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title ?? 'Fortune'),
      automaticallyImplyLeading: showBackButton,
      actions: actions
    );
  }
}