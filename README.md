# RepoTest App Review sample project

Self-contained demo repository for **Apple App Review** and anyone evaluating **RepoTest**. It implements the [RepoTest scripts contract](https://github.com/nikolayu/MacTestRunner/blob/main/docs/integrating-your-project.md) without installing npm packages or running real Vitest/Playwright.

## Quick start (in RepoTest)

1. Install **RepoTest** from the Mac App Store (or run a TestFlight build).
2. **File → Open Project…** and select **this folder** (the repo root that contains `scripts/test.sh`).
3. Sidebar:
   - **Test type:** Unit only (free tier) or E2E / Unit + E2E (Pro subscription).
   - **Platform:** Web (recommended first).
   - **Feature:** All or Authentication.
   - **Environment:** Local (for E2E).
4. Click **Run**. Console output streams on the right; **Results** fills in within a few seconds.

### What you should see

| Configuration | Results |
|---------------|---------|
| Unit · Web | 3 passing unit tests (`vitest.json`) |
| E2E · Web | 2 passed, 1 **failed** E2E (intentional — screenshot + error message) |
| E2E · Web | **Preview** tab: sample `.webm` video on the passing auth test |
| E2E · Web | **Playwright** tab: minimal HTML report |
| Unit · Android / iOS | Simulated Jest mobile unit JSON |
| E2E · Android / iOS | Simulated Detox JSON (no emulator required for this demo) |

**Seed DB** (toolbar, Pro): runs `scripts/test.sh --seed` and logs a no-op seed — proves the hook works.

## Prerequisites

RepoTest still checks that `node` and `npm` exist on PATH (common on developer Macs). This demo does **not** invoke them. For **mobile** platforms, RepoTest also expects `flutter` when Android/iOS is selected.

## Run from Terminal (optional)

```bash
cd /path/to/repotest-app-review-sample
export REPOTEST_TEST_NONINTERACTIVE=1
export REPOTEST_REPO_ROOT="$PWD"
export REPOTEST_TEST_REPORT_DIR=/tmp/repotest-demo-report
mkdir -p "$REPOTEST_TEST_REPORT_DIR"

export REPOTEST_TEST_TYPE=unit REPOTEST_TEST_PLATFORM=web REPOTEST_TEST_FEATURE=all
bash scripts/test.sh
ls -la "$REPOTEST_TEST_REPORT_DIR"

export REPOTEST_TEST_TYPE=e2e REPOTEST_TEST_ENV=local
bash scripts/test.sh
ls -la "$REPOTEST_TEST_REPORT_DIR"
```

## Pro / sandbox subscription (E2E)

E2E and **Unit + E2E** require **RepoTest Pro**. In review builds, sign in with the **sandbox Apple ID** provided in App Store Connect review notes, then subscribe (Monthly or Annual) or use **Restore Purchases**.

## Files

| Path | Purpose |
|------|---------|
| `scripts/test.sh` | Entry point RepoTest executes |
| `scripts/test-manifest.json` | Sidebar options |
| `scripts/test-lib.sh` | Writes `vitest.json`, `playwright.json`, etc. |
| `fixtures/` | Sample screenshot, video, error context for E2E failure UI |
| `apps/web/.env` | Silences optional DB env prerequisite warning |

## Distribution for review

Zip this folder or host it as a public git repo and paste the path/URL into **App Review Information → Notes** in App Store Connect. See `docs/app-store-demo-repo.md` in the RepoTest repository for suggested review note text.
