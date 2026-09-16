import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/features/auth/presentation/pages/login_page.dart';
import 'package:rent_app/features/auth/presentation/pages/register_page.dart';
import 'package:rent_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:rent_app/l10n/app_localizations.dart';

class MockAuthNotifier extends StateNotifier<AuthStateData> implements AuthNotifier {
  MockAuthNotifier() : super(const AuthStateData());

  @override
  void clearMessages() {
    state = state.copyWith(errorMessage: null, infoMessage: null);
  }

  @override
  Future<bool> signIn({required String email, required String password}) async {
    return false;
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String accountType = 'user',
  }) async {
    return false;
  }

  @override
  Future<bool> resetPassword({required String email}) async {
    return false;
  }

  @override
  Future<void> signOut() async {}
}

Widget createTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith((ref) => MockAuthNotifier()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  group('LoginPage Widget & Form Tests', () {
    testWidgets('LoginPage renders email and password fields and submit button', (tester) async {
      await tester.pumpWidget(createTestApp(const LoginPage()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('LoginPage shows email validation error on empty submit', (tester) async {
      await tester.pumpWidget(createTestApp(const LoginPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });
  });

  group('RegisterPage Widget & Form Tests', () {
    testWidgets('RegisterPage renders name, email, password and confirm password fields', (tester) async {
      await tester.pumpWidget(createTestApp(const RegisterPage()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('RegisterPage shows full name validation error on empty submit', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const RegisterPage()));
      await tester.pumpAndSettle();

      final button = find.byType(ElevatedButton);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name.'), findsOneWidget);
    });

    testWidgets('RegisterPage shows password mismatch validation when passwords differ', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const RegisterPage()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Ahmed Nabil');
      await tester.enterText(fields.at(1), 'ahmed@example.com');
      await tester.enterText(fields.at(2), '123456');
      await tester.enterText(fields.at(3), '654321');

      final button = find.byType(ElevatedButton);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });
  });
}
