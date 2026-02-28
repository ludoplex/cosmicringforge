Feature: Schema Generator (schemagen)
  As a developer using CosmicRingForge
  I want to define data types in .schema files
  So that I get consistent C structs with init/validate functions

  Background:
    Given schemagen is compiled and available
    And an empty output directory

  # ═══ Basic Type Generation ═══════════════════════════════════

  Scenario: Generate simple struct
    Given a .schema file containing:
      """
      type Point {
          x: i32
          y: i32
      }
      """
    When I run schemagen
    Then the output header should contain:
      """
      struct Point {
          int32_t x;
          int32_t y;
      };
      """

  Scenario: Generate init function
    Given a .schema file with type Point
    When I run schemagen
    Then the output source should contain:
      """
      void Point_init(Point *obj) {
      """

  Scenario: Generate validate function
    Given a .schema file with type Point
    When I run schemagen
    Then the output header should contain:
      """
      bool Point_validate(const Point *obj);
      """

  # ═══ Field Types ═════════════════════════════════════════════

  Scenario Outline: Generate correct C type for base types
    Given a .schema file containing:
      """
      type Test {
          field: <schema_type>
      }
      """
    When I run schemagen
    Then the output header should contain:
      """
      <c_type> field;
      """

    Examples:
      | schema_type | c_type      |
      | i8          | int8_t      |
      | i16         | int16_t     |
      | i32         | int32_t     |
      | i64         | int64_t     |
      | u8          | uint8_t     |
      | u16         | uint16_t    |
      | u32         | uint32_t    |
      | u64         | uint64_t    |
      | f32         | float       |
      | f64         | double      |
      | bool        | bool        |

  Scenario: Generate fixed-size string
    Given a .schema file containing:
      """
      type Config {
          name: string[64]
      }
      """
    When I run schemagen
    Then the output header should contain:
      """
      char name[64];
      """

  Scenario: Generate nested struct reference
    Given a .schema file containing:
      """
      type Point { x: i32  y: i32 }
      type Line {
          start: Point
          end: Point
      }
      """
    When I run schemagen
    Then the output header should contain:
      """
      Point start;
      Point end;
      """

  # ═══ Constraints ═════════════════════════════════════════════

  Scenario: Field with default value
    Given a .schema file containing:
      """
      type Config {
          port: i32 [default: 8080]
      }
      """
    When I run schemagen
    Then the init function should set port to 8080

  Scenario: Field with range constraint
    Given a .schema file containing:
      """
      type Config {
          port: i32 [range: 1..65535]
      }
      """
    When I run schemagen
    And I compile the generated code
    Then Config_validate with port=0 should return false
    Then Config_validate with port=80 should return true
    Then Config_validate with port=99999 should return false

  Scenario: Field with not_empty constraint
    Given a .schema file containing:
      """
      type User {
          name: string[64] [not_empty]
      }
      """
    When I run schemagen
    And I compile the generated code
    Then User_validate with name="" should return false
    Then User_validate with name="Alice" should return true

  Scenario: Multiple constraints
    Given a .schema file containing:
      """
      type Port {
          value: i32 [range: 1024..65535, default: 8080]
      }
      """
    When I run schemagen
    Then the init function should set value to 8080
    And the validate function should check range 1024..65535

  # ═══ Array Fields ════════════════════════════════════════════

  Scenario: Fixed-size array
    Given a .schema file containing:
      """
      type Buffer {
          data: u8[256]
      }
      """
    When I run schemagen
    Then the output header should contain:
      """
      uint8_t data[256];
      """

  # ═══ Error Handling ══════════════════════════════════════════

  Scenario: Missing type name
    Given a .schema file containing:
      """
      type {
          x: i32
      }
      """
    When I run schemagen
    Then schemagen should exit with error code 1
    And stderr should contain "expected type name"

  Scenario: Unknown base type
    Given a .schema file containing:
      """
      type Foo {
          bar: unknown_type
      }
      """
    When I run schemagen
    Then schemagen should exit with error code 1
    And stderr should contain "unknown type: unknown_type"

  # ═══ Self-Hosting ════════════════════════════════════════════

  @self-hosting @critical
  Scenario: Schemagen processes its own schema
    Given schemagen.schema exists in specs/
    When I run bootstrap schemagen on schemagen.schema
    And I compile schemagen with SCHEMAGEN_SELF_HOST
    And I run self-hosted schemagen on schemagen.schema
    Then the output should match bootstrap output exactly
    And the self-hosted binary should produce identical output

  @self-hosting
  Scenario: Round-trip consistency
    Given schemagen.schema
    When I run schemagen to generate types
    And I compile schemagen with those types
    And I run the new schemagen on any .schema file
    Then the output should be deterministic
    And running twice produces identical output
