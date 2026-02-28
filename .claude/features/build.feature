@build
Feature: Build System
  As a developer
  I need a minimal build system
  That supports portable and APE profiles

  # ══════════════════════════════════════════════════════════════
  # BUILD PROFILES
  # ══════════════════════════════════════════════════════════════

  @portable
  Scenario: Build with portable profile
    Given PROFILE=portable
    When I run "make"
    Then it uses native compiler (gcc/clang)
    And links system libraries where needed
    And produces native executable

  @ape
  Scenario: Build with APE profile
    Given PROFILE=ape
    When I run "make"
    Then it uses cosmocc compiler
    And produces Actually Portable Executable
    And single binary runs on Linux/macOS/Windows
    And binary embeds all resources via /zip/

  # ══════════════════════════════════════════════════════════════
  # MAKE TARGETS
  # ══════════════════════════════════════════════════════════════

  Scenario: Default build target
    When I run "make"
    Then it builds with PROFILE=portable
    And compiles all source files
    And links into executable

  Scenario: Regeneration target
    When I run "make regen"
    Then all generators execute
    And gen/ directory is updated
    And GENERATOR_VERSION stamps updated

  Scenario: Drift check target
    When I run "make regen-check"
    Then generators run
    And "git diff --exit-code" is checked
    And fails if uncommitted changes exist

  Scenario: Clean target
    When I run "make clean"
    Then build artifacts are removed
    And gen/ directory is NOT removed
    And source files are NOT removed

  Scenario: Test target
    When I run "make test"
    Then test binaries are built
    And tests execute
    And results are reported

  # ══════════════════════════════════════════════════════════════
  # DEPENDENCIES
  # ══════════════════════════════════════════════════════════════

  Scenario: Generator dependencies
    Given "types.schema" includes "common.schema"
    When I modify "common.schema"
    And run "make regen"
    Then both files are processed
    And dependent outputs are regenerated

  Scenario: Incremental build
    Given a complete build exists
    When I modify one source file
    And run "make"
    Then only affected objects recompile
    And link step runs
    And build is faster than full build

  # ══════════════════════════════════════════════════════════════
  # RING-0 BOOTSTRAP GUARANTEE
  # ══════════════════════════════════════════════════════════════

  Scenario: Minimal bootstrap requirements
    Given only sh, make, and cc available
    And gen/ directory exists with committed code
    When I run "make"
    Then build succeeds
    And no Ring-1 or Ring-2 tools are invoked
    And output is functional

  Scenario: Bootstrap from clean checkout
    Given a git clone of the repository
    And committed gen/ directory
    When I run "make PROFILE=ape"
    Then build produces working APE binary
    And no external dependencies required
    And binary runs on any supported platform

  # ══════════════════════════════════════════════════════════════
  # COSMOPOLITAN INTEGRATION
  # ══════════════════════════════════════════════════════════════

  @ape
  Scenario: APE build flags
    Given PROFILE=ape
    Then CFLAGS includes -mcosmo
    And linker produces .com binary
    And resources embedded via zip

  @ape
  Scenario: Platform-specific code
    Given platform-specific implementations
    Then all platforms compile into single binary
    And runtime dispatch via IsLinux()/IsWindows()
    And no platform #ifdefs in generated code
