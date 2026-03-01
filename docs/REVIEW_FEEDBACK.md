# Repository Review Feedback (Coherence, Quality, Improvements)

This review focuses on composability, X-macro usage, CI/CD alignment, and naming consistency.

## 1) Ring composability (`specs/` → `gen/` → `src/`)

### What is coherent
- `Makefile` clearly encodes format-driven discovery and generation paths for core Ring 0 formats (`.schema`, `.def`, `.sm`, `.lex`, `.grammar`).
- The documented workflow in `.claude/CLAUDE.md` and target output naming from the build rules are aligned.
- `scripts/feedback-loop.sh` demonstrates progressive Ring 0/1/2 behavior and validates the intended "authoring vs shipping" split.

### Gaps / risks
- Drift checks are timestamp-sensitive (`GENERATOR_VERSION` churn), which can fail verification despite no semantic changes.
- Optional Ring 2 sections are present, but demonstration coverage is uneven (documented as known TODOs).

### Suggested improvements
- Make drift verification semantic (ignore generator timestamp-only changes) or move timestamps to build artifacts not drift-gated.
- Add one end-to-end golden spec fixture per layer (`domain`, `parsing`, `testing`) that runs in CI.

## 2) X-macro pattern (`procmem.def` → generated headers)

### What is coherent
- `specs/domain/procmem.def` is a strong single-source table with clear macro groups and docs.
- `docs/XMACROS.md` explains expansion strategy and usage patterns well.

### Gaps / risks
- Current `defgen` recognizes `TOK/TABLE` style inputs but does not yet parse the higher-level `enum/flags` DSL documented in `docs/XMACROS.md`.

### Suggested improvements
- Split docs into "implemented now" vs "planned syntax" sections to prevent expectation mismatch.
- Add `defgen` fixture tests that compile generated headers for representative TOK/TABLE and procmem-like macro tables.

## 3) CI/CD alignment (`repo-ci.yml`, `template-ci.yml`, `ci.yml`)

### What is coherent
- Separation of concerns is explicit:
  - `repo-ci.yml` for framework development
  - `template-ci.yml` for downstream users
  - `ci.yml` as baseline CI workflow
- BDD fallback behavior is honest in template CI when `bddgen` is unavailable.

### Gaps / risks
- There is overlap and potential drift in repeated install/build snippets across workflows.
- Ring 2 checks are partly informational and may give a false sense of validated support.

### Suggested improvements
- Extract shared CI logic into a reusable workflow (`workflow_call`) or composite action.
- Add a CI job that compares `repo-ci.yml` and `template-ci.yml` shared steps for drift (structural lint).

## 4) Naming conventions (`_types.c`, `_defs.h`, `_sm.c`)

### What is coherent
- Naming rules are explicitly codified in docs and reflected in generation rules.
- Generated outputs under `gen/` largely match suffix conventions.

### Gaps / risks
- `defgen` currently emits `_tokens.h` and `_model.h` for TOK/TABLE flows, which can diverge from the `_defs.h` expectation in top-level docs.

### Suggested improvements
- Decide whether `_defs.h` is canonical for all `.def` outputs or document sanctioned exceptions (`_tokens.h`, `_model.h`).
- Add `make lint-names` to verify generated file suffixes against format mapping.

## Additional implementation fix from review run

- Ring 0 tool builds under `-Werror` previously failed because several generators ignored `system()` return values.
- `defgen`, `smgen`, `lexgen`, and `uigen` now create output directories using a checked `mkdir()` helper instead of `system("mkdir -p ...")`, eliminating `warn_unused_result` failures and improving portability/safety.
