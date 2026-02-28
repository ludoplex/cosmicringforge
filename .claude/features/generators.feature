@generators
Feature: Code Generation from Specifications
  As a systems engineer
  I write specifications (not code)
  So that generators produce all source code

  Background:
    Given the mbse-stacks framework is configured
    And the build profile is set

  # ══════════════════════════════════════════════════════════════
  # SCHEMA GENERATOR (Ring 0)
  # ══════════════════════════════════════════════════════════════

  @ring0 @schemagen
  Scenario: Generate C types from schema specification
    Given a schema specification "types.schema":
      """
      type Point {
          x: i32
          y: i32
      }

      type Rectangle {
          origin: Point
          width: u32
          height: u32
      }
      """
    When I run schemagen on "types.schema"
    Then it generates "gen/schemagen/types.h" containing:
      | content                          |
      | typedef struct Point             |
      | int32_t x;                       |
      | int32_t y;                       |
      | typedef struct Rectangle         |
    And it generates "gen/schemagen/types.c" with serialization functions
    And no hand-written code is required

  @ring0 @schemagen
  Scenario: Generate validators from schema constraints
    Given a schema specification with constraints:
      """
      type Config {
          port: u16 [range: 1024..65535]
          name: string[64] [not_empty]
          timeout_ms: u32 [default: 5000]
      }
      """
    When I run schemagen
    Then it generates validator functions:
      | function                          |
      | bool Config_validate(Config* c)   |
      | bool Config_port_valid(uint16_t)  |
      | bool Config_name_valid(char*)     |
    And default initialization function is generated

  @ring0 @schemagen
  Scenario: Generate JSON serialization
    Given a schema with serialization directive:
      """
      @json
      type Message {
          id: u64
          payload: string[256]
          timestamp: i64
      }
      """
    When I run schemagen
    Then it generates JSON functions:
      | function                              |
      | int Message_to_json(Message*, char*)  |
      | int Message_from_json(char*, Message*)|
    And uses yyjson for parsing

  # ══════════════════════════════════════════════════════════════
  # STATE MACHINE GENERATOR (Ring 0 simple, Ring 2 full)
  # ══════════════════════════════════════════════════════════════

  @ring0 @statemachine
  Scenario: Generate flat state machine from spec
    Given a state machine specification "controller.sm":
      """
      machine Controller {
          initial: Idle

          state Idle {
              on Start -> Running
              entry: idle_enter()
              exit: idle_exit()
          }

          state Running {
              on Stop -> Idle
              on Error -> Failed
          }

          state Failed {
              on Reset -> Idle
          }
      }
      """
    When I run smgen on "controller.sm"
    Then it generates state transition table
    And it generates event dispatch function
    And entry/exit actions are called automatically
    And I write zero C code for the state machine

  @ring2 @statesmith
  Scenario: Generate hierarchical state machine with StateSmith
    Given a StateSmith diagram "complex.drawio"
    And the diagram has nested states and history
    When I run StateSmith generator
    Then it produces Ring-0 compatible C code in "gen/statesmith/"
    And the generated code has zero runtime dependencies
    And GENERATOR_VERSION stamp is created
    And SHA256SUMS is created for drift detection

  # ══════════════════════════════════════════════════════════════
  # UI GENERATOR (Ring 0)
  # ══════════════════════════════════════════════════════════════

  @ring0 @uigen
  Scenario: Generate Nuklear UI from specification
    Given a UI specification "main.ui":
      """
      window Main {
          title: "Application"
          width: 800
          height: 600

          panel Controls {
              layout: horizontal

              button Start {
                  on_click: start_handler
              }

              button Stop {
                  on_click: stop_handler
              }

              slider Speed {
                  min: 0
                  max: 100
                  bind: config.speed
              }
          }

          panel Status {
              label StateDisplay {
                  bind: machine.current_state
              }
          }
      }
      """
    When I run uigen on "main.ui"
    Then it generates Nuklear UI code
    And data bindings are generated
    And I only implement handler functions

  # ══════════════════════════════════════════════════════════════
  # LEXER GENERATOR (Ring 0)
  # ══════════════════════════════════════════════════════════════

  @ring0 @lexgen
  Scenario: Generate lexer from token definitions
    Given a token specification "tokens.lex":
      """
      KEYWORD_IF      "if"
      KEYWORD_ELSE    "else"
      KEYWORD_WHILE   "while"
      IDENT           [a-zA-Z_][a-zA-Z0-9_]*
      NUMBER          [0-9]+
      STRING          \"[^\"]*\"
      WHITESPACE      [ \t\n]+  @skip
      """
    When I run lexgen on "tokens.lex"
    Then it generates table-driven lexer
    And the lexer requires no hand-written tokenization code

  # ══════════════════════════════════════════════════════════════
  # PARSER GENERATOR (Ring 0 - Lemon)
  # ══════════════════════════════════════════════════════════════

  @ring0 @lemon
  Scenario: Generate parser from grammar
    Given a Lemon grammar "parser.y":
      """
      %include { #include "ast.h" }
      %token_type { Token }

      program ::= statement_list.
      statement_list ::= statement.
      statement_list ::= statement_list statement.
      statement ::= IF expr THEN statement_list END.
      """
    When I run Lemon on "parser.y"
    Then it generates LALR(1) parser
    And the parser integrates with generated lexer
    And AST construction is table-driven

  # ══════════════════════════════════════════════════════════════
  # BINARY EMBEDDING (Ring 0)
  # ══════════════════════════════════════════════════════════════

  @ring0 @bin2c
  Scenario: Embed binary resources as C arrays
    Given binary files to embed:
      | file              | symbol         |
      | assets/logo.png   | logo_png       |
      | assets/font.ttf   | default_font   |
      | templates/base.tpl| base_template  |
    When I run bin2c
    Then it generates "gen/bin2c/resources.h":
      """
      extern const unsigned char logo_png[];
      extern const size_t logo_png_size;
      """
    And generates "gen/bin2c/resources.c" with data arrays
    And I write zero code to embed resources

  # ══════════════════════════════════════════════════════════════
  # RULES ENGINE (Ring 0 - CLIPS)
  # ══════════════════════════════════════════════════════════════

  @ring0 @clips
  Scenario: Generate rules from CLIPS specification
    Given a CLIPS rules file "validation.clips":
      """
      (defrule check-port-range
          (config (port ?p))
          (test (or (< ?p 1024) (> ?p 65535)))
          =>
          (assert (error "Port out of range")))

      (defrule check-timeout
          (config (timeout ?t))
          (test (> ?t 30000))
          =>
          (assert (warning "Timeout exceeds 30 seconds")))
      """
    When I load rules into CLIPS engine
    Then validation happens declaratively
    And I write rules, not validation code

  # ══════════════════════════════════════════════════════════════
  # FULL APPLICATION GENERATION
  # ══════════════════════════════════════════════════════════════

  @integration
  Scenario: Generate complete application from specs
    Given specification files:
      | spec                | type      |
      | specs/types.schema  | data      |
      | specs/app.sm        | behavior  |
      | specs/main.ui       | interface |
    When I run "make regen"
    Then all generators execute in dependency order
    And gen/ directory contains all generated code
    And src/ contains only glue code and handlers
    And generated code is >80% of total codebase

  @integration
  Scenario: Regenerate after spec change
    Given a working application
    When I modify "specs/types.schema"
    And run "make regen"
    Then only affected generators run
    And dependent code is regenerated
    And "git diff" shows the changes
    And I commit regenerated code
