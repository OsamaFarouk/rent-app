import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/account_guard_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Application shell providing persistent bottom navigation and layout container.
class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AccountGuardState>(accountGuardProvider, (prev, next) {
      if (next.notificationMessage != null) {
        final messageKey = next.notificationMessage!;
        String text = messageKey;
        if (messageKey == 'accountDeletedMessage') text = l10n.accountDeletedMessage;
        if (messageKey == 'accountSuspendedMessage') text = l10n.accountSuspendedMessage;
        if (messageKey == 'accountVerificationFailedMessage') text = l10n.accountVerificationFailedMessage;
        if (messageKey == 'sessionExpiredMessage') text = l10n.sessionExpiredMessage;
        if (messageKey == 'offlineMessage') text = l10n.offlineMessage;

        // Clear any existing snackbars first so the notification appears EXACTLY ONCE
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(text),
            backgroundColor: (next.status == AccountGuardStatus.suspended ||
                    next.status == AccountGuardStatus.deleted)
                ? AppColors.error
                : AppColors.surfaceElevated,
            duration: const Duration(milliseconds: 4500),
          ),
        );
        ref.read(accountGuardProvider.notifier).clearNotificationMessage();
      }

      if (next.status == AccountGuardStatus.needsOnboarding) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/profile-setup');
          }
        });
      } else if (next.status == AccountGuardStatus.suspended ||
          next.status == AccountGuardStatus.deleted ||
          next.status == AccountGuardStatus.missingProfile) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/');
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.accentGold,
            unselectedItemColor: AppColors.unselectedNav,
            selectedFontSize: 11.0,
            unselectedFontSize: 11.0,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home_rounded),
                label: l10n.navHome,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.camera_alt_outlined),
                activeIcon: const Icon(Icons.camera_alt_rounded),
                label: l10n.navEquipment,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline_rounded),
                activeIcon: const Icon(Icons.people_rounded),
                label: l10n.navProfessionals,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.storefront_outlined),
                activeIcon: const Icon(Icons.storefront_rounded),
                label: l10n.navRentalHouses,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                activeIcon: const Icon(Icons.person_rounded),
                label: l10n.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
