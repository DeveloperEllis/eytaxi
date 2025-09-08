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
    // Get current language to determine which flag to show
    final currentLocale = context.locale;
    String flagEmoji;
    
    switch (currentLocale.languageCode) {
      case 'es':
        flagEmoji = '🇪🇸';
        break;
      case 'en':
        flagEmoji = '🇺🇸';
        break;
      case 'fr':
        flagEmoji = '🇫🇷';
        break;
      case 'ru':
        flagEmoji = '🇷🇺';
        break;
      case 'it':
        flagEmoji = '🇮🇹';
        break;
      default:
        flagEmoji = '🇪🇸'; // Default to Spanish
    }

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    flagEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
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
