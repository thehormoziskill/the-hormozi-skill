#!/usr/bin/env python3
"""Minimal runtime preflight for the-hormozi-skill."""

from __future__ import annotations

import os
import sys


def main() -> int:
    hosted_api = os.environ.get("THS_API_BASE_URL", "").strip()
    supabase_url = os.environ.get("SUPABASE_URL", "").strip()

    if hosted_api:
        print("OK: hosted API configured")
        return 0

    if supabase_url:
        print("OK: self-host mode detected")
        return 0

    print("WARN: no hosted API or self-host Supabase values found")
    print("Expected one of:")
    print("- THS_API_BASE_URL (managed mode)")
    print("- SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY (self-host mode)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
