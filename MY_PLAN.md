# MY_PLAN.md — Roadmap to 100%

**Current:** ~85% functional
**Target:** 100% — all generators working, tests passing, documentation complete
**Timeline:** 5 days elapsed (Feb 25 - Mar 1), targeting **Mar 3 completion**

---

## Project Velocity (Actual)

| Metric | Value |
|--------|-------|
| Project age | 5 days |
| Total commits | 62 |
| Generator code | 15,568 lines |
| Working generators | 9 of 14 (64%) |
| Commits/day | ~15 |
| Generators/day | ~2.25 |

---

## Dogfooding Workflow (USE THIS)

**DO NOT hand-write parsers.** Use cosmo-bde tools to generate boilerplate:

```
┌─────────────────────────────────────────────────────────────────┐
│  DOGFOODING PIPELINE — 60% less hand-written code               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  specs/generators/foo.schema                                    │
│         │                                                       │
│         ▼                                                       │
│    ┌─────────┐                                                  │
│    │schemagen│ ──► gen/generators/foo_types.c,h  (FREE)        │
│    └─────────┘                                                  │
│                                                                 │
│  specs/parsing/foo.lex                                          │
│         │                                                       │
│         ▼                                                       │
│    ┌────────┐                                                   │
│    │ lexgen │ ──► gen/parsing/foo_lex.c,h        (FREE)        │
│    └────────┘                                                   │
│                                                                 │
│  specs/parsing/foo.grammar                                      │
│         │                                                       │
│         ▼                                                       │
│    ┌────────┐                                                   │
│    │ lemon  │ ──► gen/parsing/foo_parse.c,h      (FREE)        │
│    └────────┘                                                   │
│                                                                 │
│  tools/foogen/foogen.c  ◄── ONLY write codegen logic (~300 LOC)│
│         │                                                       │
│         ▼                                                       │
│    ┌────────┐                                                   │
│    │  make  │ ──► build/foogen                                  │
│    └────────┘                                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step-by-Step for New Generator

```bash
# 1. Create/verify schema exists
cat specs/generators/foo.schema  # or create it

# 2. Generate types (FREE - ~170 lines)
./build/schemagen specs/generators/foo.schema gen/generators foo

# 3. Create lexer spec
cat > specs/parsing/foo.lex << 'EOF'
# foo.lex - Token definitions for .foo files
TOKEN KEYWORD "keyword"
TOKEN IDENT   "[a-zA-Z_][a-zA-Z0-9_]*"
TOKEN NUMBER  "[0-9]+"
# etc.
EOF

# 4. Generate lexer (FREE - ~200 lines)
./build/lexgen specs/parsing/foo.lex gen/parsing foo

# 5. Create grammar spec
cat > specs/parsing/foo.grammar << 'EOF'
%include { #include "foo_types.h" }
%token KEYWORD IDENT NUMBER.
program ::= decl_list.
decl_list ::= decl_list decl | decl.
# etc.
EOF

# 6. Generate parser (FREE - ~300 lines)
./build/lemon specs/parsing/foo.grammar
mv foo_parse.c foo_parse.h gen/parsing/

# 7. Write ONLY the codegen logic (~300 lines)
cat > tools/foogen/foogen.c << 'EOF'
#include "foogen_self.h"
#include "../../gen/generators/foo_types.h"
#include "../../gen/parsing/foo_lex.h"
#include "../../gen/parsing/foo_parse.h"

// Just implement: parse input → walk AST → emit C code
EOF

# 8. Add to Makefile and build
make tools
```

**Result:** ~300 lines hand-written vs ~800 lines without dogfooding

---

## Phase 1: Critical Fixes (Mar 1 - Tonight)

### 1.1 Fix bddgen --run flag
**Priority:** HIGH — blocks `make test`
**Time:** 1 hour

Add to `tools/bddgen/bddgen.c`:

```c
int main(int argc, char *argv[]) {
    // Add --run flag support
    if (argc >= 2 && strcmp(argv[1], "--run") == 0) {
        int total_features = 0, total_scenarios = 0;
        for (int i = 2; i < argc; i++) {
            feature_t f;
            if (parse_feature_file(argv[i], &f) == 0) {
                printf("Feature: %s (%d scenarios)\n", f.name, f.scenario_count);
                total_features++;
                total_scenarios += f.scenario_count;
            }
        }
        printf("\nTotal: %d features, %d scenarios\n", total_features, total_scenarios);
        return 0;
    }
    // ... existing code ...
}
```

**Verify:**
```bash
make tools
./build/bddgen --run specs/testing/e9livereload.feature
make test  # Should pass
```

---

## Phase 2: Missing Generators — DOGFOODED (Mar 2)

### 2.1 implgen — Platform Implementation Hints
**Priority:** HIGH
**Schema:** `specs/generators/impl.schema` ✓ EXISTS (133 lines, 13 types)
**Types:** Already generated → `gen/generators/impl_types.c,h`

**TODO:**
1. Create `specs/parsing/impl.lex`
2. Create `specs/parsing/impl.grammar`
3. Write `tools/implgen/implgen.c` (codegen only, ~300 lines)

**Output:** `{prefix}_impl.h` with platform dispatch macros

---

### 2.2 msmgen — Modal State Machines
**Priority:** MEDIUM

**TODO:**
1. Create `specs/generators/msm.schema`
2. Generate types: `./build/schemagen specs/generators/msm.schema gen/generators msm`
3. Create `specs/parsing/msm.lex`
4. Create `specs/parsing/msm.grammar`
5. Write `tools/msmgen/msmgen.c` (codegen only)

**Output:** `{prefix}_msm.c,h` with mode switching logic

---

### 2.3 sqlgen — Database Schema Generator
**Priority:** HIGH (useful for real projects)

**TODO:**
1. Create `specs/generators/sql.schema`:
   ```
   type SqlTable { name, columns[], indexes[] }
   type SqlColumn { name, type, constraints }
   type SqlQuery { name, params[], return_type, sql }
   ```
2. Generate types
3. Create `specs/parsing/sql.lex`
4. Create `specs/parsing/sql.grammar`
5. Write `tools/sqlgen/sqlgen.c`

**Output:** `{prefix}_schema.sql` + `{prefix}_db.c,h`

---

### 2.4 siggen — Function Signature Generator
**Priority:** LOW

**TODO:**
1. Create `specs/generators/sig.schema`
2. Generate types
3. Create lexer/grammar
4. Write codegen

**Output:** `{prefix}_ffi.h` with function declarations

---

### 2.5 clipsgen — Business Rules Generator
**Priority:** LOW

**TODO:**
1. Create `specs/generators/rules.schema`
2. Generate types
3. Create lexer/grammar
4. Write codegen

**Output:** `{prefix}_rules.c,h` with rule evaluation

---

## Phase 3: Self-Hosting Completion (Mar 3 AM)

### 3.1 Wire up Lemon integration
**Time:** 2 hours

Update Makefile to use generated parsers:
```makefile
gen/parsing/%_parse.c: specs/parsing/%.grammar
	$(BUILD_DIR)/lemon $<
	mv $*_parse.c $*_parse.h gen/parsing/
```

### 3.2 Replace hand-written parsers
For each generator that has .lex + .grammar:
1. Generate lexer/parser
2. Update generator to use generated code
3. Delete hand-written parser code

---

## Phase 4: Documentation (Mar 3 PM)

### 4.1 Update SPEC_TYPES.md
Mark all generators as ✓ Working

### 4.2 Add example specs
```
specs/platform/example.impl
specs/behavior/example.msm
specs/persistence/example.sql
specs/interface/example.sig
specs/domain/example.rules
```

### 4.3 Update CLAUDE.md
Add new generators to format mapping table

### 4.4 Archive MY_PLAN.md
Move completed items to CHANGELOG.md

---

## Timeline Summary

| Date | Target | Hours |
|------|--------|-------|
| **Mar 1 (Sun)** | Phase 1: bddgen --run fix | 1h |
| **Mar 2 (Mon)** | Phase 2: 5 generators (dogfooded) | 8h |
| **Mar 3 (Tue AM)** | Phase 3: Self-hosting | 2h |
| **Mar 3 (Tue PM)** | Phase 4: Documentation | 2h |
| **Mar 3 EOD** | **100% COMPLETE** | **13h total** |

---

## Checklist

### Phase 1 (Mar 1)
- [ ] Add `--run` flag to bddgen
- [ ] Verify `make test` passes

### Phase 2 (Mar 2) — Use dogfooding!
- [ ] implgen: schema ✓, lex, grammar, codegen
- [ ] msmgen: schema, lex, grammar, codegen
- [ ] sqlgen: schema, lex, grammar, codegen
- [ ] siggen: schema, lex, grammar, codegen
- [ ] clipsgen: schema, lex, grammar, codegen

### Phase 3 (Mar 3 AM)
- [ ] Lemon integration in Makefile
- [ ] Replace hand-written parsers

### Phase 4 (Mar 3 PM)
- [ ] SPEC_TYPES.md updated
- [ ] Example specs created
- [ ] CLAUDE.md updated

---

## Already Done (Head Start)

| File | Status |
|------|--------|
| `specs/generators/impl.schema` | ✓ 133 lines, 13 types |
| `specs/generators/bddgen.schema` | ✓ exists |
| `specs/generators/defgen.schema` | ✓ exists |
| `specs/parsing/feature.lex` | ✓ exists |
| `specs/parsing/feature.grammar` | ✓ exists |
| `specs/parsing/schemagen.lex` | ✓ exists |
| `specs/parsing/schemagen.grammar` | ✓ exists |
| `gen/generators/impl_types.c,h` | ✓ generated |

---

## Commands Cheat Sheet

```bash
# Build tools
make tools

# Generate types from schema
./build/schemagen specs/generators/foo.schema gen/generators foo

# Generate lexer
./build/lexgen specs/parsing/foo.lex gen/parsing foo

# Generate parser
./build/lemon specs/parsing/foo.grammar

# Regenerate everything
make regen

# Test
make test

# Verify no drift
make verify
```

---

## Notes for LLM Agents

**ALWAYS dogfood.** Before writing a parser by hand:

1. Check if `.schema` exists → use schemagen
2. Check if `.lex` exists → use lexgen
3. Check if `.grammar` exists → use lemon

Only hand-write the **codegen logic** (AST → C output).

**Copy-paste template:**
```bash
cp -r tools/smgen tools/foogen
cd tools/foogen
mv smgen.c foogen.c
mv smgen_self.h foogen_self.h
mv smgen_tokens.def foogen_tokens.def
# Edit files, update includes
```

**Commit pattern:**
```
feat: implement foogen (.foo → C) [dogfooded]

- Schema: specs/generators/foo.schema
- Types generated by schemagen
- Lexer generated by lexgen
- Parser generated by lemon
- Hand-written: codegen only (~300 lines)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```
