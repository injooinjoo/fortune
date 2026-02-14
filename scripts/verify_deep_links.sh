#!/usr/bin/env bash
set -euo pipefail

DEFAULT_DOMAINS=(zpzg.co.kr www.zpzg.co.kr)
DEFAULT_PATHS=("/.well-known/apple-app-site-association" "/.well-known/assetlinks.json")

ROOT_CHECK=0
DOMAINS=()
PATHS=("${DEFAULT_PATHS[@]}")

for arg in "$@"; do
  case "${arg}" in
    --root-check)
      ROOT_CHECK=1
      ;;
    -*)
      echo "Unknown option: ${arg}"
      echo "Usage: $0 [--root-check] [domains...]"
      exit 2
      ;;
    *)
      DOMAINS+=("${arg}")
      ;;
  esac
done

if [ "${ROOT_CHECK}" -eq 1 ]; then
  PATHS=("/" "${PATHS[@]}")
fi

if [ "${#DOMAINS[@]}" -eq 0 ]; then
  DOMAINS=("${DEFAULT_DOMAINS[@]}")
fi

HAS_FAIL=0

check() {
  local domain="$1"
  local path="$2"
  local url="https://${domain}${path}"
  local header_file
  local body_file
  local http_count
  local final_status

  header_file="$(mktemp)"
  body_file="$(mktemp)"

  echo "==> ${url}"
  curl -sSL -D "${header_file}" "${url}" -o "${body_file}"
  sed -n '1,40p' "${header_file}"

  http_count="$(rg -c '^HTTP/' "${header_file}" || true)"
  if [ "${http_count}" -gt 1 ]; then
    echo "FAIL: Redirect detected (${http_count} responses)."
    HAS_FAIL=1
  fi

  final_status="$(rg '^HTTP/' "${header_file}" | tail -n 1 | awk '{print $2}')"
  if [ "${final_status}" != "200" ]; then
    echo "FAIL: Final status is ${final_status}, expected 200."
    HAS_FAIL=1
  fi

  case "${path}" in
    /.well-known/apple-app-site-association)
      if ! rg -iq '^content-type: (application/octet-stream|application/json)' "${header_file}"; then
        echo "FAIL: Content-Type is not expected (application/octet-stream or application/json)."
        HAS_FAIL=1
      fi
      ;;
    "/")
      ;;
    *)
      if ! rg -iq '^content-type: application/json' "${header_file}"; then
        echo "FAIL: Content-Type is not expected (application/json)."
        HAS_FAIL=1
      fi
      ;;
  esac

  if [ "${path}" = "/.well-known/assetlinks.json" ] && rg -q 'TODO_REPLACE_WITH_YOUR_SHA256_FINGERPRINT' "${body_file}"; then
    echo "FAIL: assetlinks placeholder SHA256 detected."
    HAS_FAIL=1
  fi

  if [ "${path}" = "/" ]; then
    if ! rg -q "ZPZG" "${body_file}"; then
      echo "WARN: / has no expected landing content marker."
    fi
  fi

  rm -f "${header_file}" "${body_file}"
  echo
}

for domain in "${DOMAINS[@]}"; do
  for path in "${PATHS[@]}"; do
    check "${domain}" "${path}"
  done
done

if [ "${HAS_FAIL}" -ne 0 ]; then
  echo "Result: BLOCKER"
  exit 1
fi

echo "Done."
