# CosmicRingForge Dogfooding Protocol

> If you're not eating your own dog food, you're not cooking.

## The Loop

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        DOGFOODING FEEDBACK LOOP                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│    ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐    │
│    │  .schema │ ──▶ │ schemagen│ ──▶ │  _types  │ ──▶ │  build   │    │
│    │  .sm     │     │ smgen    │     │  _fsm    │     │  test    │    │
│    │  .feature│     │ (verify) │     │  .h/.c   │     │  run     │    │
│    └──────────┘     └──────────┘     └──────────┘     └──────────┘    │
│         │                                                    │          │
│         │                                                    │          │
│         └────────────────── feedback ◀───────────────────────┘          │
│                                                                         │
│    Time from spec change to running code: < 5 seconds                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Self-Hosting Requirements

### Ring 0 Generators MUST self-host:

| Generator | Spec File | Generated Output | Status |
|-----------|-----------|------------------|--------|
| schemagen | `schemagen.schema` | `schemagen_types.h` | ✗ BROKEN |
| smgen | `smgen.sm` | `smgen_fsm.h` | ✗ MISSING |
| lexgen | `lexgen.lex` | `lexgen_tokens.h` | ✗ MISSING |

### Current Violations

**schemagen** has HAND-WRITTEN types that should be GENERATED:

```c
// strict-purist/gen/schemagen/schemagen.c lines 30-50
// THIS IS WRONG - these types duplicate schemagen.schema

typedef struct {
    char name[MAX_NAME];        // Should come from SchemaField
    base_type_t base;
    ...
} field_t;                      // Should be schema_field_t (generated)
```

**Fix required:**
```c
// CORRECT - use generated types
#include "schemagen_types.h"    // Generated from schemagen.schema

// Hand-write ONLY:
// - main()
// - parse logic
// - codegen logic
```

## Bootstrap Protocol

### Phase 1: Bootstrap (one-time)

```sh
# 1. Build minimal bootstrap schemagen (hand-written types)
cc -o schemagen_bootstrap schemagen_bootstrap.c

# 2. Generate schemagen's own types
./schemagen_bootstrap strict-purist/specs/schemagen.schema \
    strict-purist/gen/schemagen schemagen

# 3. Build real schemagen using generated types
cc -o schemagen schemagen.c schemagen_types.c
```

### Phase 2: Self-Hosting (ongoing)

```sh
# Any change to schemagen.schema:
./build/schemagen strict-purist/specs/schemagen.schema \
    strict-purist/gen/schemagen schemagen

# Rebuild schemagen with new types
make schemagen

# schemagen now uses its own output
```

## BDD Verification

### Feature files MUST be executable

Current state: `.claude/features/generators.feature` is DOCUMENTATION ONLY.

Required state: Features must run as tests.

```sh
# This should work:
make test-bdd

# Which runs:
# 1. Parse .feature files
# 2. Match scenarios to test functions
# 3. Execute Given/When/Then steps
# 4. Report pass/fail
```

### Minimal BDD Runner (Ring 0)

Since we can't use Cucumber (Ruby) or behave (Python), we need a C BDD runner:

```c
// bdd_runner.c - Ring 0 BDD test executor
// Parses .feature files, calls test_* functions

typedef struct {
    const char *scenario;
    int (*test_fn)(void);
} bdd_scenario_t;

// Auto-generated from .feature files:
bdd_scenario_t scenarios[] = {
    {"Generate C types from schema specification", test_schemagen_basic},
    {"Generate validators from schema constraints", test_schemagen_validators},
    ...
};
```

## Immediate Feedback Protocol

### Watch Mode (goal: <5 second feedback)

```sh
# Terminal 1: Watch specs
make watch-specs

# On any .schema/.sm/.feature change:
# 1. Regenerate affected outputs
# 2. Rebuild affected binaries
# 3. Run affected tests
# 4. Show pass/fail
```

### Implementation

```makefile
watch-specs:
	@while true; do \
		inotifywait -q -e modify specs/*.schema specs/*.sm; \
		make regen test; \
	done
```

Or using the portable approach:

```sh
# scripts/watch.sh
while true; do
    checksum=$(sha256sum specs/*.schema specs/*.sm | sha256sum)
    if [ "$checksum" != "$last_checksum" ]; then
        make regen test
        last_checksum="$checksum"
    fi
    sleep 1
done
```

## Literate Documentation Requirements

### Every generator must have:

1. **Spec file** - `.schema`, `.sm`, or `.lex`
2. **Feature file** - BDD scenarios in `.feature`
3. **CONVENTION.md** - Naming, structure, error handling
4. **Generated output** - Committed to `gen/`
5. **Self-hosting proof** - Uses own generated types

### Documentation is code:

```
# This comment in schemagen.schema:
# ── Core Field Type ──────────────────────────────────────────────

# Becomes this separator in schemagen_types.h:
/* ── Core Field Type ────────────────────────────────────────────── */
```

## Verification Checklist

Before any commit:

- [ ] `make regen` succeeds
- [ ] `git diff gen/` shows expected changes only
- [ ] `make test` passes
- [ ] No hand-written code duplicates spec definitions
- [ ] Feature scenarios match implementation
- [ ] Self-hosting generators use their own output

## The Rule

> **If a type exists in a .schema file, it MUST NOT be hand-written in C.**
>
> **If a state machine exists in a .sm file, it MUST NOT be hand-written in C.**
>
> **If behavior is described in a .feature file, it MUST be tested.**

Violations of this rule indicate broken dogfooding.

---

*Last verified: NOT YET - dogfooding loop is broken*
