# CosmicRingForge — Single Source of Truth Index

> **Purpose**: This document indexes ALL authoritative sources in the project.
> When information conflicts, defer to the SSOT listed here.

---

## Ground Truth Documents

| Document | Purpose | Audience |
|----------|---------|----------|
| `INTEROP_MATRIX.md` | Format relationships, composability | Everyone |
| `RING_CLASSIFICATION.md` | Tool rings, portability, cosmocc | Everyone |
| `LITERATE.md` | Conventions, traceability, workflow | Developers |
| `SPEC_TYPES.md` | All spec formats and generators | Developers |
| `.claude/CLAUDE.md` | LLM context anchor (< 200 lines) | LLMs |

---

## Generators (Ring 0)

### schemagen v2.0.0
**SSOT:** `tools/schemagen.c`
- **Input:** `.schema` files
- **Output Modes:**
  - `--c` → `{name}_types.h`, `{name}_types.c`
  - `--json` → `{name}_json.h`, `{name}_json.c` (yyjson)
  - `--sql` → `{name}_sql.h`, `{name}_sql.c` (SQLite)
  - `--proto` → `{name}.proto`
  - `--fbs` → `{name}.fbs`
  - `--all` → All formats (full composability)

### lemon
**SSOT:** `tools/lemon.c`, `tools/lempar.c`
- **Input:** `.y` grammar files
- **Output:** `{name}.c`, `{name}.h`

### smgen (planned)
**SSOT:** `tools/smgen.c`
- **Input:** `.sm` state machine files
- **Output:** `{name}_sm.c`, `{name}_sm.h`

### bddgen (planned)
**SSOT:** `tools/bddgen.c`
- **Input:** `.feature` Gherkin files
- **Output:** `{name}_bdd.c`

---

## Directory Structure

```
specs/{layer}/*.{format}  →  gen/{layer}/*_{role}.c,h
model/{tool}/*            →  gen/imported/{tool}/*
```

### Spec Layers
| Layer | Purpose | Formats |
|-------|---------|---------|
| `domain` | Data definitions | `.schema`, `.def` |
| `behavior` | State machines | `.sm`, `.hsm` |
| `interface` | External contracts | `.api`, `.ggo`, `.ui` |
| `parsing` | Language processing | `.lex`, `.y` |
| `serialization` | Wire formats | `.proto`, `.fbs` |
| `testing` | Verification | `.feature` |

### Generated Output
| Source | Generated |
|--------|-----------|
| `specs/domain/foo.schema` | `gen/domain/foo_types.c,h` |
| `specs/behavior/bar.sm` | `gen/behavior/bar_sm.c,h` |
| `model/statesmith/*.drawio` | `gen/imported/statesmith/*_sm.c,h` |

---

## Scripts (Automation)

| Script | Purpose |
|--------|---------|
| `scripts/regen-all.sh` | Regenerate all from specs (auto-detect tools) |
| `scripts/template-init.sh` | Initialize after cloning template |
| `scripts/bde-workflow.sh` | BDE workflow commands |
| `scripts/verify-tools.sh` | Report available tools |
| `scripts/new-spec.sh` | Create new spec with headers |
| `scripts/test.sh` | Run tests |

---

## CI Workflows

| Workflow | Purpose |
|----------|---------|
| `.github/workflows/repo-ci.yml` | Meta tests (developing this repo) |
| `.github/workflows/template-ci.yml` | User tests (after template clone) |

---

## Ring 2 Tools (External)

Ring 2 tools are auto-detected. Outputs must be committed to `gen/imported/`.

| Tool | Input | Output | Detection |
|------|-------|--------|-----------|
| StateSmith | `.drawio` | `*_sm.c,h` | `dotnet` |
| protobuf-c | `.proto` | `*.pb-c.c,h` | `protoc` |
| flatcc | `.fbs` | `*_builder.c` | `flatcc` |
| OpenModelica | `.mo` | `*_model.c` | `omc` |
| MATLAB | `.slx` | `*.c,h` | `matlab` |
| Rhapsody | `.emx` | `*.c,h` | `rhapsodycl` |

---

## Build System

**SSOT:** `Makefile`

| Target | Purpose |
|--------|---------|
| `make` | Build application |
| `make tools` | Build Ring 0 generators |
| `make regen` | Regenerate from specs |
| `make verify` | Regen + drift check |
| `make ape` | Build with cosmocc (APE) |
| `make formats` | Show discovered formats |
| `make test` | Run tests |
| `make lint` | Static analysis |

---

## Composability Matrix

schemagen v2.0.0 enables full composability:

```
.schema → schemagen --all → C, JSON, SQL, .proto, .fbs
                              ↓        ↓       ↓
                           Native   protoc  flatcc
                              ↓        ↓       ↓
                           cosmocc   ───────────
                              ↓
                            APE binary
```

All paths lead to C. All C compiles with cosmocc to APE.

---

## Update Protocol

1. **Ring changes** → Update `RING_CLASSIFICATION.md`
2. **Format changes** → Update `INTEROP_MATRIX.md`
3. **New generator** → Add to `tools/`, update this file
4. **New spec type** → Add to `SPEC_TYPES.md`
5. **Convention changes** → Update `.claude/CONVENTIONS.md`
6. **LLM context** → Update `.claude/CLAUDE.md` (keep < 200 lines)

---

**Document Version**: 2.0.0
**Last Updated**: 2026-02-28
