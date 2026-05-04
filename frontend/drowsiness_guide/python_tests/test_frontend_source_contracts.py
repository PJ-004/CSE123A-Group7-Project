import pathlib
import unittest


PROJECT_ROOT = pathlib.Path(__file__).resolve().parents[1]
LIB_ROOT = PROJECT_ROOT / "lib"


def read_lib_file(relative_path: str) -> str:
    return (LIB_ROOT / relative_path).read_text(encoding="utf-8")


class LoginScreenSourceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.source = read_lib_file("screens/login_screen.dart")

    def test_login_screen_contains_email_and_password_fields(self) -> None:
        self.assertIn("hint: 'email'", self.source)
        self.assertIn("hint: 'password'", self.source)

    def test_login_screen_contains_core_actions(self) -> None:
        self.assertIn("'Log in'", self.source)
        self.assertIn("'Create account'", self.source)
        self.assertIn("'Continue with Google'", self.source)

    def test_login_screen_contains_expected_auth_routes(self) -> None:
        self.assertIn("'/dashboard'", self.source)
        self.assertIn("'/fleet-dashboard'", self.source)
        self.assertIn("'/select-role'", self.source)

    def test_login_screen_contains_validation_messages(self) -> None:
        self.assertIn("Please enter both email and password", self.source)
        self.assertIn("Password must be at least 6 characters", self.source)


class RoleSelectionSourceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.source = read_lib_file("screens/role_selection_screen.dart")

    def test_role_selection_contains_both_roles(self) -> None:
        self.assertIn("'Fleet Driver'", self.source)
        self.assertIn("'Fleet Operator'", self.source)

    def test_role_selection_contains_setup_copy_and_back(self) -> None:
        self.assertIn("Select how you'll use the platform", self.source)
        self.assertIn("Finish setting up your account", self.source)
        self.assertIn("'Back'", self.source)

    def test_role_selection_routes_operator_and_driver(self) -> None:
        self.assertIn("role == 'operator' ? '/fleet-dashboard' : '/dashboard'", self.source)
        self.assertIn("await _userRoleService.saveRole(uid: user.uid, role: role);", self.source)


class AppRoutingSourceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.source = read_lib_file("app.dart")

    def test_app_defines_expected_named_routes(self) -> None:
        self.assertIn("'/dashboard': (context) => const LiveMonitorScreen()", self.source)
        self.assertIn("'/map': (context) => const OSMMapScreen()", self.source)
        self.assertIn("'/fleet-dashboard': (context) => const FleetOperatorDashboard()", self.source)
        self.assertIn("'/select-role': (context)", self.source)

    def test_app_defaults_to_login_when_signed_out(self) -> None:
        self.assertIn("return const LoginScreen();", self.source)

    def test_app_checks_role_for_signed_in_users(self) -> None:
        self.assertIn("future: UserRoleService().fetchRole(snapshot.data!.uid)", self.source)
        self.assertIn("if (roleSnapshot.data == 'operator')", self.source)
        self.assertIn("return const RoleSelectionScreen(email: null, password: null);", self.source)


if __name__ == "__main__":
    unittest.main()
