Feature: Ring 1 Tools - Velocity Layer
  As a developer using cosmo-bde
  I want to use Ring 1 tools for enhanced productivity
  So that I can generate CLI parsers, analyze code, and debug efficiently

  # ═══ Gengetopt ═══════════════════════════════════════════════

  @gengetopt
  Scenario: Generate CLI parser from .ggo file
    Given a .ggo file containing:
      """
      package "myapp"
      version "1.0"
      option "verbose" v "Verbose output" flag off
      option "config" c "Config file" string optional
      """
    When I run gengetopt on the .ggo file
    Then it should generate cmdline.h
    And it should generate cmdline.c
    And cmdline.h should declare cmdline_parser()
    And cmdline.h should declare struct gengetopt_args_info

  @gengetopt
  Scenario: CLI parser handles required options
    Given a .ggo file with required option "input"
    When I run the generated parser without --input
    Then the parser should return an error
    And the error should mention "input"

  @gengetopt
  Scenario: CLI parser generates help text
    Given a .ggo file with multiple options
    When I run the compiled program with --help
    Then it should display all options with descriptions
    And it should show default values
    And it should show required options marked

  @gengetopt
  Scenario: CLI parser handles multiple values
    Given a .ggo file with multiple option:
      """
      option "file" f "Input files" string multiple optional
      """
    When I run the parser with -f a.txt -f b.txt -f c.txt
    Then args.file_given should be 3
    And args.file_arg[0] should be "a.txt"

  # ═══ Cppcheck ════════════════════════════════════════════════

  @cppcheck
  Scenario: Detect null pointer dereference
    Given a C file with potential null dereference:
      """
      void test(int *p) {
          *p = 5;  // p could be null
      }
      """
    When I run cppcheck on the file
    Then it should report "nullPointer" or "nullPointerRedundantCheck"

  @cppcheck
  Scenario: Detect memory leak
    Given a C file with memory leak:
      """
      void leak() {
          char *p = malloc(100);
          return;  // p is never freed
      }
      """
    When I run cppcheck with --enable=warning
    Then it should report "memleak"

  @cppcheck
  Scenario: Detect uninitialized variable
    Given a C file with uninitialized read:
      """
      int test() {
          int x;
          return x;  // x is uninitialized
      }
      """
    When I run cppcheck
    Then it should report "uninitvar"

  @cppcheck
  Scenario: Suppress specific warnings
    Given a cppcheck suppression file:
      """
      nullPointer:legacy/*.c
      uninitvar:*:100
      """
    When I run cppcheck with --suppressions-list
    Then matching warnings should be suppressed

  @cppcheck
  Scenario: Run MISRA checks
    Given a C file and MISRA configuration
    When I run cppcheck --addon=misra
    Then it should check MISRA C:2012 rules
    And violations should be reported with rule numbers

  # ═══ Sanitizers ══════════════════════════════════════════════

  @asan
  Scenario: AddressSanitizer detects buffer overflow
    Given a program with heap buffer overflow:
      """
      int main() {
          char *buf = malloc(10);
          buf[10] = 'x';  // Out of bounds
          return 0;
      }
      """
    When I compile with -fsanitize=address
    And I run the program
    Then ASan should report "heap-buffer-overflow"
    And it should show the allocation stack trace

  @asan
  Scenario: AddressSanitizer detects use-after-free
    Given a program with use-after-free:
      """
      int main() {
          int *p = malloc(sizeof(int));
          free(p);
          *p = 42;  // Use after free
          return 0;
      }
      """
    When I compile with -fsanitize=address
    And I run the program
    Then ASan should report "heap-use-after-free"

  @ubsan
  Scenario: UBSan detects signed integer overflow
    Given a program with integer overflow:
      """
      int main() {
          int x = 2147483647;
          x = x + 1;  // Signed overflow is UB
          return x;
      }
      """
    When I compile with -fsanitize=undefined
    And I run the program
    Then UBSan should report "signed integer overflow"

  @ubsan
  Scenario: UBSan detects null pointer dereference
    Given a program dereferencing null:
      """
      int main() {
          int *p = 0;
          return *p;
      }
      """
    When I compile with -fsanitize=undefined
    And I run the program
    Then UBSan should report null pointer access

  @tsan
  Scenario: ThreadSanitizer detects data race
    Given a multi-threaded program with data race:
      """
      int shared = 0;
      void* thread_func(void* arg) {
          shared++;  // Unsynchronized access
          return NULL;
      }
      """
    When I compile with -fsanitize=thread
    And I run the program with multiple threads
    Then TSan should report "data race"

  # ═══ Integration ═════════════════════════════════════════════

  @ring1 @integration
  Scenario: Ring 1 tools work with Ring 0 code
    Given Ring 0 generated code from schemagen
    When I run cppcheck on the generated code
    Then there should be no errors
    And style warnings should be minimal

  @ring1 @integration
  Scenario: Sanitizers work with APE binaries
    Given a program compiled with cosmocc and -fsanitize=address
    When I run the APE binary
    Then sanitizer runtime should work correctly
    And it should detect memory errors

  @ring1 @fallback
  Scenario: Ring 1 tools have Ring 0 fallbacks
    Given gengetopt is not available
    When I try to generate CLI parser
    Then the build should suggest hand-written fallback
    Or use a minimal Ring 0 argument parser
