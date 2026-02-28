#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════════
# new-spec.sh — Create a new specification file with boilerplate
# ═══════════════════════════════════════════════════════════════════════════
#
# Usage: ./scripts/new-spec.sh <layer> <name> <type>
#   layer: domain, behavior, interface, parsing, platform, persistence, presentation, testing
#   name:  snake_case name for the spec
#   type:  schema, def, sm, hsm, msm, lex, grammar, api, impl, sql, ui, feature, rules, ggo
#
# Example: ./scripts/new-spec.sh domain user_account schema
#          ./scripts/new-spec.sh behavior connection sm
# ═══════════════════════════════════════════════════════════════════════════

set -e

LAYER="$1"
NAME="$2"
TYPE="$3"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SPECS_DIR="$ROOT_DIR/specs"

usage() {
    echo "Usage: $0 <layer> <name> <type>"
    echo
    echo "Layers:"
    echo "  domain       Data models, constants, business rules"
    echo "  behavior     State machines (flat, hierarchical, modal)"
    echo "  interface    APIs, CLI options, protocols"
    echo "  parsing      Lexers, grammars"
    echo "  platform     Platform-specific implementations"
    echo "  persistence  Database schemas"
    echo "  presentation UI layouts"
    echo "  testing      BDD feature specs"
    echo
    echo "Types:"
    echo "  schema   Data types, structs, validation"
    echo "  def      Constants, enums, X-Macros"
    echo "  sm       Flat state machine"
    echo "  hsm      Hierarchical state machine"
    echo "  msm      Modal state machine"
    echo "  lex      Lexer tokens"
    echo "  grammar  Parser grammar (Lemon)"
    echo "  api      API contracts"
    echo "  impl     Platform hints"
    echo "  sql      Database schema"
    echo "  ui       UI layout"
    echo "  feature  BDD test scenarios"
    echo "  rules    Business rules (CLIPS)"
    echo "  ggo      CLI options (gengetopt)"
    exit 1
}

[ -z "$LAYER" ] || [ -z "$NAME" ] || [ -z "$TYPE" ] && usage

# Validate layer
case "$LAYER" in
    domain|behavior|interface|parsing|platform|persistence|presentation|testing) ;;
    *) echo "[ERROR] Invalid layer: $LAYER"; usage ;;
esac

# Validate type
case "$TYPE" in
    schema|def|sm|hsm|msm|lex|grammar|api|impl|sql|ui|feature|rules|ggo) ;;
    *) echo "[ERROR] Invalid type: $TYPE"; usage ;;
esac

SPEC_FILE="$SPECS_DIR/$LAYER/$NAME.$TYPE"

if [ -f "$SPEC_FILE" ]; then
    echo "[ERROR] File already exists: $SPEC_FILE"
    exit 1
fi

mkdir -p "$SPECS_DIR/$LAYER"

# Convert snake_case to Title Case
title_case() {
    echo "$1" | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1'
}

# Convert snake_case to PascalCase
pascal_case() {
    echo "$1" | sed 's/_\([a-z]\)/\U\1/g; s/^\([a-z]\)/\U\1/'
}

TITLE=$(title_case "$NAME")
PASCAL=$(pascal_case "$NAME")
UPPER=$(echo "$NAME" | tr '[:lower:]' '[:upper:]')

# Generate boilerplate based on type
case "$TYPE" in
    schema)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $TITLE SCHEMA
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe the purpose of this data type]
 *
 * Related Specs:
 *   - specs/behavior/xxx.sm
 *   - specs/interface/xxx.api
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

type $PASCAL {
    id: u64 [doc: "Unique identifier"]
    /* Add fields here */
}
EOF
        ;;

    def)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $TITLE DEFINITIONS
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe the constants/enums defined here]
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

enum ${UPPER}_TYPE [prefix: "${UPPER}_", xmacro: true] {
    NONE = 0    # Default/unset value
    /* Add values here */
}
EOF
        ;;

    sm)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $TITLE STATE MACHINE
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe the behavior this state machine models]
 *
 * Related Specs:
 *   - specs/domain/xxx.schema
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

machine $PASCAL {
    # Initial state
    initial: Idle

    state Idle {
        entry: on_idle_enter()
        on Start -> Running
    }

    state Running {
        entry: on_running_enter()
        on Stop -> Idle
    }
}
EOF
        ;;

    hsm)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $TITLE HIERARCHICAL STATE MACHINE
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe the hierarchical behavior]
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

machine $PASCAL {
    initial: Off

    state Off {
        on PowerOn -> On
    }

    state On {
        initial: Idle

        state Idle {
            on Start -> Active
        }

        state Active {
            on Stop -> Idle
        }

        on PowerOff -> Off
    }
}
EOF
        ;;

    lex)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $TITLE LEXER
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe the tokens this lexer recognizes]
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

lexer $PASCAL {
    /* Keywords */
    "keyword"       => KEYWORD

    /* Identifiers and literals */
    [a-zA-Z_][a-zA-Z0-9_]*  => IDENTIFIER
    [0-9]+                   => NUMBER
    \"[^\"]*\"               => STRING

    /* Operators */
    "="             => ASSIGN
    "=="            => EQ

    /* Skip whitespace */
    [ \t\n\r]+      => skip
}
EOF
        ;;

    grammar)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $TITLE GRAMMAR (Lemon)
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe what this parser parses]
 *
 * Paired with: specs/parsing/$NAME.lex
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

%include {
#include "${NAME}_parser.h"
}

%token_type { Token* }
%default_type { AstNode* }

%left PLUS MINUS.
%left TIMES DIVIDE.

program ::= statement_list.

statement_list ::= statement.
statement_list ::= statement_list statement.

statement ::= expression SEMICOLON.

expression ::= NUMBER.
expression ::= IDENTIFIER.
expression ::= expression PLUS expression.
expression ::= expression MINUS expression.
EOF
        ;;

    feature)
        cat > "$SPEC_FILE" << EOF
# ═══════════════════════════════════════════════════════════════════════
# $TITLE
# ═══════════════════════════════════════════════════════════════════════

Feature: $TITLE
  As a [role]
  I want [feature]
  So that [benefit]

  Background:
    Given [common setup]

  Scenario: Basic operation
    Given [initial condition]
    When [action]
    Then [expected result]

  Scenario: Error handling
    Given [initial condition]
    When [invalid action]
    Then [error is handled gracefully]
EOF
        ;;

    api)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $TITLE API
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe this API contract]
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

api $PASCAL {
    version: "1.0"
    base_path: "/api/v1/${NAME}"

    endpoint GET "/" {
        description: "List all items"
        response: ${PASCAL}[]
    }

    endpoint GET "/:id" {
        description: "Get item by ID"
        param id: u64
        response: $PASCAL
        error 404: "Not found"
    }

    endpoint POST "/" {
        description: "Create new item"
        body: ${PASCAL}Create
        response: $PASCAL
        error 400: "Invalid input"
    }
}
EOF
        ;;

    impl)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $TITLE IMPLEMENTATION HINTS
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe platform-specific implementation details]
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

impl $PASCAL {
    /* Memory allocation strategy */
    allocator: arena

    /* SIMD hints */
    simd: auto

    /* Platform-specific overrides */
    @linux {
        use_mmap: true
    }

    @windows {
        use_virtualalloc: true
    }

    @cosmo {
        portable: true
    }
}
EOF
        ;;

    rules)
        cat > "$SPEC_FILE" << EOF
; ═══════════════════════════════════════════════════════════════════════
; $TITLE BUSINESS RULES
; ═══════════════════════════════════════════════════════════════════════
;
; Purpose: [Describe the business rules]
;
; ═══════════════════════════════════════════════════════════════════════

(defrule ${NAME}-initial
    "Initial rule description"
    (initial-fact)
    =>
    (assert (${NAME}-ready)))

(defrule ${NAME}-process
    "Process description"
    (${NAME}-ready)
    (condition ?x)
    =>
    (assert (${NAME}-result ?x)))
EOF
        ;;

    ggo)
        cat > "$SPEC_FILE" << EOF
# ═══════════════════════════════════════════════════════════════════════
# $TITLE CLI OPTIONS (gengetopt)
# ═══════════════════════════════════════════════════════════════════════
#
# Purpose: [Describe the CLI interface]
#
# ═══════════════════════════════════════════════════════════════════════

package "$NAME"
version "1.0.0"
purpose "Description of the tool"

option "verbose" v "Enable verbose output" flag off
option "config"  c "Configuration file" string optional
option "output"  o "Output file" string default="-"
EOF
        ;;

    sql)
        cat > "$SPEC_FILE" << EOF
-- ═══════════════════════════════════════════════════════════════════════
-- $TITLE DATABASE SCHEMA
-- ═══════════════════════════════════════════════════════════════════════
--
-- Purpose: [Describe the database structure]
--
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS $NAME (
    id INTEGER PRIMARY KEY,
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_${NAME}_created ON $NAME(created_at);
EOF
        ;;

    ui)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $TITLE UI LAYOUT
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe this UI component]
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

ui $PASCAL {
    layout: vertical

    panel "Main" {
        label "Title"
        button "Action" => on_action_click
    }
}
EOF
        ;;

    *)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $TITLE
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe the purpose]
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

/* Add content here */
EOF
        ;;
esac

echo "[OK]    Created: $SPEC_FILE"
echo "        Layer:   $LAYER"
echo "        Type:    $TYPE"
echo
echo "Next steps:"
echo "  1. Edit $SPEC_FILE"
echo "  2. Run: make regen"
echo "  3. Check: git diff gen/"
