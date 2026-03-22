#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

PUBSPEC_PATH="${PUBSPEC_PATH:-pubspec.yaml}"
GENERATED_XCCONFIG_PATH="${GENERATED_XCCONFIG_PATH:-ios/Flutter/Generated.xcconfig}"
FLUTTER_ENV_PATH="${FLUTTER_ENV_PATH:-ios/Flutter/flutter_export_environment.sh}"
EXPORT_OPTIONS_PLIST_PATH="${EXPORT_OPTIONS_PLIST_PATH:-ios/ExportOptions.plist}"
EXPORTED_EXPORT_OPTIONS_PATH="${EXPORTED_EXPORT_OPTIONS_PATH:-build/ios/ipa/ExportOptions.plist}"
IPA_PATH="${IPA_PATH:-}"
ARCHIVE_PATH="${ARCHIVE_PATH:-build/ios/archive/Runner.xcarchive}"

if [ -z "$IPA_PATH" ]; then
  IPA_PATH="$(find build/ios/ipa -maxdepth 1 -name '*.ipa' -print | head -n 1 || true)"
fi

if [ -z "$IPA_PATH" ] || [ ! -f "$IPA_PATH" ]; then
  echo "ERROR: IPA not found. Set IPA_PATH or build an IPA first."
  exit 1
fi

if [ ! -f "$PUBSPEC_PATH" ]; then
  echo "ERROR: pubspec not found at $PUBSPEC_PATH"
  exit 1
fi

PUBSPEC_VERSION_LINE="$(grep '^version:' "$PUBSPEC_PATH" | head -n 1 | awk '{print $2}')"
EXPECTED_SHORT_VERSION="${PUBSPEC_VERSION_LINE%%+*}"
EXPECTED_BUILD_NUMBER="${PUBSPEC_VERSION_LINE##*+}"

if [ -z "$EXPECTED_SHORT_VERSION" ] || [ -z "$EXPECTED_BUILD_NUMBER" ]; then
  echo "ERROR: Failed to parse version from $PUBSPEC_PATH"
  exit 1
fi

GENERATED_BUILD_NAME=""
GENERATED_BUILD_NUMBER=""
if [ -f "$GENERATED_XCCONFIG_PATH" ]; then
  GENERATED_BUILD_NAME="$(grep '^FLUTTER_BUILD_NAME=' "$GENERATED_XCCONFIG_PATH" | cut -d'=' -f2- || true)"
  GENERATED_BUILD_NUMBER="$(grep '^FLUTTER_BUILD_NUMBER=' "$GENERATED_XCCONFIG_PATH" | cut -d'=' -f2- || true)"
fi

ENV_BUILD_NAME=""
ENV_BUILD_NUMBER=""
if [ -f "$FLUTTER_ENV_PATH" ]; then
  ENV_BUILD_NAME="$(grep '^export "FLUTTER_BUILD_NAME=' "$FLUTTER_ENV_PATH" | sed 's/^export "FLUTTER_BUILD_NAME=//; s/"$//' || true)"
  ENV_BUILD_NUMBER="$(grep '^export "FLUTTER_BUILD_NUMBER=' "$FLUTTER_ENV_PATH" | sed 's/^export "FLUTTER_BUILD_NUMBER=//; s/"$//' || true)"
fi

python3 - "$IPA_PATH" "$ARCHIVE_PATH" "$EXPECTED_SHORT_VERSION" "$EXPECTED_BUILD_NUMBER" "$GENERATED_BUILD_NAME" "$GENERATED_BUILD_NUMBER" "$ENV_BUILD_NAME" "$ENV_BUILD_NUMBER" "$EXPORT_OPTIONS_PLIST_PATH" "$EXPORTED_EXPORT_OPTIONS_PATH" <<'PY'
import os
import plistlib
import sys
import zipfile

(
    ipa_path,
    archive_path,
    expected_short_version,
    expected_build_number,
    generated_build_name,
    generated_build_number,
    env_build_name,
    env_build_number,
    source_export_options_path,
    exported_export_options_path,
) = sys.argv[1:]


def fail(message: str) -> None:
    print(f"ERROR: {message}")
    sys.exit(1)


def read_ipa_info(path: str):
    with zipfile.ZipFile(path) as zf:
        matches = [name for name in zf.namelist() if name.endswith("Runner.app/Info.plist")]
        if not matches:
            fail(f"Runner.app/Info.plist not found inside IPA: {path}")
        info = plistlib.loads(zf.read(matches[0]))
        return info.get("CFBundleShortVersionString"), info.get("CFBundleVersion")


def read_embedded_bundle_infos(path: str):
    bundle_infos = []
    with zipfile.ZipFile(path) as zf:
        for name in zf.namelist():
            if not name.startswith("Payload/Runner.app/") or not name.endswith("Info.plist"):
                continue
            if name == "Payload/Runner.app/Info.plist":
                continue
            if ".appex/" not in name and "/Watch/" not in name:
                continue

            info = plistlib.loads(zf.read(name))
            bundle_infos.append(
                (
                    name,
                    info.get("CFBundleShortVersionString"),
                    info.get("CFBundleVersion"),
                )
            )
    return bundle_infos


def read_archive_info(path: str):
    info_path = os.path.join(path, "Info.plist")
    if not os.path.exists(info_path):
        return None, None
    with open(info_path, "rb") as f:
        info = plistlib.load(f)
    app = info.get("ApplicationProperties", {})
    return app.get("CFBundleShortVersionString"), app.get("CFBundleVersion")


def read_export_options(path: str):
    if not path or not os.path.exists(path):
        return None
    with open(path, "rb") as f:
        return plistlib.load(f)


print("iOS release artifact verification")
print(f"  pubspec expected short version: {expected_short_version}")
print(f"  pubspec expected build number: {expected_build_number}")

if generated_build_name or generated_build_number:
    print(f"  Generated.xcconfig: short={generated_build_name} build={generated_build_number}")
    if generated_build_name != expected_short_version or generated_build_number != expected_build_number:
        fail("Generated.xcconfig is stale. Regenerate iOS build settings with `flutter build ios` or `flutter build ipa` before uploading.")

if env_build_name or env_build_number:
    print(f"  flutter_export_environment.sh: short={env_build_name} build={env_build_number}")
    if env_build_name != expected_short_version or env_build_number != expected_build_number:
        fail("flutter_export_environment.sh is stale. Regenerate iOS build settings with `flutter build ios` or `flutter build ipa` before uploading.")

source_export_options = read_export_options(source_export_options_path)
if source_export_options:
    source_method = source_export_options.get("method")
    source_manage_versions = source_export_options.get("manageAppVersionAndBuildNumber")
    print(f"  Source ExportOptions: method={source_method} manageAppVersionAndBuildNumber={source_manage_versions}")
    if source_method in {"app-store", "app-store-connect"} and source_manage_versions is not False:
        fail("ios/ExportOptions.plist must set manageAppVersionAndBuildNumber to false for deterministic App Store release artifacts.")

ipa_short, ipa_build = read_ipa_info(ipa_path)
print(f"  IPA: {ipa_path}")
print(f"    short={ipa_short} build={ipa_build}")
if ipa_short != expected_short_version or ipa_build != expected_build_number:
    fail("IPA version/build does not match pubspec. Do not upload this artifact.")

embedded_bundle_infos = read_embedded_bundle_infos(ipa_path)
for bundle_path, bundle_short, bundle_build in embedded_bundle_infos:
    print(f"  Embedded bundle: {bundle_path}")
    print(f"    short={bundle_short} build={bundle_build}")
    if bundle_short != expected_short_version or bundle_build != expected_build_number:
        fail(
            "Embedded app extension/watch bundle version/build does not match pubspec. "
            f"Offending bundle: {bundle_path}"
        )

archive_short, archive_build = read_archive_info(archive_path)
if archive_short or archive_build:
    print(f"  Archive: {archive_path}")
    print(f"    short={archive_short} build={archive_build}")
    if archive_short != expected_short_version or archive_build != expected_build_number:
        fail("xcarchive version/build does not match pubspec. Rebuild before upload.")

exported_export_options = read_export_options(exported_export_options_path)
if exported_export_options:
    exported_method = exported_export_options.get("method")
    exported_manage_versions = exported_export_options.get("manageAppVersionAndBuildNumber")
    print(f"  Exported ExportOptions: method={exported_method} manageAppVersionAndBuildNumber={exported_manage_versions}")
    if exported_method in {"app-store", "app-store-connect"} and exported_manage_versions is not False:
        fail("Exported IPA was created with manageAppVersionAndBuildNumber enabled. Rebuild with ios/ExportOptions.plist before uploading.")

print("OK: iOS release artifacts match pubspec and generated Flutter iOS settings.")
PY
