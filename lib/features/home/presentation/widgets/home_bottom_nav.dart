import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.local_taxi),
          label: 'taxi'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.landscape),
          label: 'excursiones'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.info_outline),
          label: 'informacion'.tr(),
        ),
      ],
    );
  }
}