#!/usr/bin/env bash
# Generates JSON reports RepoTest parses — simulates unit/E2E without Node test runners.

repotest_env() {
  local primary="$1"
  local mtr="$2"
  local fiskal="$3"
  if [[ -n "${!primary:-}" ]]; then
    printf '%s' "${!primary}"
    return
  fi
  if [[ -n "${!mtr:-}" ]]; then
    printf '%s' "${!mtr}"
    return
  fi
  if [[ -n "${!fiskal:-}" ]]; then
    printf '%s' "${!fiskal}"
  fi
}

REPOTEST_TEST_TYPE="$(repotest_env REPOTEST_TEST_TYPE MTR_TEST_TYPE FISKAL_TEST_TYPE)"
REPOTEST_TEST_PLATFORM="$(repotest_env REPOTEST_TEST_PLATFORM MTR_TEST_PLATFORM FISKAL_TEST_PLATFORM)"
REPOTEST_TEST_FEATURE="$(repotest_env REPOTEST_TEST_FEATURE MTR_TEST_FEATURE FISKAL_TEST_FEATURE)"
REPOTEST_TEST_ENV="$(repotest_env REPOTEST_TEST_ENV MTR_TEST_ENV FISKAL_TEST_ENV)"
REPOTEST_TEST_REPORT_DIR="$(repotest_env REPOTEST_TEST_REPORT_DIR MTR_TEST_REPORT_DIR FISKAL_TEST_REPORT_DIR)"
REPOTEST_REPO_ROOT="$(repotest_env REPOTEST_REPO_ROOT MTR_REPO_ROOT FISKAL_REPO_ROOT)"
REPOTEST_TEST_RUN_ID="$(repotest_env REPOTEST_TEST_RUN_ID MTR_TEST_RUN_ID FISKAL_TEST_RUN_ID)"

ROOT="${REPOTEST_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
FIXTURES="$ROOT/fixtures"

report_enabled() {
  [[ -n "${REPOTEST_TEST_REPORT_DIR:-}" ]] || return 1
  mkdir -p "$REPOTEST_TEST_REPORT_DIR"
}

log_step() {
  echo "[demo] $*"
  sleep 0.35
}

run_seed() {
  log_step "Seeding demo database (no-op for this sample)…"
  log_step "Seed complete."
}

write_vitest_json() {
  local outfile="$REPOTEST_TEST_REPORT_DIR/vitest.json"
  local feature="${REPOTEST_TEST_FEATURE:-all}"
  cat >"$outfile" <<EOF
{
  "testResults": [
    {
      "name": "apps/web/tests/unit/features/${feature}/demo.test.ts",
      "assertionResults": [
        {
          "title": "renders welcome message",
          "status": "passed",
          "duration": 42
        },
        {
          "title": "validates session token shape",
          "status": "passed",
          "duration": 18
        }
      ]
    },
    {
      "name": "apps/web/tests/unit/features/${feature}/helpers.test.ts",
      "assertionResults": [
        {
          "title": "formats currency for checkout",
          "status": "passed",
          "duration": 7
        }
      ]
    }
  ]
}
EOF
  log_step "Wrote $outfile (3 passing unit tests)"
}

write_jest_mobile_unit_json() {
  local outfile="$REPOTEST_TEST_REPORT_DIR/jest-mobile-unit.json"
  local feature="${REPOTEST_TEST_FEATURE:-all}"
  cat >"$outfile" <<EOF
{
  "testResults": [
    {
      "name": "apps/mobile/__tests__/unit/features/${feature}/demo.test.ts",
      "assertionResults": [
        {
          "title": "shows login screen",
          "status": "passed",
          "duration": 55
        },
        {
          "title": "stores auth token securely",
          "status": "passed",
          "duration": 31
        }
      ]
    }
  ]
}
EOF
  log_step "Wrote $outfile (2 passing mobile unit tests)"
}

write_jest_e2e_json() {
  local platform="$1"
  local outfile="$REPOTEST_TEST_REPORT_DIR/jest-e2e-${platform}.json"
  local feature="${REPOTEST_TEST_FEATURE:-all}"
  cat >"$outfile" <<EOF
{
  "testResults": [
    {
      "name": "apps/mobile/e2e/features/${feature}/smoke.e2e.ts",
      "assertionResults": [
        {
          "title": "launches app on ${platform}",
          "status": "passed",
          "duration": 4200
        }
      ]
    }
  ]
}
EOF
  log_step "Wrote $outfile (1 passing mobile E2E test)"
}

copy_fixture_artifacts() {
  local dest_root="$REPOTEST_TEST_REPORT_DIR/playwright-output/auth-login-shows-dashboard"
  mkdir -p "$dest_root"
  if [[ -f "$FIXTURES/demo-screenshot.png" ]]; then
    cp "$FIXTURES/demo-screenshot.png" "$dest_root/test-failed-1.png"
  fi
  if [[ -f "$FIXTURES/demo-video.webm" ]]; then
    cp "$FIXTURES/demo-video.webm" "$dest_root/video.webm"
  fi
  if [[ -f "$FIXTURES/error-context.md" ]]; then
    cp "$FIXTURES/error-context.md" "$dest_root/error-context.md"
  fi
}

write_playwright_json() {
  local outfile="$REPOTEST_TEST_REPORT_DIR/playwright.json"
  local env="${REPOTEST_TEST_ENV:-local}"
  local shot_rel="playwright-output/auth-login-shows-dashboard/test-failed-1.png"
  local video_rel="playwright-output/auth-login-shows-dashboard/video.webm"
  cat >"$outfile" <<EOF
{
  "config": { "rootDir": "$ROOT/apps/web" },
  "suites": [
    {
      "title": "features/auth",
      "file": "apps/web/tests/e2e/features/auth/login.spec.ts",
      "specs": [
        {
          "title": "login shows dashboard",
          "tests": [
            {
              "results": [
                {
                  "status": "passed",
                  "duration": 2100,
                  "attachments": [
                    {
                      "name": "video",
                      "path": "$video_rel",
                      "contentType": "video/webm"
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "title": "rejects invalid password",
          "tests": [
            {
              "results": [
                {
                  "status": "failed",
                  "duration": 890,
                  "error": {
                    "message": "Demo failure: expected dashboard heading, received sign-in form.",
                    "stack": "Error: Demo failure at login.spec.ts:24:11"
                  },
                  "attachments": [
                    {
                      "name": "screenshot",
                      "path": "$shot_rel",
                      "contentType": "image/png"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "title": "features/checkout",
      "file": "apps/web/tests/e2e/features/checkout/cart.spec.ts",
      "specs": [
        {
          "title": "adds item to cart on ${env}",
          "tests": [
            {
              "results": [
                {
                  "status": "passed",
                  "duration": 1500,
                  "attachments": []
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
EOF
  log_step "Wrote $outfile (2 passed, 1 failed E2E — intentional for artifact demo)"
}

write_playwright_html() {
  local html_dir="$REPOTEST_TEST_REPORT_DIR/playwright-html"
  mkdir -p "$html_dir"
  cat >"$html_dir/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>RepoTest Demo — Playwright HTML Report</title>
  <style>
    body { font-family: -apple-system, sans-serif; margin: 2rem; color: #1d1d1f; }
    h1 { font-size: 1.25rem; }
    .pass { color: #248a3d; }
    .fail { color: #d70015; }
    ul { line-height: 1.6; }
  </style>
</head>
<body>
  <h1>RepoTest App Review sample</h1>
  <p>This is a minimal HTML report placeholder so the <strong>Playwright</strong> tab can load in RepoTest.</p>
  <ul>
    <li class="pass">auth › login shows dashboard</li>
    <li class="fail">auth › rejects invalid password (demo failure with screenshot)</li>
    <li class="pass">checkout › adds item to cart</li>
  </ul>
  <p>Open <strong>Results</strong> for the parsed tree; use <strong>Preview</strong> for the sample video attachment.</p>
</body>
</html>
EOF
  log_step "Wrote $html_dir/index.html"
}

write_preview_url() {
  echo "http://127.0.0.1:4173/" >"$REPOTEST_TEST_REPORT_DIR/preview-url.txt"
  log_step "Wrote preview-url.txt (demo dev server URL)"
}

run_web_unit() {
  report_enabled || return 0
  log_step "Running web unit tests (simulated)…"
  write_vitest_json
}

run_web_e2e() {
  report_enabled || return 0
  log_step "Running web E2E on env=${REPOTEST_TEST_ENV:-local} (simulated Playwright)…"
  copy_fixture_artifacts
  write_playwright_json
  write_playwright_html
  write_preview_url
}

run_mobile_unit() {
  report_enabled || return 0
  log_step "Running mobile unit tests (simulated Jest)…"
  write_jest_mobile_unit_json
}

run_mobile_e2e() {
  local platform="$1"
  report_enabled || return 0
  log_step "Running mobile E2E on ${platform} (simulated Detox)…"
  write_jest_e2e_json "$platform"
}

run_suite() {
  local type="${REPOTEST_TEST_TYPE:-unit}"
  local platform="${REPOTEST_TEST_PLATFORM:-web}"
  local feature="${REPOTEST_TEST_FEATURE:-all}"

  log_step "RepoTest Demo — type=$type platform=$platform feature=$feature run=${REPOTEST_TEST_RUN_ID:-local}"
  log_step "Report dir: ${REPOTEST_TEST_REPORT_DIR:-<not set>}"

  case "$type" in
    unit)
      case "$platform" in
        web) run_web_unit ;;
        mobile-android|mobile-ios) run_mobile_unit ;;
        mobile-both)
          run_mobile_unit
          ;;
        web-mobile)
          run_web_unit
          run_mobile_unit
          ;;
        *)
          echo "[demo] Unknown platform: $platform" >&2
          exit 1
          ;;
      esac
      ;;
    e2e)
      case "$platform" in
        web) run_web_e2e ;;
        mobile-android) run_mobile_e2e android ;;
        mobile-ios) run_mobile_e2e ios ;;
        mobile-both)
          run_mobile_e2e android
          run_mobile_e2e ios
          ;;
        web-mobile)
          run_web_e2e
          run_mobile_e2e android
          run_mobile_e2e ios
          ;;
        *)
          echo "[demo] Unknown platform: $platform" >&2
          exit 1
          ;;
      esac
      ;;
    both)
      case "$platform" in
        web)
          run_web_unit
          run_web_e2e
          ;;
        mobile-android)
          run_mobile_unit
          run_mobile_e2e android
          ;;
        mobile-ios)
          run_mobile_unit
          run_mobile_e2e ios
          ;;
        mobile-both)
          run_mobile_unit
          run_mobile_e2e android
          run_mobile_e2e ios
          ;;
        web-mobile)
          run_web_unit
          run_web_e2e
          run_mobile_unit
          run_mobile_e2e android
          run_mobile_e2e ios
          ;;
        *)
          echo "[demo] Unknown platform: $platform" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "[demo] Unknown test type: $type" >&2
      exit 1
      ;;
  esac

  log_step "Done."
}
