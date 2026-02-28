@drift
Feature: Drift Detection and Prevention
  As a maintainer
  I need generated code to be committed and drift-gated
  So that builds are reproducible without Ring-2 tools

  Background:
    Given Ring-2 generator outputs are committed to git
    And GENERATOR_VERSION stamps exist for each generator

  # ══════════════════════════════════════════════════════════════
  # DRIFT GATE
  # ══════════════════════════════════════════════════════════════

  Scenario: Clean build with no drift
    Given specs have not changed since last regen
    And generators have not been updated
    When I run "make regen-check"
    Then the command succeeds
    And "git diff --exit-code" passes
    And no files are modified

  Scenario: Detect drift from spec change
    Given a schema spec "types.schema"
    When I add a new field to a type
    And run "make regen"
    Then "gen/schemagen/types.h" is modified
    And "git diff" shows the change
    And I must commit the regenerated code

  Scenario: Detect drift from generator update
    Given StateSmith version was "0.9.13"
    When I update StateSmith to "0.9.14"
    And run "make regen"
    Then GENERATOR_VERSION shows new version
    And generated code may have changed
    And I review and commit changes

  Scenario: Block merge with uncommitted drift
    Given a pull request with spec changes
    But regenerated code was not committed
    When CI runs "make regen-check"
    Then the check fails
    And error message indicates drift
    And PR cannot be merged

  # ══════════════════════════════════════════════════════════════
  # VERSION STAMPS
  # ══════════════════════════════════════════════════════════════

  Scenario: Generator version is stamped
    When I run schemagen
    Then "gen/schemagen/GENERATOR_VERSION" contains:
      """
      schemagen 1.0.0
      generated: 2026-02-28T04:00:00Z
      profile: portable
      """

  Scenario: SHA256 sums for integrity
    When I run any generator
    Then "gen/<tool>/SHA256SUMS" is created
    And contains checksum for each generated file
    And can be verified with "sha256sum -c"

  # ══════════════════════════════════════════════════════════════
  # RING-0 BOOTSTRAP
  # ══════════════════════════════════════════════════════════════

  Scenario: Build without Ring-2 tools
    Given a clean checkout with committed gen/ directory
    And Ring-2 tools are NOT installed
    When I run "make PROFILE=ape"
    Then the build succeeds using committed generated code
    And no regeneration is attempted
    And output binary is functional

  Scenario: Ring-1 tools are optional
    Given Ring-1 tools (sanitizers, cppcheck) not available
    When I run "make"
    Then the build succeeds
    And optional checks are skipped
    And warning indicates skipped checks

  # ══════════════════════════════════════════════════════════════
  # REPRODUCIBILITY
  # ══════════════════════════════════════════════════════════════

  Scenario: Deterministic generation
    Given a spec file "types.schema"
    When I run schemagen twice
    Then output files are byte-identical
    And no timestamps in generated code
    And SHA256SUMS matches both times

  Scenario: Cross-platform reproducibility
    Given generated code on Linux
    When I run same generators on macOS
    Then generated code is identical
    And line endings are normalized (LF)
    And no platform-specific artifacts
