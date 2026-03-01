Feature: Lemon Parser Generator
  As a developer using cosmo-bde
  I want to use Lemon for LALR(1) parsing
  So that I can generate efficient parsers for all spec formats

  Background:
    Given Lemon is compiled from vendor/lemon/lemon.c
    And the Lemon binary is available at build/lemon

  # ═══ Basic Grammar Processing ════════════════════════════════

  Scenario: Process simple grammar
    Given a .grammar file containing:
      """
      %token_type { int }
      start ::= IDENT.
      """
    When I run lemon on the grammar
    Then it should generate a .c file
    And it should generate a .h file
    And the .h file should contain token definitions

  Scenario: Generate parser with semantic actions
    Given a .grammar file with semantic actions:
      """
      %include { #include "ast.h" }
      %token_type { Token }
      expr(A) ::= NUMBER(N). { A = make_num(N); }
      expr(A) ::= expr(L) PLUS expr(R). { A = make_add(L, R); }
      """
    When I run lemon on the grammar
    Then the generated .c should contain the semantic action code

  # ═══ Precedence and Associativity ════════════════════════════

  Scenario: Handle operator precedence
    Given a grammar with precedence declarations:
      """
      %left PLUS MINUS.
      %left TIMES DIVIDE.
      %right NOT.
      expr ::= expr PLUS expr.
      expr ::= expr TIMES expr.
      """
    When I run lemon on the grammar
    Then TIMES should have higher precedence than PLUS
    And there should be no shift/reduce conflicts

  Scenario: Report shift/reduce conflicts
    Given an ambiguous grammar:
      """
      stmt ::= IF expr stmt.
      stmt ::= IF expr stmt ELSE stmt.
      """
    When I run lemon on the grammar
    Then it should report a shift/reduce conflict

  # ═══ Error Recovery ══════════════════════════════════════════

  Scenario: Generate error recovery code
    Given a grammar with error productions:
      """
      %syntax_error { printf("Syntax error\\n"); }
      stmt_list ::= stmt_list stmt.
      stmt_list ::= stmt_list error stmt.
      """
    When I run lemon on the grammar
    Then the parser should recover from errors
    And continue parsing after error

  # ═══ Integration with Lexgen ═════════════════════════════════

  Scenario: Parser integrates with lexgen tokens
    Given a .lex file defining tokens
    And a .grammar file using those tokens
    When I run lexgen on the .lex file
    And I run lemon on the .grammar file
    Then the parser should accept tokens from the lexer
    And the token values should match

  @self-hosting
  Scenario: Lemon builds with cosmocc
    Given the Lemon source at vendor/lemon/lemon.c
    When I compile with cosmocc
    Then it should produce lemon.com
    And lemon.com should run on Linux
    And lemon.com should run on Windows
    And lemon.com should run on macOS

  # ═══ Generator Integration ═══════════════════════════════════

  @schemagen
  Scenario: Schemagen uses Lemon parser
    Given schemagen.grammar in specs/
    When I run lemon schemagen.grammar
    Then schemagen_parser.c is generated
    And schemagen can parse .schema files

  @defgen
  Scenario: Defgen uses Lemon parser
    Given def.grammar in specs/
    When I run lemon def.grammar
    Then def_parser.c is generated
    And defgen can parse .def files

  @bddgen
  Scenario: BDDgen uses Lemon parser
    Given feature.grammar in specs/
    When I run lemon feature.grammar
    Then feature_parser.c is generated
    And bddgen can parse .feature files

  # ═══ Template Customization ══════════════════════════════════

  Scenario: Use custom parser template
    Given a custom lempar.c template with tracing
    When I run lemon with -T custom_lempar.c
    Then the generated parser uses the custom template
    And trace output is available

  # ═══ Ring 0 Compliance ═══════════════════════════════════════

  @ring0
  Scenario: Lemon has no external dependencies
    Given the Lemon source
    Then it should only include standard C headers
    And it should compile with -ansi -pedantic
    And it should not require any external libraries

  @ring0
  Scenario: Generated parsers are Ring 0
    Given any .grammar file
    When I run lemon on it
    Then the generated code should be pure C
    And it should not require C++ features
    And it should compile with cosmocc
