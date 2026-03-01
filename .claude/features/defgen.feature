Feature: Definition Generator (defgen)
  As a developer using cosmo-bde
  I want to define constants, enums, and configs in .def files
  So that I get consistent, type-safe C code with X-Macro support

  Background:
    Given defgen is compiled and available
    And an empty output directory

  # ═══ Constants ═══════════════════════════════════════════════

  Scenario: Generate integer constant
    Given a .def file containing:
      """
      const MAX_SIZE = 1024
      """
    When I run defgen
    Then the output header should contain:
      """
      #define MAX_SIZE 1024
      """

  Scenario: Generate string constant
    Given a .def file containing:
      """
      const VERSION = "1.0.0"
      """
    When I run defgen
    Then the output header should contain:
      """
      #define VERSION "1.0.0"
      """

  Scenario: Generate expression constant
    Given a .def file containing:
      """
      const BUFFER_SIZE = 1 << 16
      """
    When I run defgen
    Then the output header should contain:
      """
      #define BUFFER_SIZE (1 << 16)
      """

  # ═══ Enums ═══════════════════════════════════════════════════

  Scenario: Generate enum with X-Macro table
    Given a .def file containing:
      """
      enum LogLevel [prefix: "LOG_"] {
          DEBUG = 0
          INFO = 1
          ERROR = 2
      }
      """
    When I run defgen
    Then the output header should contain:
      """
      #define LOGLEVEL_XMACRO(X) \
          X(LOG_DEBUG, 0, "DEBUG") \
          X(LOG_INFO,  1, "INFO")  \
          X(LOG_ERROR, 2, "ERROR")
      """
    And the output header should contain:
      """
      typedef enum {
      """
    And the output header should contain:
      """
      const char* LogLevel_to_string(LogLevel val);
      """

  Scenario: Generate enum to_string function
    Given a .def file with enum LogLevel
    When I run defgen
    And I compile the generated code
    Then LogLevel_to_string(LOG_DEBUG) should return "DEBUG"
    And LogLevel_to_string(LOG_INFO) should return "INFO"
    And LogLevel_to_string(99) should return "UNKNOWN"

  Scenario: Generate enum from_string function
    Given a .def file with enum LogLevel
    When I run defgen
    And I compile the generated code
    Then LogLevel_from_string("DEBUG", &out) should set out to LOG_DEBUG
    And LogLevel_from_string("INVALID", &out) should return false

  Scenario: Enum with auto-incrementing values
    Given a .def file containing:
      """
      enum Color {
          RED
          GREEN
          BLUE
      }
      """
    When I run defgen
    Then COLOR_RED should equal 0
    And COLOR_GREEN should equal 1
    And COLOR_BLUE should equal 2

  # ═══ Flags ═══════════════════════════════════════════════════

  Scenario: Generate flags with bitmask values
    Given a .def file containing:
      """
      flags Permissions [prefix: "PERM_"] {
          READ = 0x01
          WRITE = 0x02
          EXEC = 0x04
      }
      """
    When I run defgen
    Then the output header should contain:
      """
      typedef uint32_t Permissions;
      """
    And the output header should contain:
      """
      #define PERM_READ  0x01
      #define PERM_WRITE 0x02
      #define PERM_EXEC  0x04
      """
    And the output header should contain:
      """
      #define PERMISSIONS_HAS(flags, flag) (((flags) & (flag)) != 0)
      """

  Scenario: Generate flags to_string with multiple flags set
    Given a .def file with flags Permissions
    When I run defgen
    And I compile the generated code
    Then Permissions_to_string(PERM_READ | PERM_WRITE, buf, 64) should produce "READ|WRITE"

  # ═══ Config ══════════════════════════════════════════════════

  Scenario: Generate config struct with defaults
    Given a .def file containing:
      """
      config ServerConfig {
          port: u16 = 8080 [range: 1024..65535]
          workers: u8 = 4 [range: 1..32]
      }
      """
    When I run defgen
    Then the output header should contain:
      """
      typedef struct {
          uint16_t port;
          uint8_t workers;
      } ServerConfig;
      """
    And the output source should contain:
      """
      void ServerConfig_init(ServerConfig *cfg) {
          cfg->port = 8080;
          cfg->workers = 4;
      }
      """

  Scenario: Generate config validation
    Given a .def file with config ServerConfig with range constraints
    When I run defgen
    And I compile the generated code
    And ServerConfig.port is set to 80
    Then ServerConfig_validate(&cfg) should return false

  Scenario: Generate config validation passes
    Given a .def file with config ServerConfig with range constraints
    When I run defgen
    And I compile the generated code
    And ServerConfig.port is set to 8080
    Then ServerConfig_validate(&cfg) should return true

  # ═══ Error Handling ══════════════════════════════════════════

  Scenario: Invalid .def file syntax
    Given a .def file containing:
      """
      enum BadEnum {
          VALUE =
      }
      """
    When I run defgen
    Then defgen should exit with error code 1
    And stderr should contain "syntax error"
    And stderr should contain line number

  Scenario: Duplicate constant name
    Given a .def file containing:
      """
      const FOO = 1
      const FOO = 2
      """
    When I run defgen
    Then defgen should exit with error code 1
    And stderr should contain "duplicate definition: FOO"

  # ═══ Self-Hosting ════════════════════════════════════════════

  @self-hosting
  Scenario: Defgen processes its own .def file
    Given defgen.def exists in specs/
    When I run bootstrap defgen on defgen.def
    And I compile defgen with generated types
    And I run self-hosted defgen on defgen.def
    Then the output should match bootstrap output exactly
