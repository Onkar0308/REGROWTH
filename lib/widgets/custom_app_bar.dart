// lib/widgets/custom_user_app_bar.dart

import 'package:flutter/material.dart';
import 'package:regrowth_mobile/utils/contants.dart';

class CustomUserAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomUserAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: AppColors.accent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.04,
            ),
            Image.asset(
              'assets/images/app_bar_logo.PNG',
              width: MediaQuery.of(context).size.width * 0.40,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.16,
            ),
          ],
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
