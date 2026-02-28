# MBSE Stacks - Agent Context

> Universal context for LLM coding assistants (Claude, Copilot, Cursor, Aider, Continue, etc.)

## Overview

Model-Based Systems Engineering code generation framework. Three stacks, one philosophy: **separate authoring from shipping**.

| Stack | Purpose | Toolchain | Ring |
|-------|---------|-----------|------|
| **Strict Purist** | Self-hostable, minimal deps | C + sh + make | 0 |
| **FOSS Visual** | Best productivity | StateSmith, EEZ | 0-2 |
| **Commercial** | Safety-critical | MATLAB, Rhapsody | 2 |

## Critical Constraints

1. **Ring 0 must always build** - Only needs C compiler, sh, make
2. **Ring 2 outputs are committed** - External tool outputs checked in
3. **Dogfooding** - Generators generate themselves where possible
4. **APE-native** - Cosmopolitan builds produce universal binaries

## Tool Inventory Quick Reference

### Ring 0 (Bootstrap)

```
Generators:    schemagen, smgen, lexgen, bin2c, lemon
Libraries:     sqlite, nuklear, yyjson, civetweb, clips
Toolchain:     cc, sh, make, cosmocc (optional)
Patching:      e9patch, e9studio
```

### Ring 1 (Velocity)

```
CLI:           gengetopt, makeheaders
Analysis:      cppcheck, AddressSanitizer, UBSan, valgrind
Debug:         cosmo-disasm
```

### Ring 2 (Authoring)

```
State Machines: StateSmith (.NET), MATLAB/Simulink
Schemas:        protobuf-c (C++), rtiddsgen (Java)
UI:             EEZ Studio (Node.js), Qt Design Studio
Modeling:       OpenModelica
WASM:           Binaryen, WAMR
```

## Directory Map

```
cosmicringforge/
├── strict-purist/           # C + sh + make only
│   ├── gen/                 # In-tree generators
│   ├── vendor/              # Ring 0 libraries
│   │   ├── sqlite/
│   │   ├── lemon/
│   │   ├── nuklear/
│   │   ├── yyjson/
│   │   ├── civetweb/
│   │   ├── clips/
│   │   ├── cosmopolitan/
│   │   ├── e9patch/
│   │   ├── kilo/
│   │   └── bin2c/
│   ├── specs/               # .schema, .sm, .lex, .y
│   └── src/
├── foss-visual/             # FOSS toolchain
│   └── vendor/
│       ├── StateSmith/
│       ├── protobuf-c/
│       ├── eez-studio/
│       ├── lvgl/
│       └── openmodelica/
├── upstream/                # External projects
│   ├── e9studio/            # Binary patching IDE
│   ├── ludoplex-binaryen/   # WASM optimizer
│   ├── cosmo-sokol/         # Graphics
│   ├── cosmo-bsd/           # BSD utilities
│   └── ...
├── scripts/                 # Orchestration
│   ├── template-init.sh
│   ├── regen-all.sh
│   └── verify-tools.sh
└── templates/               # GitHub template skeleton
```

## Naming Conventions

```c
/* Functions */
{prefix}_{module}_{action}()     /* e9_ape_parse() */

/* Types */
{prefix}_{name}_t                /* e9_ape_info_t */

/* Enums */
{PREFIX}_{TYPE}_{VALUE}          /* E9_FORMAT_APE */

/* Files */
{module}.schema                  /* Data definitions */
{module}.sm                      /* State machines */
gen/{tool}/{output}.{h,c}        /* Generated code */
```

## Workflow

```bash
# 1. Edit specs
vim specs/mytype.schema specs/myfsm.sm

# 2. Regenerate
./scripts/regen-all.sh

# 3. Build
make PROFILE=portable   # or PROFILE=ape

# 4. Verify before commit
./scripts/regen-all.sh --verify
git diff --exit-code gen/
```

## GitHub Template Usage

```bash
# Initialize new project from template
./scripts/template-init.sh my-project

# Verify toolchain
./scripts/verify-tools.sh
```

## Key Documentation

| File | Purpose |
|------|---------|
| `TOOLING.md` | Complete tool inventory and orchestration |
| `RING_CLASSIFICATION.md` | Ring definitions and criteria |
| `LICENSES.md` | License tracking and compatibility |
| `CONVENTIONS.md` | Code style and conventions |
| `scripts/` | Orchestration scripts |

## See Also

- [TOOLING.md](TOOLING.md) - Full tool details
- [RING_CLASSIFICATION.md](RING_CLASSIFICATION.md) - Ring system
- [strict-purist/](strict-purist/) - Pure C stack
- [upstream/e9studio/AGENTS.md](upstream/e9studio/AGENTS.md) - e9studio context
