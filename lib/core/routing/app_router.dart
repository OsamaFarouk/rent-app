import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/equipment/domain/equipment_model.dart';
import '../../features/equipment/presentation/pages/add_equipment_page.dart';
import '../../features/equipment/presentation/pages/equipment_detail_page.dart';
import '../../features/equipment/presentation/pages/equipment_page.dart';
import '../../features/equipment/presentation/pages/my_equipment_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/professionals/presentation/pages/my_professional_profile_page.dart';
import '../../features/professionals/presentation/pages/professional_detail_page.dart';
import '../../features/professionals/presentation/pages/professionals_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/my_business_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_setup_page.dart';
import '../../features/profile/presentation/pages/rental_house_detail_page.dart';
import '../../features/profile/presentation/pages/rental_houses_page.dart';
import '../../features/search/presentation/pages/search_results_page.dart';
import '../../shared/widgets/app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Central GoRouter navigation configuration.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/search',
      builder: (BuildContext context, GoRouterState state) => SearchResultsPage(
        initialQuery: state.uri.queryParameters['q'] ?? '',
      ),
    ),
    // Standalone Authentication & Profile Routes
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (BuildContext context, GoRouterState state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (BuildContext context, GoRouterState state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (BuildContext context, GoRouterState state) => const ProfileSetupPage(),
    ),
    GoRoute(
      path: '/my-professional-profile',
      builder: (BuildContext context, GoRouterState state) => const MyProfessionalProfilePage(),
    ),
    GoRoute(
      path: '/my-business-profile',
      builder: (BuildContext context, GoRouterState state) => const MyBusinessProfilePage(),
    ),
    GoRoute(
      path: '/rental-houses/:id',
      builder: (BuildContext context, GoRouterState state) => RentalHouseDetailPage(
        businessProfileId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/professionals/:id',
      builder: (BuildContext context, GoRouterState state) => ProfessionalDetailPage(
        professionalId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/add-equipment',
      builder: (BuildContext context, GoRouterState state) => const AddEquipmentPage(),
    ),
    GoRoute(
      path: '/edit-equipment/:id',
      builder: (BuildContext context, GoRouterState state) => AddEquipmentPage(
        equipmentToEdit: state.extra as EquipmentModel?,
        equipmentId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/equipment/:id',
      builder: (BuildContext context, GoRouterState state) => EquipmentDetailPage(
        equipmentId: state.pathParameters['id']!,
      ),
    ),

    // Persistent Bottom Navigation Shell Routes
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) =>
                  const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/equipment',
              builder: (BuildContext context, GoRouterState state) =>
                  EquipmentPage(
                initialCategory: state.uri.queryParameters['category'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/professionals',
              builder: (BuildContext context, GoRouterState state) =>
                  ProfessionalsPage(
                initialCategory: state.uri.queryParameters['category'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/rental-houses',
              builder: (BuildContext context, GoRouterState state) =>
                  const RentalHousesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) =>
                  const ProfilePage(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'my-equipment',
                  builder: (BuildContext context, GoRouterState state) =>
                      const MyEquipmentPage(),
                ),
              ],
            ),
            GoRoute(
              path: '/my-equipment',
              builder: (BuildContext context, GoRouterState state) =>
                  const MyEquipmentPage(),
            ),
            GoRoute(
              path: '/favorites',
              builder: (BuildContext context, GoRouterState state) =>
                  const FavoritesPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
