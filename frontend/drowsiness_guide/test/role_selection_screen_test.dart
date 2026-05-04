import 'package:drowsiness_guide/screens/role_selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

Widget _buildApp(Widget screen) {
  return MaterialApp(
    home: screen,
    routes: {
      '/dashboard': (_) => const Scaffold(body: Text('Dashboard')),
      '/fleet-dashboard': (_) =>
          const Scaffold(body: Text('Fleet Dashboard')),
      '/login': (_) => const Scaffold(body: Text('Login')),
    },
  );
}

void main() {
  late MockAuthService mockAuth;
  late MockUserRoleService mockRoleService;

  setUp(() {
    mockAuth = MockAuthService();
    mockRoleService = MockUserRoleService();
  });

  Widget buildScreen({
    String? email = 'newuser@example.com',
    String? password = 'password123',
    User? currentUser,
  }) {
    return _buildApp(
      RoleSelectionScreen(
        email: email,
        password: password,
        authService: mockAuth,
        userRoleService: mockRoleService,
        currentUserResolver: () => currentUser,
      ),
    );
  }

  group('RoleSelectionScreen - initial UI', () {
    testWidgets('renders both role options and back button', (tester) async {
      await tester.pumpWidget(buildScreen(currentUser: null));

      expect(find.text('Choose your role'), findsOneWidget);
      expect(find.text('Fleet Driver'), findsOneWidget);
      expect(find.text('Fleet Operator'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text("Select how you'll use the platform"), findsOneWidget);
    });

    testWidgets('shows setup subtitle when an authenticated user exists',
        (tester) async {
      await tester.pumpWidget(buildScreen(currentUser: FakeUser()));

      expect(find.text('Finish setting up your account'), findsOneWidget);
    });
  });

  group('RoleSelectionScreen - role routing', () {
    testWidgets('driver selection creates account, saves role, and routes',
        (tester) async {
      when(
        mockAuth.createUserWithEmailPassword(
          email: 'newuser@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => FakeUserCredential());

      await tester.pumpWidget(buildScreen(currentUser: null));
      await tester.tap(find.text('Fleet Driver'));
      await tester.pump();
      await tester.pump();

      verify(
        mockAuth.createUserWithEmailPassword(
          email: 'newuser@example.com',
          password: 'password123',
        ),
      ).called(1);
      verify(
        mockRoleService.saveRole(uid: 'test-uid-123', role: 'driver'),
      ).called(1);
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('operator selection with existing user saves role and routes',
        (tester) async {
      await tester.pumpWidget(buildScreen(currentUser: FakeUser()));
      await tester.tap(find.text('Fleet Operator'));
      await tester.pump();
      await tester.pump();

      verifyNever(
        mockAuth.createUserWithEmailPassword(
          email: 'newuser@example.com',
          password: 'password123',
        ),
      );
      verify(
        mockRoleService.saveRole(uid: 'test-uid-123', role: 'operator'),
      ).called(1);
      expect(find.text('Fleet Dashboard'), findsOneWidget);
    });
  });

  group('RoleSelectionScreen - validation and navigation', () {
    testWidgets('missing credentials show a friendly error for new user',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(email: null, password: null, currentUser: null),
      );
      await tester.tap(find.text('Fleet Driver'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Could not create account: Missing account credentials'),
          findsOneWidget);
    });

    testWidgets('back signs out existing user and returns to login',
        (tester) async {
      await tester.pumpWidget(buildScreen(currentUser: FakeUser()));
      await tester.tap(find.text('Back'));
      await tester.pump();
      await tester.pump();

      verify(mockAuth.signOut()).called(1);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('back does not sign out when there is no authenticated user',
        (tester) async {
      await tester.pumpWidget(buildScreen(currentUser: null));
      await tester.tap(find.text('Back'));
      await tester.pump();
      await tester.pump();

      verifyNever(mockAuth.signOut());
    });
  });
}
