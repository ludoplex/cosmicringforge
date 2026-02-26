# MBSE Code Generation Stacks

Three approaches to Model-Based Systems Engineering (MBSE) code generation, organized by toolchain philosophy and bootstrap requirements.

## Architecture Principle

**Separate (A) how you author behavior/models from (B) what's required to build and ship.**

This is the only way to get both "diagram-to-C productivity" *and* "bootstrap/self-hostable C+sh purity" without the story collapsing under toolchain creep.

## The Three Stacks

| Stack | Target Use Case | Bootstrap Requirements | Certification Support |
|-------|-----------------|----------------------|----------------------|
| [Commercial MBSE](./commercial/) | Safety-critical / certification-oriented | Vendor toolchains (MATLAB, Rhapsody, etc.) | Full qualification kits |
| [FOSS Visual](./foss-visual/) | Best diagram-to-C productivity feel | Mixed (C#, Node, C++) | Community/self-qualified |
| [Strict Purist](./strict-purist/) | Self-hostable, minimal bootstrap | C + sh only | Manual process |

## Ring Classification

Tools and dependencies are classified into three rings based on bootstrap requirements:

### Ring 0: Bootstrap (must build from clean checkout with C+sh only)
- `sh`, `make`, `cc`
- In-tree generators (`schemagen.c`, `lexgen.c`, `bin2c.c`)
- Lemon parser generator (in-tree as `lemon.c` + `lempar.c`)
- Vendored runtime libs that compile as C (SQLite, CivetWeb, Nuklear, yyjson, etc.)

### Ring 1: Optional C/sh Velocity Tools
- gengetopt, makeheaders, sanitizers, etc.

### Ring 2: Authoring Appliances (may require C++/MATLAB/.NET/Node/etc.)
- Rhapsody, Simulink/Embedded Coder, StateSmith, OpenModelica
- protobuf-c generation, EEZ Studio, Flex/Bison, SWIG, GTK, etc.

**The Rule**: Ring-2 outputs must be checked in and drift-gated.

## Build Profiles

Two build profiles support different deployment scenarios:

### PROFILE=portable
- Native toolchain, system libs where needed
- Best for debugging/sanitizers, desktop GUI
- Standard compilation path

### PROFILE=ape
- cosmocc toolchain/packaging
- Single-binary distribution via Actually Portable Executable
- GUI is "best-effort/limited-surface" unless proven
- Requires APE loader installation on Linux for smoother execution

## Three Specs Model

All stacks generate from three specification types:

1. **Behavior Spec** - State machines, control flow, reactive logic
2. **Data/Schema Spec** - Type definitions, serialization, validation
3. **Interface Spec** - UI layouts, external protocols, API contracts

## Quick Start

```sh
# Clone the repository
git clone git@github.com:ludoplex/mbse-stacks.git
cd mbse-stacks

# Choose a stack and follow its README
cd strict-purist/  # or commercial/ or foss-visual/

# Run the regen-and-diff gate (required before commits)
make regen
git diff --exit-code
```

## Documentation

- [CONTRIBUTING.md](./CONTRIBUTING.md) - Definition of done rules
- [LICENSES.md](./LICENSES.md) - License tracking for all dependencies
- [RING_CLASSIFICATION.md](./RING_CLASSIFICATION.md) - Detailed ring assignment rationale

## License

This repository structure and documentation is MIT licensed. Individual tools and vendored dependencies retain their original licenses (see [LICENSES.md](./LICENSES.md)).
