#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

PUBSPEC_PATH="${PUBSPEC_PATH:-pubspec.yaml}"
BUNDLE_ID="${BUNDLE_ID:-com.beyond.ondo}"
FASTLANE_USER_EMAIL="${FASTLANE_USER_EMAIL:-${FASTLANE_USER:-ink595@g.harvard.edu}}"
IOS_DIR="${IOS_DIR:-ios}"

if [ ! -f "$PUBSPEC_PATH" ]; then
  echo "ERROR: pubspec not found at $PUBSPEC_PATH"
  exit 1
fi

if [ ! -d "$IOS_DIR" ]; then
  echo "ERROR: iOS directory not found at $IOS_DIR"
  exit 1
fi

if [ ! -f "$IOS_DIR/Gemfile" ]; then
  echo "ERROR: Gemfile not found in $IOS_DIR. Fastlane/Spaceship is required for App Store build-number checks."
  exit 1
fi

PUBSPEC_VERSION_LINE="$(grep '^version:' "$PUBSPEC_PATH" | head -n 1 | awk '{print $2}')"
EXPECTED_SHORT_VERSION="${PUBSPEC_VERSION_LINE%%+*}"
EXPECTED_BUILD_NUMBER="${PUBSPEC_VERSION_LINE##*+}"

if [ -z "$EXPECTED_SHORT_VERSION" ] || [ -z "$EXPECTED_BUILD_NUMBER" ]; then
  echo "ERROR: Failed to parse version from $PUBSPEC_PATH"
  exit 1
fi

pushd "$IOS_DIR" >/dev/null
bundle exec ruby - "$BUNDLE_ID" "$EXPECTED_SHORT_VERSION" "$EXPECTED_BUILD_NUMBER" "$FASTLANE_USER_EMAIL" <<'RUBY'
require 'spaceship'

bundle_id, marketing_version, build_number, user_email = ARGV
expected_build = Integer(build_number)

Spaceship::Tunes.login(user_email)
app = Spaceship::ConnectAPI::App.find(bundle_id)
raise "App not found for bundle id #{bundle_id}" unless app

edit_version = app.get_edit_app_store_version(platform: 'IOS')
builds = app.get_builds(sort: '-uploadedDate', limit: 50)

numeric_builds = builds.filter_map do |build|
  begin
    Integer(build.version)
  rescue StandardError
    nil
  end
end

highest_uploaded_build = numeric_builds.max || 0

puts 'App Store Connect build-number preflight'
puts "  bundle id: #{bundle_id}"
puts "  pubspec marketing version: #{marketing_version}"
puts "  pubspec build number: #{expected_build}"
if edit_version
  puts "  edit version: #{edit_version.version_string} (#{edit_version.app_store_state})"
end
puts "  highest uploaded build: #{highest_uploaded_build}"

if expected_build <= highest_uploaded_build
  next_build = highest_uploaded_build + 1
  abort("ERROR: pubspec build number #{expected_build} has already been used in App Store Connect. Bump pubspec.yaml to at least #{next_build} before building or uploading.")
end

puts 'OK: pubspec build number is higher than the highest uploaded build on App Store Connect.'
RUBY
popd >/dev/null
