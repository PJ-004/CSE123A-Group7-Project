#!/usr/bin/env python3
"""Run LiveMonitorScreen widget tests."""

from __future__ import annotations

import pathlib
import subprocess
import shutil


PROJECT_ROOT = pathlib.Path(__file__).resolve().parents[1]
TEST_PATH = 'test/live_monitor_screen_test.dart'


def resolve_flutter_cmd() -> str | None:
    flutter = shutil.which('flutter') or shutil.which('flutter.bat')
    return flutter


def main() -> int:
    flutter = resolve_flutter_cmd()
    if flutter:
        command = [flutter, 'test', TEST_PATH, '--reporter', 'expanded']
    else:
        # Fallback for Windows environments where flutter is available in
        # PowerShell profile but not directly discoverable by CreateProcess.
        command = [
            'powershell',
            '-Command',
            f'flutter test {TEST_PATH} --reporter expanded',
        ]
    return subprocess.call(command, cwd=PROJECT_ROOT)


if __name__ == '__main__':
    raise SystemExit(main())
