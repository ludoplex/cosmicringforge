# CosmicRingForge Unified Workflow

> **Behavior Driven Engineering with Models** — BDE with Models.
>
> Framework for the design and development of any application.

This document defines the **canonical workflow** with automation scripts and universal conventions that work for humans and LLMs alike.

---

## One Output, Many Authoring Tools

**All paths lead to C.** Every Ring 2 tool—FOSS or commercial—generates C source code that compiles with `cosmocc` to produce APE binaries. The distinction isn't "portable vs commercial output"—it's **what authoring tools are available**.

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTHORING TOOLS (Ring 2)                     │
│                                                                 │
│   FOSS                          COMMERCIAL                      │
│   ────                          ──────────                      │
│   StateSmith (.NET)             Rhapsody (IBM)                  │
│   EEZ Studio (Node.js)          Simulink (MATLAB)               │
│   protobuf-c (C++)              Qt Design Studio                │
│   OpenModelica (C++)            RTI Connext DDS                 │
│   flatcc (C)                                                    │
│   Binaryen (C++)                                                │
│                                                                 │
│                         ▼ all generate ▼                        │
│                                                                 │
│              ┌─────────────────────────────┐                    │
│              │     C SOURCE CODE           │                    │
│              │   (zero dependencies)       │                    │
│              └─────────────────────────────┘                    │
│                              │                                  │
│                              ▼                                  │
│              ┌─────────────────────────────┐                    │
│              │   cosmocc / any C compiler  │                    │
│              └─────────────────────────────┘                    │
│                              │                                  │
│                              ▼                                  │
│              ┌─────────────────────────────┐                    │
│              │   APE binary (runs everywhere) │                 │
│              └─────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
```

**The regen script auto-detects available tools.** No profile flag needed—if you have Rhapsody installed, it uses it. If not, it skips it. Ring 2 outputs are committed, so builds always succeed with just C+sh.

| Distinction | FOSS Tools | Commercial Tools |
|-------------|------------|------------------|
| **License** | Free | $10K-$100K+/seat |
| **Certification** | None | DO-178C, ISO 26262 |
| **Traceability** | Manual | Automated |
| **Output** | C code | C code |
| **APE compatible** | Yes | Yes |

---

## File Extension Registry

### Ring 0: Pure C+sh (Always Available)

| Extension | Generator | Purpose | Input Format |
|-----------|-----------|---------|--------------|
| `.schema` | schemagen | Data types, structs | X-Macro DSL |
| `.def` | defgen | Constants, enums, X-Macros | X-Macro DSL |
| `.impl` | implgen | Platform hints, SIMD | Directive DSL |
| `.sm` | smgen | Flat state machines | State DSL |
| `.hsm` | hsmgen | Hierarchical state machines | Nested State DSL |
| `.msm` | msmgen | Modal state machines | Mode DSL |
| `.lex` | lexgen | Lexer tokens | Token DSL |
| `.grammar` | Lemon | Parser grammars | BNF-like |
| `.feature` | bddgen | BDD test scenarios | Gherkin |
| `.rules` | clipsgen | Business rules | CLIPS-like |
| `.api` | apigen | API contracts | Endpoint DSL |
| `.sig` | siggen | FFI signatures | Signature DSL |
| `.sql` | sqlgen | Database schema | SQL subset |
| `.ui` | uigen | UI layouts | Layout DSL |
| `.ggo` | gengetopt | CLI options | GGO format |

### Ring 2: Visual Authoring Tools (Auto-Detected)

These tools require external toolchains but generate **zero-dependency C code**.
The regen script auto-detects which tools are available and uses them.

| Extension | Generator | Toolchain | Output |
|-----------|-----------|-----------|--------|
| `.proto` | protobuf-c | C++ (protoc) | Pure C serialization |
| `.fbs` | flatcc | C | Zero-copy C structs |
| `.drawio` | StateSmith | .NET | Dependency-free C FSM |
| `.plantuml` | StateSmith | .NET | Dependency-free C FSM |
| `.mo` | OpenModelica | C++/OCaml | Pure C simulation |
| `.eez-project` | EEZ Studio | Node.js | Embedded C/C++ GUI |
| `.wasm` | Binaryen | C++ | Optimized WASM |
| `.slx/.mdl` | Embedded Coder | MATLAB | DO-178C certifiable C |
| `.emx/.sbs` | Rhapsody | IBM | ASPICE/ISO 26262 C |
| `.qml` | Qt Design Studio | Qt | C++ (needs Qt runtime) |
| `.idl/.xml` | rtiddsgen | RTI DDS | C type support |

**Note:** Qt and DDS may require runtime libraries. All others generate standalone C.

---

## The Canonical Directory Structure

```
cosmicringforge/
├── specs/                      # ══ SOURCE OF TRUTH ══
│   ├── domain/                 # Business domain models
│   │   ├── entities.schema     # Core data types
│   │   ├── constants.def       # Enums, flags, config
│   │   └── rules.rules         # Business rules
│   ├── behavior/               # State and control flow
│   │   ├── main.sm             # Primary state machine
│   │   ├── subsystem.hsm       # Hierarchical FSM
│   │   └── modes.msm           # Mode switching
│   ├── interface/              # External interfaces
│   │   ├── api.api             # REST/RPC contracts
│   │   ├── cli.ggo             # Command-line options
│   │   └── protocol.proto      # Wire protocol (Ring 2)
│   ├── parsing/                # Language processing
│   │   ├── tokens.lex          # Lexer specification
│   │   └── grammar.grammar     # Parser grammar
│   ├── platform/               # Platform-specific
│   │   ├── linux.impl          # Linux optimizations
│   │   ├── windows.impl        # Windows adaptations
│   │   └── cosmo.impl          # Cosmopolitan specifics
│   ├── persistence/            # Data storage
│   │   └── schema.sql          # Database schema
│   ├── presentation/           # User interface
│   │   ├── main.ui             # UI layout (Ring 0)
│   │   └── dashboard.eez-project # Visual UI (Ring 2)
│   └── testing/                # Test specifications
│       ├── unit.feature        # Unit test scenarios
│       ├── integration.feature # Integration tests
│       └── acceptance.feature  # Acceptance criteria
│
├── model/                      # ══ RING 2 VISUAL SOURCES ══
│   ├── statesmith/             # StateSmith diagrams
│   │   └── *.drawio
│   ├── simulink/               # MATLAB models (commercial)
│   │   └── *.slx
│   ├── rhapsody/               # IBM Rhapsody (commercial)
│   │   └── *.emx
│   └── openmodelica/           # Physics models
│       └── *.mo
│
├── gen/                        # ══ GENERATED CODE ══
│   ├── domain/                 # From specs/domain/
│   ├── behavior/               # From specs/behavior/
│   ├── interface/              # From specs/interface/
│   ├── parsing/                # From specs/parsing/
│   ├── platform/               # From specs/platform/
│   ├── persistence/            # From specs/persistence/
│   ├── presentation/           # From specs/presentation/
│   ├── testing/                # From specs/testing/
│   └── imported/               # From model/ (Ring 2)
│       ├── statesmith/
│       ├── protobuf/
│       ├── flatbuf/
│       ├── modelica/
│       ├── simulink/           # commercial only
│       └── rhapsody/           # commercial only
│
├── src/                        # ══ HANDWRITTEN CODE ══
│   ├── main.c                  # Entry point
│   ├── glue/                   # Integration code
│   └── platform/               # Platform-specific impl
│
├── vendor/                     # ══ VENDORED LIBRARIES ══
│   ├── sqlite/
│   ├── nuklear/
│   ├── sokol/
│   ├── yyjson/
│   ├── clips/
│   └── civetweb/
│
├── tools/                      # ══ RING 0 GENERATORS ══
│   ├── schemagen.c
│   ├── defgen.c
│   ├── implgen.c
│   ├── smgen.c
│   ├── hsmgen.c
│   ├── msmgen.c
│   ├── lexgen.c
│   ├── bddgen.c
│   ├── clipsgen.c
│   ├── apigen.c
│   ├── siggen.c
│   ├── sqlgen.c
│   ├── uigen.c
│   ├── lemon.c
│   └── lempar.c
│
├── scripts/                    # ══ AUTOMATION ══
│   ├── regen.sh                # Master regeneration
│   ├── verify.sh               # Drift verification
│   ├── new-spec.sh             # Create new spec file
│   └── release.sh              # Build release
│
├── Makefile                    # Build orchestration
├── WORKFLOW.md                 # This document
├── CONVENTIONS.md              # Coding standards
└── STACKS_REFERENCE.md         # Complete tool reference
```

---

## The Workflow Pipeline

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        SPECIFICATION PHASE                               │
│                                                                          │
│   Human/LLM edits specs/*.{schema,def,sm,lex,grammar,feature,...}       │
│                              │                                           │
│                              ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                    VALIDATION GATE                               │   │
│   │   • All required fields documented                               │   │
│   │   • Syntax valid                                                 │   │
│   │   • No circular dependencies                                     │   │
│   │   • Naming conventions followed                                  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                              │                                           │
│                              ▼                                           │
├─────────────────────────────────────────────────────────────────────────┤
│                        GENERATION PHASE                                  │
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │   RING 0 GENERATORS (Always run - Pure C+sh)                     │   │
│   │                                                                  │   │
│   │   specs/domain/*.schema  ──► schemagen ──► gen/domain/*_types.c │   │
│   │   specs/domain/*.def     ──► defgen    ──► gen/domain/*_defs.c  │   │
│   │   specs/behavior/*.sm    ──► smgen     ──► gen/behavior/*_fsm.c │   │
│   │   specs/parsing/*.lex    ──► lexgen    ──► gen/parsing/*_lex.c  │   │
│   │   specs/parsing/*.grammar──► lemon     ──► gen/parsing/*_parse.c│   │
│   │   specs/testing/*.feature──► bddgen    ──► gen/testing/*_test.c │   │
│   │   specs/interface/*.ggo  ──► gengetopt ──► gen/interface/cli.c  │   │
│   │   specs/platform/*.impl  ──► implgen   ──► gen/platform/*.c     │   │
│   │   specs/persistence/*.sql──► sqlgen    ──► gen/persistence/*.c  │   │
│   │   specs/presentation/*.ui──► uigen     ──► gen/presentation/*.c │   │
│   │   specs/domain/*.rules   ──► clipsgen  ──► gen/domain/*_rules.c │   │
│   │   specs/interface/*.api  ──► apigen    ──► gen/interface/*_api.c│   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                              │                                           │
│                              ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │   RING 2 IMPORTS (Auto-detected based on tool availability)     │   │
│   │                                                                  │   │
│   │   model/statesmith/*.drawio ──► StateSmith ──► gen/imported/sm/ │   │
│   │   specs/interface/*.proto   ──► protoc-c   ──► gen/imported/pb/ │   │
│   │   specs/interface/*.fbs     ──► flatcc     ──► gen/imported/fb/ │   │
│   │   model/openmodelica/*.mo   ──► omc        ──► gen/imported/sim/│   │
│   │   specs/presentation/*.eez  ──► EEZ Studio ──► gen/imported/eez/│   │
│   │   model/simulink/*.slx      ──► Embedded   ──► gen/imported/ec/ │   │
│   │   model/rhapsody/*.emx      ──► Rhapsody   ──► gen/imported/rh/ │   │
│   │                                                                  │   │
│   │   (Tools not installed are skipped; outputs already committed)  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                              │                                           │
│                              ▼                                           │
├─────────────────────────────────────────────────────────────────────────┤
│                        VERIFICATION PHASE                                │
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │   DRIFT GATE                                                     │   │
│   │   git diff --exit-code gen/ docs/                                │   │
│   │   • Generated code matches committed                             │   │
│   │   • Ring 2 outputs committed (can't assume tools available)     │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                              │                                           │
│                              ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │   BDD TEST GATE                                                  │   │
│   │   ./build/bddgen --run specs/testing/*.feature                   │   │
│   │   • All scenarios pass                                           │   │
│   │   • Coverage meets threshold                                     │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                              │                                           │
│                              ▼                                           │
├─────────────────────────────────────────────────────────────────────────┤
│                        COMPILATION PHASE                                 │
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │   cosmocc -o app.com src/*.c gen/**/*.c vendor/**/*.c           │   │
│   │                                                                  │   │
│   │   Output: Single APE binary                                      │   │
│   │   Runs on: Linux, macOS, Windows, FreeBSD, OpenBSD, NetBSD      │   │
│   │   Architectures: AMD64, ARM64                                    │   │
│   │                                                                  │   │
│   │   Note: Qt/DDS may need native runtime—but generated C is still │   │
│   │   compiled with cosmocc. Only runtime linking differs.          │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                              │                                           │
│                              ▼                                           │
│                         SHIP IT                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Universal Conventions

### File Naming

```
# Spec files: lowercase, underscores, descriptive
specs/domain/user_account.schema
specs/behavior/connection_manager.sm
specs/interface/rest_api.api

# Generated files: match spec name + suffix
gen/domain/user_account_types.h
gen/domain/user_account_types.c
gen/behavior/connection_manager_fsm.h
gen/behavior/connection_manager_fsm.c

# Always include generator stamp
/* AUTO-GENERATED by schemagen 1.0.0 — DO NOT EDIT */
/* Source: specs/domain/user_account.schema */
/* Generated: 2026-02-28T12:34:56Z */
```

### Documentation Requirements

Every spec element MUST have documentation:

```c
/* .schema example - doc strings required */
type UserAccount {
    id: u64 [doc: "Unique identifier, auto-generated"]
    email: string[256] [doc: "Primary contact email", not_empty]
    created_at: i64 [doc: "Unix timestamp of account creation"]
}

/* .def example - inline comments required */
enum UserRole {
    GUEST = 0       # Unauthenticated visitor
    USER = 1        # Registered user
    ADMIN = 2       # System administrator
    SUPER = 3       # Super admin (can modify admins)
}

/* .sm example - state/transition docs required */
machine ConnectionManager {
    # Initial state: system is offline
    initial: Disconnected

    state Disconnected {
        # Entry: cleanup any stale connections
        entry: cleanup_connections()

        # Connect event initiates handshake
        on Connect -> Connecting
    }
}
```

### Literate Documentation Format

All spec files support literate blocks:

```c
/* ═══════════════════════════════════════════════════════════════════════
 * USER ACCOUNT DOMAIN MODEL
 * ═══════════════════════════════════════════════════════════════════════
 *
 * This schema defines the core user account entity used throughout the
 * system. It is the source of truth for:
 *
 *   - Database table structure (via sqlgen)
 *   - JSON serialization (via schemagen --json)
 *   - Admin UI forms (via uigen)
 *   - Validation rules (via schemagen --validate)
 *
 * ## Design Decisions
 *
 * 1. Email is the primary identifier, not username
 *    - Rationale: Reduces "forgot username" support tickets
 *    - Trade-off: Email changes require re-verification
 *
 * 2. Timestamps are Unix seconds, not milliseconds
 *    - Rationale: SQLite INTEGER affinity, smaller storage
 *    - Trade-off: Millisecond precision not available
 *
 * ## Related Specs
 *
 * - specs/behavior/auth.sm - Authentication state machine
 * - specs/interface/user_api.api - User REST endpoints
 * - specs/domain/permissions.def - Role definitions
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

type UserAccount {
    /* Primary key, auto-assigned by database */
    id: u64 [doc: "Unique identifier"]

    /* ... */
}
```

### X-Macro Conventions

All `.def` files generate X-Macro tables for maximum flexibility:

```c
/* Input: specs/domain/log_level.def */
enum LogLevel [prefix: "LOG_", xmacro: true] {
    TRACE = 0   # Most verbose, development only
    DEBUG = 1   # Debug information
    INFO = 2    # Normal operation
    WARN = 3    # Warning conditions
    ERROR = 4   # Error conditions
    FATAL = 5   # Fatal, will terminate
}

/* Output: gen/domain/log_level_defs.h */
#define LOGLEVEL_XMACRO(X) \
    X(LOG_TRACE, 0, "TRACE", "Most verbose, development only") \
    X(LOG_DEBUG, 1, "DEBUG", "Debug information") \
    X(LOG_INFO,  2, "INFO",  "Normal operation") \
    X(LOG_WARN,  3, "WARN",  "Warning conditions") \
    X(LOG_ERROR, 4, "ERROR", "Error conditions") \
    X(LOG_FATAL, 5, "FATAL", "Fatal, will terminate")

/* Usage examples */
// Enum definition
typedef enum {
#define X(name, val, str, doc) name = val,
    LOGLEVEL_XMACRO(X)
#undef X
} LogLevel;

// String lookup
const char* LogLevel_to_string(LogLevel l) {
    switch(l) {
#define X(name, val, str, doc) case name: return str;
        LOGLEVEL_XMACRO(X)
#undef X
    }
    return "UNKNOWN";
}

// Documentation array
static const char* LogLevel_docs[] = {
#define X(name, val, str, doc) [val] = doc,
    LOGLEVEL_XMACRO(X)
#undef X
};
```

---

## Automation Scripts

### scripts/regen.sh — Master Regeneration

```sh
#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# regen.sh — Regenerate all code from specifications
# ═══════════════════════════════════════════════════════════════════════
#
# Usage: ./scripts/regen.sh [--verify]
#   --verify: Also check for drift after regeneration
#
# This script is the SINGLE POINT OF TRUTH for code generation order.
# Ring 2 tools are auto-detected—available tools are used, missing are skipped.
# Ring 2 outputs are committed, so builds always succeed with just C+sh.
#
# Exit codes:
#   0 - Success
#   1 - Generator failed
#   2 - Drift detected (with --verify)
# ═══════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build"
GEN_DIR="$ROOT_DIR/gen"
SPECS_DIR="$ROOT_DIR/specs"
TOOLS_DIR="$ROOT_DIR/tools"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()  { printf "${BLUE}[INFO]${NC}  %s\n" "$1"; }
log_ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$1"; }
log_warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$1"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

# ═══ Phase 0: Build Ring 0 Tools ═══════════════════════════════════════
build_tools() {
    log_info "Building Ring 0 generators..."

    mkdir -p "$BUILD_DIR"

    # Bootstrap: build schemagen first (it's self-hosting)
    if [ ! -f "$BUILD_DIR/schemagen" ]; then
        log_info "  Bootstrapping schemagen..."
        ${CC:-cc} -o "$BUILD_DIR/schemagen-bootstrap" "$TOOLS_DIR/schemagen.c"
        "$BUILD_DIR/schemagen-bootstrap" "$SPECS_DIR/schemagen.schema" \
            -o "$GEN_DIR/schemagen/"
        ${CC:-cc} -DSCHEMAGEN_SELF_HOST \
            -I"$GEN_DIR/schemagen" \
            -o "$BUILD_DIR/schemagen" \
            "$TOOLS_DIR/schemagen.c" \
            "$GEN_DIR/schemagen/schemagen_types.c"
    fi

    # Build remaining generators
    for gen in defgen implgen smgen hsmgen msmgen lexgen bddgen \
               clipsgen apigen siggen sqlgen uigen; do
        if [ -f "$TOOLS_DIR/${gen}.c" ]; then
            if [ ! -f "$BUILD_DIR/$gen" ] || \
               [ "$TOOLS_DIR/${gen}.c" -nt "$BUILD_DIR/$gen" ]; then
                log_info "  Building $gen..."

                # Generate types for this generator if spec exists
                if [ -f "$SPECS_DIR/${gen}.schema" ]; then
                    "$BUILD_DIR/schemagen" "$SPECS_DIR/${gen}.schema" \
                        -o "$GEN_DIR/$gen/"
                fi

                ${CC:-cc} -I"$GEN_DIR/$gen" -o "$BUILD_DIR/$gen" \
                    "$TOOLS_DIR/${gen}.c" \
                    "$GEN_DIR/$gen/${gen}_types.c" 2>/dev/null || \
                ${CC:-cc} -o "$BUILD_DIR/$gen" "$TOOLS_DIR/${gen}.c"
            fi
        fi
    done

    # Build Lemon
    if [ ! -f "$BUILD_DIR/lemon" ]; then
        log_info "  Building lemon..."
        ${CC:-cc} -o "$BUILD_DIR/lemon" "$TOOLS_DIR/lemon.c"
    fi

    log_ok "Ring 0 generators ready"
}

# ═══ Phase 1: Generate from Ring 0 Specs ════════════════════════════════
generate_ring0() {
    log_info "Generating from Ring 0 specs..."

    # Domain layer
    for spec in "$SPECS_DIR"/domain/*.schema; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .schema)
        log_info "  schemagen: $name.schema"
        "$BUILD_DIR/schemagen" "$spec" -o "$GEN_DIR/domain/"
    done

    for spec in "$SPECS_DIR"/domain/*.def; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .def)
        log_info "  defgen: $name.def"
        "$BUILD_DIR/defgen" "$spec" -o "$GEN_DIR/domain/" 2>/dev/null || \
            log_warn "  defgen not ready, skipping $name.def"
    done

    for spec in "$SPECS_DIR"/domain/*.rules; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .rules)
        log_info "  clipsgen: $name.rules"
        "$BUILD_DIR/clipsgen" "$spec" -o "$GEN_DIR/domain/" 2>/dev/null || \
            log_warn "  clipsgen not ready, skipping $name.rules"
    done

    # Behavior layer
    for spec in "$SPECS_DIR"/behavior/*.sm; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .sm)
        log_info "  smgen: $name.sm"
        "$BUILD_DIR/smgen" "$spec" -o "$GEN_DIR/behavior/" 2>/dev/null || \
            log_warn "  smgen not ready, skipping $name.sm"
    done

    for spec in "$SPECS_DIR"/behavior/*.hsm; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .hsm)
        log_info "  hsmgen: $name.hsm"
        "$BUILD_DIR/hsmgen" "$spec" -o "$GEN_DIR/behavior/" 2>/dev/null || \
            log_warn "  hsmgen not ready, skipping $name.hsm"
    done

    for spec in "$SPECS_DIR"/behavior/*.msm; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .msm)
        log_info "  msmgen: $name.msm"
        "$BUILD_DIR/msmgen" "$spec" -o "$GEN_DIR/behavior/" 2>/dev/null || \
            log_warn "  msmgen not ready, skipping $name.msm"
    done

    # Parsing layer
    for spec in "$SPECS_DIR"/parsing/*.lex; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .lex)
        log_info "  lexgen: $name.lex"
        "$BUILD_DIR/lexgen" "$spec" -o "$GEN_DIR/parsing/" 2>/dev/null || \
            log_warn "  lexgen not ready, skipping $name.lex"
    done

    for spec in "$SPECS_DIR"/parsing/*.grammar; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .grammar)
        log_info "  lemon: $name.grammar"
        "$BUILD_DIR/lemon" "$spec"
        mv "${spec%.grammar}.c" "$GEN_DIR/parsing/${name}_parser.c" 2>/dev/null || true
        mv "${spec%.grammar}.h" "$GEN_DIR/parsing/${name}_parser.h" 2>/dev/null || true
    done

    # Interface layer
    for spec in "$SPECS_DIR"/interface/*.ggo; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .ggo)
        log_info "  gengetopt: $name.ggo"
        gengetopt < "$spec" --output-dir="$GEN_DIR/interface/" 2>/dev/null || \
            log_warn "  gengetopt not available, skipping $name.ggo"
    done

    for spec in "$SPECS_DIR"/interface/*.api; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .api)
        log_info "  apigen: $name.api"
        "$BUILD_DIR/apigen" "$spec" -o "$GEN_DIR/interface/" 2>/dev/null || \
            log_warn "  apigen not ready, skipping $name.api"
    done

    # Platform layer
    for spec in "$SPECS_DIR"/platform/*.impl; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .impl)
        log_info "  implgen: $name.impl"
        "$BUILD_DIR/implgen" "$spec" -o "$GEN_DIR/platform/" 2>/dev/null || \
            log_warn "  implgen not ready, skipping $name.impl"
    done

    # Persistence layer
    for spec in "$SPECS_DIR"/persistence/*.sql; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .sql)
        log_info "  sqlgen: $name.sql"
        "$BUILD_DIR/sqlgen" "$spec" -o "$GEN_DIR/persistence/" 2>/dev/null || \
            log_warn "  sqlgen not ready, skipping $name.sql"
    done

    # Presentation layer
    for spec in "$SPECS_DIR"/presentation/*.ui; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .ui)
        log_info "  uigen: $name.ui"
        "$BUILD_DIR/uigen" "$spec" -o "$GEN_DIR/presentation/" 2>/dev/null || \
            log_warn "  uigen not ready, skipping $name.ui"
    done

    # Testing layer
    for spec in "$SPECS_DIR"/testing/*.feature; do
        [ -f "$spec" ] || continue
        name=$(basename "$spec" .feature)
        log_info "  bddgen: $name.feature"
        "$BUILD_DIR/bddgen" "$spec" -o "$GEN_DIR/testing/" 2>/dev/null || \
            log_warn "  bddgen not ready, skipping $name.feature"
    done

    log_ok "Ring 0 generation complete"
}

# ═══ Phase 2: Import Ring 2 FOSS (Portable Profile) ══════════════════════
import_foss() {
    log_info "Importing Ring 2 FOSS artifacts (if tools available)..."

    mkdir -p "$GEN_DIR/imported"

    # StateSmith
    if command -v dotnet >/dev/null 2>&1; then
        for diagram in "$ROOT_DIR"/model/statesmith/*.drawio; do
            [ -f "$diagram" ] || continue
            name=$(basename "$diagram" .drawio)
            log_info "  StateSmith: $name.drawio"
            dotnet StateSmith.Cli run "$diagram" \
                --lang=C99 \
                -o "$GEN_DIR/imported/statesmith/" 2>/dev/null || \
                log_warn "  StateSmith failed for $name.drawio"
        done
    else
        log_warn "  StateSmith (.NET) not available"
    fi

    # protobuf-c
    if command -v protoc >/dev/null 2>&1; then
        for proto in "$SPECS_DIR"/interface/*.proto; do
            [ -f "$proto" ] || continue
            name=$(basename "$proto" .proto)
            log_info "  protobuf-c: $name.proto"
            protoc --c_out="$GEN_DIR/imported/protobuf/" "$proto" 2>/dev/null || \
                log_warn "  protobuf-c failed for $name.proto"
        done
    else
        log_warn "  protobuf-c (protoc) not available"
    fi

    # flatcc
    if command -v flatcc >/dev/null 2>&1; then
        for fbs in "$SPECS_DIR"/interface/*.fbs; do
            [ -f "$fbs" ] || continue
            name=$(basename "$fbs" .fbs)
            log_info "  flatcc: $name.fbs"
            flatcc -a -o "$GEN_DIR/imported/flatbuf/" "$fbs" 2>/dev/null || \
                log_warn "  flatcc failed for $name.fbs"
        done
    else
        log_warn "  flatcc not available"
    fi

    # EEZ Studio
    if command -v eez-studio >/dev/null 2>&1; then
        for eez in "$SPECS_DIR"/presentation/*.eez-project; do
            [ -f "$eez" ] || continue
            name=$(basename "$eez" .eez-project)
            log_info "  EEZ Studio: $name.eez-project"
            eez-studio build "$eez" \
                --output-dir="$GEN_DIR/imported/eez/" 2>/dev/null || \
                log_warn "  EEZ Studio failed for $name.eez-project"
        done
    else
        log_warn "  EEZ Studio (Node.js) not available"
    fi

    # OpenModelica
    if command -v omc >/dev/null 2>&1; then
        for mo in "$ROOT_DIR"/model/openmodelica/*.mo; do
            [ -f "$mo" ] || continue
            name=$(basename "$mo" .mo)
            log_info "  OpenModelica: $name.mo"
            omc "$mo" +s +d=initialization \
                --output="$GEN_DIR/imported/modelica/" 2>/dev/null || \
                log_warn "  OpenModelica failed for $name.mo"
        done
    else
        log_warn "  OpenModelica (omc) not available"
    fi

    # Binaryen (wasm-opt)
    if command -v wasm-opt >/dev/null 2>&1; then
        for wasm in "$ROOT_DIR"/model/wasm/*.wasm; do
            [ -f "$wasm" ] || continue
            name=$(basename "$wasm" .wasm)
            log_info "  Binaryen: $name.wasm"
            wasm-opt -O3 "$wasm" \
                -o "$GEN_DIR/imported/wasm/${name}.opt.wasm" 2>/dev/null || \
                log_warn "  Binaryen failed for $name.wasm"
        done
    else
        log_warn "  Binaryen (wasm-opt) not available"
    fi

    log_ok "Ring 2 FOSS imports complete"
}

# ═══ Phase 3: Import Ring 2 Commercial ════════════════════════════════
import_commercial() {
    [ "$PROFILE" != "commercial" ] && return 0

    log_info "Importing Ring 2 Commercial artifacts..."

    mkdir -p "$GEN_DIR/imported"

    # Simulink / Embedded Coder
    if command -v matlab >/dev/null 2>&1; then
        for slx in "$ROOT_DIR"/model/simulink/*.slx; do
            [ -f "$slx" ] || continue
            name=$(basename "$slx" .slx)
            log_info "  Embedded Coder: $name.slx"
            matlab -batch "slbuild('$slx')" 2>/dev/null || \
                log_warn "  Embedded Coder failed for $name.slx"
            # Copy generated code
            cp -r "${slx%.slx}_ert_rtw/"* "$GEN_DIR/imported/simulink/" 2>/dev/null || true
        done
    else
        log_warn "  MATLAB/Simulink not available"
    fi

    # IBM Rhapsody
    if command -v rhapsodycl >/dev/null 2>&1; then
        for emx in "$ROOT_DIR"/model/rhapsody/*.emx; do
            [ -f "$emx" ] || continue
            name=$(basename "$emx" .emx)
            log_info "  Rhapsody: $name.emx"
            rhapsodycl -generate "$emx" 2>/dev/null || \
                log_warn "  Rhapsody failed for $name.emx"
            cp -r "$(dirname "$emx")/DefaultComponent/"* \
                "$GEN_DIR/imported/rhapsody/" 2>/dev/null || true
        done
    else
        log_warn "  IBM Rhapsody not available"
    fi

    # Qt Design Studio
    if command -v qmlsc >/dev/null 2>&1; then
        for qml in "$ROOT_DIR"/model/qt/*.qml; do
            [ -f "$qml" ] || continue
            name=$(basename "$qml" .qml)
            log_info "  Qt Design Studio: $name.qml"
            qmlsc "$qml" -o "$GEN_DIR/imported/qt/${name}.cpp" 2>/dev/null || \
                log_warn "  Qt compilation failed for $name.qml"
        done
    else
        log_warn "  Qt Design Studio not available"
    fi

    # RTI DDS
    if command -v rtiddsgen >/dev/null 2>&1; then
        for idl in "$SPECS_DIR"/interface/*.idl; do
            [ -f "$idl" ] || continue
            name=$(basename "$idl" .idl)
            log_info "  rtiddsgen: $name.idl"
            rtiddsgen -language C -d "$GEN_DIR/imported/dds/" "$idl" 2>/dev/null || \
                log_warn "  rtiddsgen failed for $name.idl"
        done
    else
        log_warn "  RTI DDS (rtiddsgen) not available"
    fi

    log_ok "Ring 2 Commercial imports complete"
}

# ═══ Phase 4: Verify Drift ════════════════════════════════════════════
verify_drift() {
    log_info "Verifying drift gate..."

    if git diff --quiet gen/ 2>/dev/null; then
        log_ok "No drift detected"
    else
        log_error "DRIFT DETECTED in gen/"
        log_error "Run 'git diff gen/' to see changes"
        log_error "Commit generated code before proceeding"
        exit 2
    fi
}

# ═══ Main ═════════════════════════════════════════════════════════════
main() {
    log_info "═══════════════════════════════════════════════════════════"
    log_info "CosmicRingForge Regeneration — Profile: $PROFILE"
    log_info "═══════════════════════════════════════════════════════════"

    build_tools
    generate_ring0
    import_foss
    import_commercial

    if [ "${VERIFY:-0}" = "1" ]; then
        verify_drift
    fi

    log_ok "═══════════════════════════════════════════════════════════"
    log_ok "Regeneration complete!"
    log_ok "═══════════════════════════════════════════════════════════"
}

main "$@"
```

### scripts/verify.sh — Drift Verification

```sh
#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# verify.sh — Verify generated code matches committed code
# ═══════════════════════════════════════════════════════════════════════
#
# Usage: ./scripts/verify.sh
#
# This script regenerates all code and verifies no drift exists.
# Used in CI/CD and pre-commit hooks.
#
# Exit codes:
#   0 - No drift, all generated code matches
#   1 - Drift detected
#   2 - Generation failed
# ═══════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Run regeneration with verification
VERIFY=1 "$SCRIPT_DIR/regen.sh" "${1:-portable}"

# Additional checks
echo "[INFO]  Running additional verification..."

# Check for uncommitted Ring 2 outputs
if [ -d gen/imported ]; then
    if ! git diff --quiet gen/imported/; then
        echo "[ERROR] Ring 2 imports have drift!"
        echo "[ERROR] These MUST be committed (can't assume Ring 2 tools available)"
        exit 1
    fi
fi

# Check generator version stamps
for stamp in gen/**/GENERATOR_VERSION; do
    [ -f "$stamp" ] || continue
    if ! git diff --quiet "$stamp"; then
        echo "[WARN]  Generator version changed: $stamp"
    fi
done

echo "[OK]    All verification checks passed"
```

### scripts/new-spec.sh — Create New Spec File

```sh
#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# new-spec.sh — Create a new specification file with boilerplate
# ═══════════════════════════════════════════════════════════════════════
#
# Usage: ./scripts/new-spec.sh <layer> <name> <type>
#   layer: domain, behavior, interface, parsing, platform, persistence, presentation, testing
#   name:  snake_case name for the spec
#   type:  schema, def, sm, hsm, msm, lex, grammar, api, impl, sql, ui, feature, rules, ggo
#
# Example: ./scripts/new-spec.sh domain user_account schema
#          ./scripts/new-spec.sh behavior connection_manager sm
# ═══════════════════════════════════════════════════════════════════════

set -e

LAYER="$1"
NAME="$2"
TYPE="$3"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SPECS_DIR="$ROOT_DIR/specs"

if [ -z "$LAYER" ] || [ -z "$NAME" ] || [ -z "$TYPE" ]; then
    echo "Usage: $0 <layer> <name> <type>"
    echo "  layer: domain, behavior, interface, parsing, platform, persistence, presentation, testing"
    echo "  name:  snake_case name"
    echo "  type:  schema, def, sm, hsm, msm, lex, grammar, api, impl, sql, ui, feature, rules, ggo"
    exit 1
fi

SPEC_FILE="$SPECS_DIR/$LAYER/$NAME.$TYPE"

if [ -f "$SPEC_FILE" ]; then
    echo "[ERROR] File already exists: $SPEC_FILE"
    exit 1
fi

mkdir -p "$SPECS_DIR/$LAYER"

# Generate boilerplate based on type
case "$TYPE" in
    schema)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $(echo "$NAME" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1') SCHEMA
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

type $(echo "$NAME" | sed 's/_\([a-z]\)/\U\1/g; s/^\([a-z]\)/\U\1/') {
    id: u64 [doc: "Unique identifier"]
    /* Add fields here */
}
EOF
        ;;
    def)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $(echo "$NAME" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1') DEFINITIONS
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe the constants/enums defined here]
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

enum $(echo "$NAME" | tr '[:lower:]' '[:upper:]') [prefix: "$(echo "$NAME" | tr '[:lower:]' '[:upper:]')_", xmacro: true] {
    NONE = 0    # Default/unset value
    /* Add values here */
}
EOF
        ;;
    sm)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $(echo "$NAME" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1') STATE MACHINE
 * ═══════════════════════════════════════════════════════════════════════
 *
 * Purpose: [Describe the behavior this state machine models]
 *
 * Related Specs:
 *   - specs/domain/xxx.schema
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

machine $(echo "$NAME" | sed 's/_\([a-z]\)/\U\1/g; s/^\([a-z]\)/\U\1/') {
    # Initial state
    initial: Idle

    state Idle {
        # Entry action
        entry: on_idle_enter()

        # Transitions
        on Start -> Running
    }

    state Running {
        entry: on_running_enter()
        on Stop -> Idle
    }
}
EOF
        ;;
    feature)
        cat > "$SPEC_FILE" << EOF
# ═══════════════════════════════════════════════════════════════════════
# $(echo "$NAME" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
# ═══════════════════════════════════════════════════════════════════════

Feature: $(echo "$NAME" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
  As a [role]
  I want [feature]
  So that [benefit]

  Scenario: Basic operation
    Given [initial condition]
    When [action]
    Then [expected result]
EOF
        ;;
    *)
        cat > "$SPEC_FILE" << EOF
/* ═══════════════════════════════════════════════════════════════════════
 * $(echo "$NAME" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
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
```

---

## Makefile Integration

```makefile
# ═══════════════════════════════════════════════════════════════════════
# CosmicRingForge Makefile
# ═══════════════════════════════════════════════════════════════════════

CC ?= cc
COSMOCC ?= cosmocc

# Directories
BUILD_DIR := build
GEN_DIR := gen
SPECS_DIR := specs
TOOLS_DIR := tools
SRC_DIR := src
VENDOR_DIR := vendor

# Collect sources
GEN_SRCS := $(shell find $(GEN_DIR) -name '*.c' 2>/dev/null)
SRC_SRCS := $(shell find $(SRC_DIR) -name '*.c' 2>/dev/null)
VENDOR_SRCS := $(shell find $(VENDOR_DIR) -name '*.c' 2>/dev/null)
ALL_SRCS := $(GEN_SRCS) $(SRC_SRCS) $(VENDOR_SRCS)

# ═══ Primary Targets ═══════════════════════════════════════════════════

.PHONY: all clean regen verify test

all: $(BUILD_DIR)/app.com

# Regenerate all code (auto-detects available Ring 2 tools)
regen:
	./scripts/regen-all.sh

# Verify no drift in generated code
verify:
	./scripts/regen-all.sh --verify

# Run BDD tests
test: $(BUILD_DIR)/bddgen
	$(BUILD_DIR)/bddgen --run $(SPECS_DIR)/testing/*.feature

# ═══ Build Targets ═════════════════════════════════════════════════════

$(BUILD_DIR)/app.com: $(ALL_SRCS) | $(BUILD_DIR)
	$(COSMOCC) -O3 -o $@ $(ALL_SRCS) \
		-I$(GEN_DIR) -I$(SRC_DIR) -I$(VENDOR_DIR)

$(BUILD_DIR):
	mkdir -p $@

# ═══ Generator Targets ════════════════════════════════════════════════

$(BUILD_DIR)/schemagen: $(TOOLS_DIR)/schemagen.c | $(BUILD_DIR)
	$(CC) -o $@ $<

$(BUILD_DIR)/lemon: $(TOOLS_DIR)/lemon.c | $(BUILD_DIR)
	$(CC) -o $@ $<

# ═══ Utility Targets ══════════════════════════════════════════════════

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf $(GEN_DIR)

# Create new spec file
new-spec:
	@./scripts/new-spec.sh $(LAYER) $(NAME) $(TYPE)

# ═══ Help ═════════════════════════════════════════════════════════════

help:
	@echo "CosmicRingForge Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all      - Build APE binary (cosmocc)"
	@echo "  regen    - Regenerate all code (auto-detects Ring 2 tools)"
	@echo "  verify   - Regenerate and check for drift"
	@echo "  test     - Run BDD tests"
	@echo "  clean    - Remove build artifacts"
	@echo ""
	@echo "Create new spec:"
	@echo "  make new-spec LAYER=domain NAME=user TYPE=schema"
	@echo ""
	@echo "Ring 2 tools are auto-detected. Missing tools are skipped."
	@echo "Ring 2 outputs are committed, so builds always succeed."
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                                                              __         │
│   ██████╗ ██████╗ ███████╗                                 .'  '.       │
│   ██╔══██╗██╔══██╗██╔════╝                                :      ;      │
│   ██████╔╝██║  ██║█████╗    with                           \ -- /       │
│   ██╔══██╗██║  ██║██╔══╝                                  .-(.__).-.    │
│   ██████╔╝██████╔╝███████╗  ███╗   ███╗                  ( (    ) )    │
│   ╚═════╝ ╚═════╝ ╚══════╝  ████╗ ████║ odels!            ).'  '.(     │
│                             ██╔████╔██║                    /      \     │
│   Behavior Driven           ██║╚██╔╝██║                   ( '.__.' )    │
│   Engineering               ██║ ╚═╝ ██║                    \      /     │
│                             ╚═╝     ╚═╝                    |      |     │
│   C O S M I C R I N G F O R G E                           /        \    │
│                                                          ;          ;   │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  WORKFLOW                                                                │
│    Edit spec  →  make regen  →  git diff gen/  →  make test  →  commit │
│                                                                          │
│  COMMANDS                                                                │
│    make regen          Regenerate all (auto-detects Ring 2 tools)       │
│    make verify         Check for drift                                   │
│    make test           Run BDD tests                                     │
│    make                Build APE binary                                  │
│                                                                          │
│  NEW SPEC                                                                │
│    ./scripts/new-spec.sh domain user_account schema                      │
│    ./scripts/new-spec.sh behavior connection sm                          │
│    ./scripts/new-spec.sh testing acceptance feature                      │
│                                                                          │
│  RING 0 (C+sh, always available)                                        │
│    .schema  → schemagen    .def     → defgen      .sm  → smgen          │
│    .lex     → lexgen       .grammar → lemon       .ggo → gengetopt      │
│    .feature → bddgen       .rules   → clipsgen    .api → apigen         │
│    .impl    → implgen      .sql     → sqlgen      .ui  → uigen          │
│                                                                          │
│  RING 2 (auto-detected, outputs committed)                              │
│    .drawio → StateSmith    .proto → protobuf-c   .mo  → OpenModelica   │
│    .fbs    → flatcc        .eez   → EEZ Studio   .wasm → Binaryen      │
│    .slx    → Embedded Coder   .emx → Rhapsody    .idl → rtiddsgen      │
│                                                                          │
│  DRIFT GATE                                                              │
│    git diff --exit-code gen/    # Must pass before commit               │
│                                                                          │
│  KEY INSIGHT                                                             │
│    Behavior specs + models → C code → cosmocc → APE binary (anywhere)  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## See Also

- **STACKS_REFERENCE.md** — Complete tool inventory and architecture
- **CONVENTIONS.md** — Code style and naming conventions
- **RING_CLASSIFICATION.md** — Ring 0/1/2 decision tree
- **strict-purist/docs/XMACROS.md** — X-Macro patterns
- **.claude/features/** — BDD test specifications
