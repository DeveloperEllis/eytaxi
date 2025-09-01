import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final void Function(Offset globalPosition)? onLanguageMenuRequested;
  final VoidCallback? onToggleTheme;

  const HomeAppBar({
    super.key,
    required this.title,
    this.onLanguageMenuRequested,
    this.onToggleTheme,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      title: Text(title),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      automaticallyImplyLeading: false,
      actions: [
        GestureDetector(
          onTapDown: (details) =>
              onLanguageMenuRequested?.call(details.globalPosition),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.language),
          ),
        ),
        IconButton(
          onPressed: onToggleTheme,
          icon: const Icon(Icons.brightness_6),
          tooltip: tr('Cambiar tema'),
        ),
      ],
    );
  }
}