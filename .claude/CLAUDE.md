# CosmicRingForge - LLM Context

## Overview
**Behavior Driven Engineering with Models** — BDE with Models.

Framework for the design and development of any application. All paths lead to C.

## Architecture Principle
Separate **authoring** (how you create models) from **shipping** (what's required to build).
Ring 2 tools (FOSS or commercial) generate Ring 0 compatible C code that's committed and drift-gated.

**Key Insight:** All Ring 2 tools output C. All C compiles with cosmocc to APE binaries.
The distinction is licensing/certification, not portability. Tools are auto-detected at regen time.

## Ring Classification
| Ring | Bootstrap | Tools |
|------|-----------|-------|
| **0** | C + sh + make | schemagen, defgen, smgen, lexgen, bddgen, bin2c, Lemon, SQLite, Nuklear, yyjson, CLIPS, CivetWeb, flatcc, e9patch, kilo, Cosmopolitan |
| **1** | Ring 0 + C tools | gengetopt, makeheaders, cppcheck, sanitizers (ASan/UBSan/TSan), cosmo-disasm |
| **2** | External toolchains | StateSmith, protobuf-c, EEZ Studio, LVGL, OpenModelica, Binaryen, WAMR, MATLAB, Rhapsody, Qt Design Studio, RTI Connext DDS |

## Spec Types (15+)
| Type | Generator | Purpose |
|------|-----------|---------|
| `.schema` | schemagen | Data types, structs, validation |
| `.def` | defgen | Constants, enums, X-Macros, config |
| `.impl` | implgen | Platform hints, SIMD, allocation |
| `.sm` | smgen | Flat state machines |
| `.hsm` | hsmgen | Hierarchical state machines |
| `.lex` | lexgen | Lexer tokens, patterns |
| `.grammar` | Lemon | Parser grammars (LALR) |
| `.feature` | bddgen | BDD test scenarios (Gherkin) |
| `.ggo` | gengetopt | CLI option specs |
| `.proto` | protobuf-c | Wire protocol (Ring 2) |
| `.fbs` | flatcc | Zero-copy serialization |
| `.drawio` | StateSmith | Visual state machines (Ring 2) |
| `.mo` | OpenModelica | Physics simulation (Ring 2) |
| `.eez` | EEZ Studio | Embedded GUI (Ring 2) |

See `SPEC_TYPES.md` and `STACKS_REFERENCE.md` for complete details.

## Build Commands
```bash
make regen    # Auto-detect Ring 2 tools, regenerate C code
make          # Compile with cosmocc to APE binary
make verify   # Regen + check for drift
```

## Directory Structure
```
cosmicringforge/
├── specs/             # Source of truth (all spec types)
│   ├── domain/        # .schema, .def, .rules
│   ├── behavior/      # .sm, .hsm, .msm
│   ├── interface/     # .api, .ggo, .proto, .fbs
│   ├── parsing/       # .lex, .grammar
│   └── testing/       # .feature
├── model/             # Ring 2 visual sources
│   ├── statesmith/    # .drawio files
│   ├── openmodelica/  # .mo files
│   └── simulink/      # .slx (commercial only)
├── gen/               # Generated code (committed)
│   ├── domain/        # From Ring 0 generators
│   └── imported/      # From Ring 2 generators
├── tools/             # Ring 0 generators (schemagen, etc.)
├── vendor/            # Vendored C libraries
├── src/               # Hand-written code
├── scripts/           # Automation (regen.sh, verify.sh)
└── .claude/           # LLM context, BDD specs
```

## Naming Conventions
- Generators: `{name}gen.c` (e.g., `schemagen.c`)
- Specs: `*.schema`, `*.sm`, `*.ui`
- Generated: `gen/{tool}/{output}.c` with `GENERATOR_VERSION`

## Key Files
| Purpose | Path |
|---------|------|
| **Master Reference** | `STACKS_REFERENCE.md` |
| Spec Types | `SPEC_TYPES.md` |
| Tool Inventory | `TOOLING.md` |
| Ring Classification | `RING_CLASSIFICATION.md` |
| X-Macro Patterns | `strict-purist/docs/XMACROS.md` |
| License Tracking | `LICENSES.md` |
| LLM Context | `AGENTS.md` |
| Conventions | `CONVENTIONS.md` |
| BDD Specs | `.claude/features/*.feature` |
| Build System | `Makefile` |

## Orchestration Scripts
| Script | Purpose |
|--------|---------|
| `scripts/regen-all.sh` | Auto-detect tools, regenerate all code |
| `scripts/regen-all.sh --verify` | Regen + check for drift |
| `scripts/verify-tools.sh` | Check which tools are available |
| `scripts/new-spec.sh` | Create new spec file with boilerplate |

## Regen-and-Diff Gate
```bash
./scripts/regen-all.sh --verify  # Regenerate and check for drift
git diff --exit-code gen/        # Must be clean before commit
```

## GitHub Template
```bash
./scripts/template-init.sh my-project  # Create from template
./scripts/verify-tools.sh              # Check toolchain
```

## Quick Reference
- Cosmopolitan: https://github.com/jart/cosmopolitan
- Nuklear: https://github.com/Immediate-Mode-UI/Nuklear
- StateSmith: https://github.com/StateSmith/StateSmith
- Lemon: https://sqlite.org/lemon.html
- e9patch: https://github.com/GJDuck/e9patch
- Binaryen: https://github.com/WebAssembly/binaryen
- WAMR: https://github.com/bytecodealliance/wasm-micro-runtime
