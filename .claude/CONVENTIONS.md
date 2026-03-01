# MBSE Stacks — Universal Conventions

> **Audience**: Human developers AND Large Language Models
>
> These conventions govern **both** the development of this stack itself **and** all
> projects built using it. Written for clarity to humans and parseability by LLMs.

---

## Purpose

This document serves as the **single source of truth** for coding, naming, and
structural conventions. When in doubt, check here first.

**For Humans**: Follow these patterns for consistency and maintainability.
**For LLMs**: Use these patterns when generating or analyzing code in this stack.

---

## 1. Naming Conventions

### 1.1 Identifier Patterns

| Type | Pattern | Example | Notes |
|------|---------|---------|-------|
| **Functions** | `prefix_module_action()` | `mhi_channel_price()` | Verb at end |
| **Types** | `prefix_entity_t` | `mhi_channel_t` | Always `_t` suffix |
| **Constants** | `PREFIX_CATEGORY_NAME` | `MHI_ERR_NOT_FOUND` | ALL_CAPS |
| **Enums** | `prefix_enum_t` | `mhi_state_t` | Type is lowercase_t |
| **Enum Values** | `PREFIX_ENUM_VALUE` | `MHI_STATE_IDLE` | ALL_CAPS |
| **Globals** | `g_prefix_name` | `g_mhi_config` | Avoid when possible |
| **File-static** | `s_name` | `s_initialized` | File-local only |

### 1.2 Prefix Selection

Choose a short (2-4 char) prefix unique to your project:

```
mhi_   — MHI Procurement
mbse_  — MBSE Stacks
app_   — Generic application
ctl_   — Controller
ui_    — User interface
db_    — Database layer
```

**Why prefixes?** C has no namespaces. Prefixes prevent symbol collisions when
linking multiple projects or libraries together.

### 1.3 File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Specifications | `name.{schema,sm,ui,lex}` | `types.schema` |
| Generated Header | `prefix_category.h` | `mhi_types.h` |
| Generated Source | `prefix_category.c` | `mhi_types.c` |
| Generators | `namegen.c` | `schemagen.c` |
| Tests | `test_module.c` | `test_channel.c` |
| Bootstrap | `name_bootstrap.c` | `schemagen_bootstrap.c` |

---

## 2. Code Structure

### 2.1 Section Separators

Use visual separators to create scannable code:

```c
/* ── Section Name ──────────────────────────────────────────────── */
```

**Standard sections** (in this order):
1. File header comment
2. Includes
3. Constants / Defines
4. Type Definitions
5. Static Variables
6. Utilities
7. Core Logic
8. Main / Entry Point

**Example**:
```c
/* MBSE Stacks — Schema Generator
 * Ring 0: Pure C, minimal bootstrap
 */

#include <stdio.h>
#include <stdlib.h>

#define MAX_TYPES 256

/* ── Type System ──────────────────────────────────────────────── */

typedef enum { TYPE_I32, TYPE_STRING } base_type_t;

/* ── Parser ───────────────────────────────────────────────────── */

static int parse_field(const char *line, field_t *f) { ... }

/* ── Main ─────────────────────────────────────────────────────── */

int main(int argc, char *argv[]) { ... }
```

### 2.2 Function Documentation

**Exported functions**: One-line comment above:
```c
/* Initialize channel with default values */
void mhi_channel_init(mhi_channel_t *ch);
```

**Complex functions**: Brief description + parameter notes:
```c
/* Calculate price for product in channel
 * @param ch      Channel context (must be initialized)
 * @param prod_id Product ID to price
 * @param out     Output: calculated price
 * @return        MHI_OK on success, error code otherwise
 */
mhi_result_t mhi_channel_price(mhi_channel_t *ch, int64_t prod_id, double *out);
```

**Internal (static) functions**: Comment only if non-obvious.

### 2.3 Error Handling Pattern

Use result enums, not exceptions or errno:

```c
typedef enum {
    PREFIX_OK = 0,        /* Success */
    PREFIX_ERR_NULL,      /* Null pointer argument */
    PREFIX_ERR_NOT_FOUND, /* Item not found */
    PREFIX_ERR_INVALID,   /* Invalid input */
    PREFIX_ERR_IO,        /* I/O operation failed */
} prefix_result_t;
```

**Usage pattern**:
```c
prefix_result_t res = prefix_do_thing(input, &output);
if (res != PREFIX_OK) {
    fprintf(stderr, "Error: %d\n", res);
    return res;
}
```

### 2.4 Memory Management

**Prefer stack allocation** for small, fixed-size data.

**When heap needed**:
- `malloc`/`free` pairs in same scope
- Document ownership in comments
- For generated code: caller provides buffer with size

```c
/* Caller allocates buffer, function fills it */
int to_json(const Config *cfg, char *buf, size_t buf_size);
```

---

## 3. Specification Formats

Specs are the **source of truth**. Code is generated from specs.

### 3.1 Schema Spec (`.schema`)

Defines data types and constraints.

```
# Comment line
@json                              # Directive: generate JSON serialization

type TypeName {
    field_name: type [constraints]
}
```

**Primitive types**:
- Integers: `i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`
- Floats: `f32`, `f64`
- Boolean: `bool`
- String: `string[N]` (fixed-size array)

**Constraints**:
- `[range: min..max]` — Numeric bounds validation
- `[default: value]` — Default initialization value
- `[not_empty]` — String must have content

**Example**:
```
@json
type Config {
    port: u16 [range: 1024..65535]
    name: string[64] [not_empty]
    timeout_ms: u32 [default: 5000]
}
```

### 3.2 State Machine Spec (`.sm`)

Defines behavioral state machines.

```
machine MachineName {
    initial: InitialState

    state StateName {
        entry: entry_action()      # Called on state entry
        exit: exit_action()        # Called on state exit
        on EventName -> TargetState
        on EventName [guard] -> TargetState / action()
    }
}
```

**Example**:
```
machine Controller {
    initial: Idle

    state Idle {
        entry: led_off()
        on Start -> Running
        on Error -> Failed
    }

    state Running {
        entry: motor_start()
        exit: motor_stop()
        on Stop -> Idle
        on Overheat [temp_critical] -> Failed / alarm()
    }

    state Failed {
        entry: emergency_stop()
        on Reset -> Idle
    }
}
```

### 3.3 UI Spec (`.ui`)

Defines user interface layouts.

```
window WindowName {
    title: "Display Title"
    width: 800
    height: 600

    panel PanelName {
        layout: vertical | horizontal | grid

        button Name { label: "Click", on_click: handler }
        slider Name { min: 0, max: 100, bind: state.field }
        label Name { bind: state.status }
    }
}
```

### 3.4 Token Spec (`.lex`)

Defines lexer tokens for parsers.

```
TOKEN_NAME   "literal"           # Exact string match
TOKEN_NAME   [a-zA-Z_]+          # Pattern match (regex subset)
WHITESPACE   [ \t\n]+  @skip     # Skip directive
```

---

## 4. Generated Code Format

All generators produce code in consistent format.

### 4.1 Header Template

```c
/* AUTO-GENERATED by toolname VERSION — DO NOT EDIT */
#ifndef PREFIX_MODULE_H
#define PREFIX_MODULE_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

/* Forward declarations */
typedef struct TypeName TypeName;

/* Type definitions */
struct TypeName {
    int32_t field;
};

/* Function declarations */
void TypeName_init(TypeName *obj);
bool TypeName_validate(const TypeName *obj);

#endif /* PREFIX_MODULE_H */
```

### 4.2 Source Template

```c
/* AUTO-GENERATED by toolname VERSION — DO NOT EDIT */

#include "prefix_module.h"
#include <string.h>

void TypeName_init(TypeName *obj) {
    memset(obj, 0, sizeof(*obj));
}

bool TypeName_validate(const TypeName *obj) {
    if (!obj) return false;
    return true;
}
```

### 4.3 Version Stamp

Every generator creates `GENERATOR_VERSION`:

```
toolname VERSION
generated: YYYY-MM-DDTHH:MM:SSZ
profile: portable | ape
```

---

## 5. Build System

### 5.1 Profiles

| Profile | Toolchain | Use Case |
|---------|-----------|----------|
| `portable` | Native cc (gcc/clang) | Development, platform-specific |
| `ape` | cosmocc | Actually Portable Executable |

### 5.2 Directory Layout

```
project/
├── .claude/              # LLM context (always loaded)
│   ├── CLAUDE.md         # Main context (<200 lines)
│   ├── CONVENTIONS.md    # This file
│   ├── DOMAIN.md         # Business domain
│   ├── SSOT.md           # File index
│   └── features/         # BDD specifications
├── specs/                # Source specifications
├── gen/                  # Generators + generated code
│   └── toolname/
│       ├── toolname.c    # Generator source
│       ├── prefix_*.h    # Generated headers
│       └── prefix_*.c    # Generated sources
├── vendors/libs/               # Third-party vendored code
├── src/                  # Hand-written source (minimal)
├── tests/                # Test files
├── build/                # Artifacts (gitignored)
└── Makefile
```

### 5.3 Makefile Targets

| Target | Purpose |
|--------|---------|
| `make` | Build with PROFILE=portable |
| `make PROFILE=ape` | Build APE binary |
| `make test` | Run tests |
| `make regen` | Regenerate from specs |
| `make regen-check` | Regen + drift detection |
| `make clean` | Remove build artifacts |

### 5.4 Drift Gate

```makefile
regen-check: regen
	git diff --exit-code gen/ || (echo "Drift detected!" && exit 1)
```

This ensures generated code in git matches current specs.

---

## 6. Testing

### 6.1 BDD Mapping

Tests map to Gherkin scenarios in `.claude/features/`:

| Feature File | Test File |
|--------------|-----------|
| `features/channel.feature` | `tests/test_channel.c` |
| `Scenario: Price calculation` | `test_price_calculation()` |

### 6.2 Test Structure

```c
/* test_module.c - Tests for module
 * Maps to: .claude/features/module.feature
 */

#include "module.h"
#include <assert.h>
#include <stdio.h>

/* ── Test: Scenario Name (from feature file) ───────────────────── */

static void test_scenario_name(void) {
    /* Given: setup */
    Config cfg;
    cfg_init(&cfg);

    /* When: action */
    result_t res = cfg_validate(&cfg);

    /* Then: assertions */
    assert(res == OK);
}

/* ── Main ─────────────────────────────────────────────────────── */

int main(void) {
    test_scenario_name();
    printf("All tests passed\n");
    return 0;
}
```

---

## 7. Ring Classification

### Ring 0 (Bootstrap)

**Requirements**: Only C compiler + sh + make
- Pure C11, no C++ features
- No external dependencies beyond libc
- Must compile with: gcc, clang, tcc, cosmocc

### Ring 1 (Quality Tools)

**Requirements**: Ring 0 + C-based tools
- sanitizers, cppcheck, static analysis
- Build must succeed without them (graceful degradation)

### Ring 2 (Authoring)

**Requirements**: External toolchains allowed
- StateSmith, EEZ Studio, MATLAB
- Outputs must be committed to git
- Outputs must be Ring-0 compatible C

---

## 8. Cosmopolitan / APE

### Platform Detection

```c
#ifdef __COSMOPOLITAN__
    if (IsLinux()) { /* Linux-specific */ }
    if (IsWindows()) { /* Windows-specific */ }
    if (IsXnu()) { /* macOS-specific */ }
#endif
```

### Embedded Assets

```c
/* Files embedded via /zip/ prefix */
FILE *f = fopen("/zip/assets/logo.png", "rb");
```

### Build Flags

```makefile
ifeq ($(PROFILE),ape)
    CC := cosmocc
    CFLAGS := -mcosmo -O2 -Wall -Werror -std=c11
endif
```

---

## 9. Git Conventions

### Commit Message Format

```
type(scope): brief description

- Detail 1
- Detail 2

Ring: 0 | 1 | 2
```

**Types**: `feat`, `fix`, `gen`, `spec`, `docs`, `build`, `test`

### Branch Naming

```
feature/state-machine-gen
fix/schema-parser-overflow
gen/statesmith-v0.9.14
```

---

## Quick Reference Card

```
IDENTIFIERS
─────────────────────────────────────
function    prefix_mod_action()
type        prefix_entity_t
constant    PREFIX_CAT_NAME
enum value  PREFIX_ENUM_VALUE

FILES
─────────────────────────────────────
spec        name.schema / name.sm / name.ui
gen header  prefix_module.h
gen source  prefix_module.c
test        test_module.c

SECTIONS
─────────────────────────────────────
/* ── Section Name ──────────────── */

ERROR HANDLING
─────────────────────────────────────
typedef enum { PREFIX_OK = 0, PREFIX_ERR_* } prefix_result_t;

SCHEMA TYPES
─────────────────────────────────────
i8 i16 i32 i64    Signed integers
u8 u16 u32 u64    Unsigned integers
f32 f64           Floats
bool              Boolean
string[N]         Fixed-size string

CONSTRAINTS
─────────────────────────────────────
[range: min..max]   Numeric bounds
[default: value]    Default value
[not_empty]         Non-empty string
```

---

## schemagen v2.0.0 Output Modes

schemagen supports multiple output formats for full composability:

| Flag | Output Files | Dependencies |
|------|--------------|--------------|
| `--c` | `{name}_types.h`, `{name}_types.c` | None (pure C) |
| `--json` | `{name}_json.h`, `{name}_json.c` | yyjson |
| `--sql` | `{name}_sql.h`, `{name}_sql.c` | sqlite3 |
| `--proto` | `{name}.proto` | protoc (Ring 2) |
| `--fbs` | `{name}.fbs` | flatcc (Ring 2) |
| `--all` | All above | All above |

**Example:**
```bash
# Generate all formats from a schema
./build/schemagen --all specs/domain/sensor.schema gen/domain sensor
```

---

**Document Version**: 2.0.0
**Last Updated**: 2026-02-28
**Applies To**: cosmo-bde and all projects using this stack
