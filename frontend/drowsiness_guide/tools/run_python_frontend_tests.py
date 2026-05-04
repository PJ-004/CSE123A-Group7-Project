#!/usr/bin/env python3
"""Run Python-based frontend source tests without requiring Flutter."""

from __future__ import annotations

import pathlib
import subprocess
import sys


PROJECT_ROOT = pathlib.Path(__file__).resolve().parents[1]


def main() -> int:
    command = [
        sys.executable,
        "-m",
        "unittest",
        "discover",
        "-s",
        "python_tests",
        "-p",
        "test_*.py",
        "-v",
    ]
    return subprocess.call(command, cwd=PROJECT_ROOT)


if __name__ == "__main__":
    raise SystemExit(main())
