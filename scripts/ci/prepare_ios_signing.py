#!/usr/bin/env python3
"""Prepare manual-signing settings for CI from the installed iOS profile."""
from __future__ import annotations

import os
from pathlib import Path
import plistlib
import re
import shutil
import sys


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("Usage: prepare_ios_signing.py PROFILE.plist PROFILE.mobileprovision")

    with open(sys.argv[1], "rb") as fh:
        profile = plistlib.load(fh)
    team = profile["TeamIdentifier"][0]
    name = profile["Name"]
    uuid = profile["UUID"]
    app_identifier = profile.get("Entitlements", {}).get("application-identifier", "")
    expected_identifier = f"{team}.com.vertex.cortex"
    if app_identifier != expected_identifier:
        raise SystemExit(
            "ERROR: The Apple provisioning profile is not for com.vertex.cortex "
            f"(expected {expected_identifier}, received {app_identifier!r})."
        )
    if not re.fullmatch(r"[A-Z0-9]{10}", team):
        raise SystemExit("ERROR: Invalid Apple Team ID in provisioning profile")
    if not re.fullmatch(r"[A-Fa-f0-9-]{36}", uuid):
        raise SystemExit("ERROR: Invalid UUID in provisioning profile")
    if any(c in name for c in ['"', "\n", "\r", "\\"]):
        raise SystemExit("ERROR: Unexpected characters in provisioning profile name")

    destination = (
        Path.home() / "Library" / "MobileDevice" / "Provisioning Profiles" / f"{uuid}.mobileprovision"
    )
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(sys.argv[2], destination)

    # The committed Xcode project has a fixed team/profile name. Set the exact
    # values from the supplied signing profile in the runner's checkout only.
    project = Path("ios/Runner.xcodeproj/project.pbxproj")
    original = project.read_text(encoding="utf-8")
    edited, profile_matches = re.subn(
        r'("PROVISIONING_PROFILE_SPECIFIER\[sdk=iphoneos\*\]" = )"[^"]*";',
        lambda match: f'{match.group(1)}"{name}";',
        original,
    )
    edited, team_matches = re.subn(
        r'("DEVELOPMENT_TEAM\[sdk=iphoneos\*\]" = )[A-Za-z0-9]*;',
        lambda match: f"{match.group(1)}{team};",
        edited,
    )
    edited = edited.replace(
        '"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Distribution";',
        '"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Distribution";',
    )
    if profile_matches < 1 or team_matches < 1:
        raise SystemExit("ERROR: Expected manual signing settings not found in Xcode project")
    project.write_text(edited, encoding="utf-8")

    options = {
        "method": "app-store-connect",
        "signingStyle": "manual",
        "teamID": team,
        "destination": "export",
        "uploadSymbols": True,
        "provisioningProfiles": {"com.vertex.cortex": name},
    }
    with open("ios/ExportOptions.plist", "wb") as fh:
        plistlib.dump(options, fh, sort_keys=False)
    print(f"Apple profile installed: {name!r}; team {team}; bundle com.vertex.cortex")
    print("Xcode signing settings and ios/ExportOptions.plist prepared.")


if __name__ == "__main__":
    main()
