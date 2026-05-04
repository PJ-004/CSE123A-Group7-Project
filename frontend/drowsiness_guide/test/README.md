How to run the frontend widget tests.

Go to `CSE123A-Group7-Project\frontend\drowsiness_guide`, then use Flutter's test runner:

Run the full frontend test suite:
`flutter test`

Run only the login screen tests:
`flutter test test/login_screen_test.dart`

Run only the role selection tests:
`flutter test test/role_selection_screen_test.dart`

Run only the live monitor tests:
`flutter test test/live_monitor_screen_test.dart`

Run only the map/navigation tests:
`flutter test test/osm_map_screen_test.dart`
`flutter test test/drowsiness_map_navigation_test.dart`

The helper script is still available for the live monitor file only:
`python tools/run_live_monitor_tests.py`

The new role-selection tests do not need any special command beyond `flutter test`.

Python-only frontend checks:

If Flutter is not installed, there is also a Python test that checks the frontend Dart source for expected login, role-selection, and app route wiring:

`py -3.11 tools/run_python_frontend_tests.py`

or

`py -3.11 -m unittest discover -s python_tests -p "test_*.py" -v`

These Python tests are source-level checks, not real Flutter widget tests.
