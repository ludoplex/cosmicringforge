# MBSE Stacks - LLM Context

## Overview
Model-Based Systems Engineering code generation framework with three stacks:
- **Commercial**: Safety-critical, vendor toolchains (MATLAB, Rhapsody)
- **FOSS Visual**: Best diagram-to-C productivity (StateSmith, EEZ)
- **Strict Purist**: Self-hostable, C+sh only bootstrap

## Architecture Principle
Separate **authoring** (how you create models) from **shipping** (what's required to build).
Ring-2 authoring tools generate Ring-0 compatible C code that's committed and drift-gated.

## Ring Classification
| Ring | Bootstrap | Tools |
|------|-----------|-------|
| **0** | C + sh + make | schemagen, smgen, lexgen, bin2c, Lemon, SQLite, Nuklear, yyjson, CLIPS, CivetWeb, e9patch, kilo, Cosmopolitan |
| **1** | Ring 0 + C tools | gengetopt, makeheaders, cppcheck, sanitizers, cosmo-disasm |
| **2** | External toolchains | StateSmith, protobuf-c, EEZ Studio, LVGL, OpenModelica, Binaryen, WAMR, MATLAB, Rhapsody |

## Three Specs Model
1. **Behavior Spec** - State machines, control flow (`.sm`, `.clips`)
2. **Data/Schema Spec** - Types, serialization (`.schema`, `.proto`)
3. **Interface Spec** - UI layouts, protocols (`.ui`, `.api`)

## Build Profiles
```bash
make PROFILE=portable  # Native toolchain, system libs
make PROFILE=ape       # cosmocc, Actually Portable Executable
```

## Directory Structure
```
mbse-stacks/
├── strict-purist/     # C+sh only stack
│   ├── gen/           # Ring-0 generators
│   ├── vendor/        # Vendored C libraries
│   ├── src/           # Generated + hand-written code
│   └── specs/         # Behavior/Data/Interface specs
├── foss-visual/       # FOSS toolchain stack
│   ├── gen/           # Ring-2 generators (outputs committed)
│   └── ...
├── commercial/        # Vendor toolchain stack
└── .claude/           # LLM context, BDD specs
```

## Naming Conventions
- Generators: `{name}gen.c` (e.g., `schemagen.c`)
- Specs: `*.schema`, `*.sm`, `*.ui`
- Generated: `gen/{tool}/{output}.c` with `GENERATOR_VERSION`

## Key Files
| Purpose | Path |
|---------|------|
| Tool Inventory | `TOOLING.md` |
| Ring Classification | `RING_CLASSIFICATION.md` |
| License Tracking | `LICENSES.md` |
| LLM Context | `AGENTS.md` |
| Conventions | `CONVENTIONS.md` |
| BDD Specs | `.claude/features/*.feature` |
| Build System | `Makefile` |

## Orchestration Scripts
| Script | Purpose |
|--------|---------|
| `scripts/template-init.sh` | Initialize new project from template |
| `scripts/regen-all.sh` | Regenerate all generated code |
| `scripts/verify-tools.sh` | Verify toolchain availability |

## Regen-and-Diff Gate
```bash
./scripts/regen-all.sh --verify  # Regenerate and check
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
