# MY_PLAN.md — Roadmap to 100%

**Current:** ~85% functional
**Target:** 100% — all generators working, tests passing, documentation complete

---

## Phase 1: Critical Fixes (Day 1)

### 1.1 Fix bddgen --run flag
**Priority:** HIGH — blocks `make test`

PR #3's bddgen lacks the `--run` flag that PR #2 had. Need to add:

```c
// In tools/bddgen/bddgen.c, add argument parsing:
if (argc >= 2 && strcmp(argv[1], "--run") == 0) {
    // Parse and report without generating files
    for (int i = 2; i < argc; i++) {
        parse_feature_file(argv[i]);
        print_feature_summary();
    }
    return 0;
}
```

**Files:**
- `tools/bddgen/bddgen.c` — Add --run flag handling

**Verify:**
```bash
make tools
./build/bddgen --run specs/testing/e9livereload.feature
make test  # Should pass
```

---

### 1.2 Fix make test target
**Priority:** HIGH

If bddgen --run is added, test should work. Otherwise, update Makefile:

```makefile
test: tools
	@echo "Running BDD tests..."
	@if [ -d "$(SPECS_DIR)/testing" ] && [ -x "$(BUILD_DIR)/bddgen" ]; then \
		for f in $(SPECS_DIR)/testing/*.feature; do \
			$(BUILD_DIR)/bddgen "$$f" $(BUILD_DIR)/test $$(basename "$$f" .feature); \
		done; \
		echo "BDD harnesses generated"; \
	fi
```

---

## Phase 2: Missing Generators (Days 2-5)

### 2.1 implgen — Platform Implementation Hints
**Priority:** MEDIUM
**Spec exists:** `specs/generators/impl.schema` (check if exists)

Generates platform-specific code paths:
```
# specs/platform/memory.impl
platform Linux {
    allocator: mmap
    simd: AVX2
}
platform Windows {
    allocator: VirtualAlloc
    simd: AVX2
}
platform Cosmopolitan {
    allocator: IsLinux() ? mmap : VirtualAlloc
    simd: runtime_detect()
}
```

**Output:** `{prefix}_impl.c,h` with `#if` blocks

**Files to create:**
- `tools/implgen/implgen.c`
- `tools/implgen/implgen_tokens.def`
- `tools/implgen/implgen_self.h`
- `specs/generators/implgen.schema` (if not exists)

---

### 2.2 msmgen — Modal State Machines
**Priority:** LOW
**Use case:** Mode-switching systems (edit mode, view mode, etc.)

Different from HSM — modes are mutually exclusive top-level states with shared sub-behaviors.

```
# specs/behavior/editor.msm
modal EditorModes {
    mode Normal {
        on 'i' -> Insert
        on ':' -> Command
    }
    mode Insert {
        on ESC -> Normal
    }
    mode Command {
        on ENTER -> Normal.execute
        on ESC -> Normal
    }
}
```

**Files to create:**
- `tools/msmgen/msmgen.c`
- `tools/msmgen/msmgen_tokens.def`
- `tools/msmgen/msmgen_self.h`

---

### 2.3 sqlgen — Database Schema Generator
**Priority:** MEDIUM
**Use case:** Generate SQLite schema + CRUD functions from specs

```
# specs/persistence/users.sql
table users {
    id: integer primary key
    name: text not null
    email: text unique
    created_at: timestamp default now
}

index users_email on users(email)

query find_by_email(email: text) -> users {
    SELECT * FROM users WHERE email = ?
}
```

**Output:**
- `{prefix}_schema.sql` — DDL statements
- `{prefix}_db.c,h` — C functions for queries

**Files to create:**
- `tools/sqlgen/sqlgen.c`
- `tools/sqlgen/sqlgen_tokens.def`
- `tools/sqlgen/sqlgen_self.h`

---

### 2.4 siggen — Function Signature Generator
**Priority:** LOW
**Use case:** FFI bindings, header generation

```
# specs/interface/math.sig
module math {
    fn add(a: i32, b: i32) -> i32
    fn multiply(a: f64, b: f64) -> f64
    fn vector_dot(v1: *f32, v2: *f32, len: usize) -> f32 [simd]
}
```

**Output:**
- `{prefix}_ffi.h` — Function declarations
- `{prefix}_ffi.c` — Stub implementations or trampolines

---

### 2.5 clipsgen — Business Rules Generator
**Priority:** LOW
**Use case:** Rule-based systems, validation logic

```
# specs/domain/pricing.rules
rule ApplyDiscount {
    when {
        order.total > 100
        customer.tier == "gold"
    }
    then {
        order.discount = 0.15
    }
}
```

**Output:** `{prefix}_rules.c,h` — Rule evaluation functions

---

## Phase 3: Self-Hosting Completion (Days 6-7)

### 3.1 Complete schemagen self-hosting
**Status:** Partially done

Ensure `specs/generators/schemagen.schema` is parsed by schemagen itself:
```bash
./build/schemagen specs/generators/schemagen.schema gen/generators schemagen
```

### 3.2 Add Lemon grammar integration
**Status:** Grammars exist but not integrated into build

Files exist:
- `specs/parsing/schemagen.lex`
- `specs/parsing/schemagen.grammar`

Need to:
1. Generate lexer with lexgen
2. Generate parser with Lemon
3. Replace hand-written parsers with generated ones

---

## Phase 4: Documentation & Polish (Day 8)

### 4.1 Update SPEC_TYPES.md
Mark all new generators as ✓ Working

### 4.2 Add example specs
For each new generator, add example in `specs/`:
- `specs/platform/example.impl`
- `specs/behavior/example.msm`
- `specs/persistence/example.sql`
- `specs/interface/example.sig`
- `specs/domain/example.rules`

### 4.3 Update CLAUDE.md
Add new generators to the format mapping table

### 4.4 Clean up MY_PLAN.md
Convert completed items to a CHANGELOG entry

---

## Phase 5: Ring 2 Integration (Future)

### 5.1 StateSmith integration
- Process `.drawio` files
- Output to `gen/imported/`

### 5.2 protobuf-c integration
- Process `.proto` files
- Generate C bindings

### 5.3 WAMR interpreter integration
- Ring 0 compatible WASM runtime
- For plugin system

---

## Checklist

### Phase 1 (Critical)
- [ ] Add `--run` flag to bddgen
- [ ] Verify `make test` passes

### Phase 2 (Generators)
- [ ] implgen implemented
- [ ] msmgen implemented
- [ ] sqlgen implemented
- [ ] siggen implemented
- [ ] clipsgen implemented

### Phase 3 (Self-Hosting)
- [ ] schemagen fully self-hosted
- [ ] Lemon integration in build

### Phase 4 (Documentation)
- [ ] SPEC_TYPES.md updated
- [ ] Example specs for all generators
- [ ] CLAUDE.md updated

### Phase 5 (Ring 2)
- [ ] StateSmith integration
- [ ] protobuf-c integration
- [ ] WAMR integration

---

## Priority Order

1. **bddgen --run** — Unblocks testing
2. **sqlgen** — High value for real projects
3. **implgen** — Enables platform abstraction
4. **msmgen** — Nice to have for UI
5. **siggen** — FFI support
6. **clipsgen** — Business rules (specialized)

---

## Time Estimates

| Phase | Effort | Complexity |
|-------|--------|------------|
| Phase 1 | 1-2 hours | Low |
| Phase 2 | 2-3 days | Medium |
| Phase 3 | 1 day | Medium |
| Phase 4 | 0.5 day | Low |
| Phase 5 | 1 week | High |

**Total to 100% core:** ~5 days
**Total with Ring 2:** ~2 weeks

---

## Notes for LLM Agents

When implementing a new generator:

1. Copy an existing generator as template:
   ```bash
   cp -r tools/smgen tools/foogen
   mv tools/foogen/smgen.c tools/foogen/foogen.c
   # etc.
   ```

2. Update token definitions for your format

3. Add to Makefile RING0_TOOLS list

4. Create example spec in `specs/`

5. Run `make tools && make regen`

6. Update SPEC_TYPES.md status

7. Commit with pattern:
   ```
   feat: implement foogen (.foo → C)

   - Parses .foo specs
   - Generates {prefix}_foo.c,h
   - Self-hosted via X-macros

   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
   ```
