
#!/usr/bin/env bash
# Nginx Reverse Proxy & Web Security Lab
# HTTPS and HTTP security headers validation
#
# Usage:
#   bash scripts/check-security-headers.sh https://example.com
#
# Requirements: Bash, curl
# Only checks a URL supplied by the user.

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 https://example.com"
    exit 2
fi

URL="$1"

if [[ ! "$URL" =~ ^https://[^/[:space:]]+(/[^[:space:]]*)?$ ]]; then
    echo "ERROR: Provide a valid HTTPS URL."
    exit 2
fi

for cmd in curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Missing dependency: $cmd"
        exit 2
    fi
done

echo "======================================"
echo " HTTPS Security Validation"
echo "======================================"
echo "Target: $URL"
echo

# Do not use -k: TLS certificate verification is required.
HEADERS="$(curl -fsSIL --max-time 15 "$URL")" || {
    echo "FAIL: HTTPS connection or HTTP request failed."
    exit 1
}

HTTP_STATUS="$(curl -sS -o /dev/null \
    --max-time 15 -w '%{http_code}' "$URL")" || {
    echo "FAIL: Could not obtain HTTP status."
    exit 1
}

echo "HTTP status: $HTTP_STATUS"
echo "TLS certificate: validated by curl"
echo

CHECKS=(
    "strict-transport-security"
    "content-security-policy"
    "x-frame-options"
    "x-content-type-options"
)

FAILED=0

for HEADER in "${CHECKS[@]}"; do
    if printf '%s\n' "$HEADERS" | tr -d '\r' |
       grep -iq "^${HEADER}:"; then
        echo "[PASS] $HEADER"
    else
        echo "[FAIL] $HEADER is missing"
        FAILED=$((FAILED + 1))
    fi
done

echo
echo "======================================"

if [[ $FAILED -eq 0 ]]; then
    echo "RESULT: All security headers detected."
    exit 0
else
    echo "RESULT: $FAILED security header(s) missing."
    exit 1
fi
