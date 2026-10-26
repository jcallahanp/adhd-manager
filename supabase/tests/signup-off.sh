#!/usr/bin/env bash
# M1-01: public sign-up is off (D-006). Needs a running local stack (`supabase start`).
set -eu
out="$(mktemp)"
eval "$(supabase status -o env)"
code="$(curl -s -o "$out" -w '%{http_code}' -X POST "$API_URL/auth/v1/signup" \
  -H "apikey: $ANON_KEY" -H 'Content-Type: application/json' \
  -d '{"email":"signup-check@example.test","password":"not-a-real-password-1"}')"
grep -q signup_disabled "$out" && [ "$code" = 422 ] || { echo "::error::sign-up is open (HTTP $code): $(cat "$out")"; exit 1; }
echo "sign-up off"
