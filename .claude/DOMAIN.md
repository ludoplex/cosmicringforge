# MBSE Stacks - Domain Model

## Core Concepts

### Stack
A complete toolchain configuration for MBSE code generation.

```
Stack
├── ring_0_tools[]      # Bootstrap (C+sh)
├── ring_1_tools[]      # Velocity (optional C)
├── ring_2_tools[]      # Authoring (any language)
├── spec_types[]        # Supported spec formats
└── build_profile       # portable | ape
```

### Ring Classification
Bootstrap dependency tier for tools and libraries.

| Ring | Constraint | Build Requirement |
|------|------------|-------------------|
| 0 | C + sh + make | Must build from clean checkout |
| 1 | Ring 0 + C tools | Build succeeds without |
| 2 | External toolchains | Outputs committed |

### Specification
Declarative input describing behavior, data, or interface.

```
Specification
├── type           # behavior | data | interface
├── format         # .schema | .sm | .ui | .api
├── source_path    # specs/foo.schema
└── generators[]   # Which tools process this
```

### Generator
Tool that transforms specifications into code.

```
Generator
├── name           # schemagen, statesmith
├── ring           # 0 | 1 | 2
├── input_format   # .schema, .sm
├── output_format  # .c, .h
├── toolchain      # C, .NET, Java
└── version        # For drift detection
```

## Three Specs Model

### 1. Behavior Spec
State machines, control flow, reactive logic.

```
Formats: .sm, .clips, .statechart
Generators:
  - schemagen.c (Ring 0) - Simple FSM tables
  - StateSmith (Ring 2) - Full hierarchical SM
  - CLIPS (Ring 0) - Rules engine
```

### 2. Data/Schema Spec
Type definitions, serialization, validation.

```
Formats: .schema, .proto, .idl
Generators:
  - schemagen.c (Ring 0) - Structs, validators
  - protobuf-c (Ring 2) - Protocol buffers
  - rtiddsgen (Ring 2) - DDS types
```

### 3. Interface Spec
UI layouts, external protocols, API contracts.

```
Formats: .ui, .api, .qml
Generators:
  - uigen.c (Ring 0) - Nuklear UI code
  - EEZ Studio (Ring 2) - Embedded GUI
  - Qt Design Studio (Ring 2) - Qt UI
```

## Stack Profiles

### Strict Purist
```
Purpose: Self-hostable, minimal bootstrap
Ring 0 Only: schemagen, lexgen, Lemon, Nuklear
Spec Support: .schema, .sm (simple), .ui (simple)
Build: make PROFILE=ape
Output: Single APE binary
```

### FOSS Visual
```
Purpose: Best diagram-to-C productivity
Ring 0-2: StateSmith, EEZ Studio, protobuf-c
Spec Support: Full .sm hierarchy, rich .ui
Build: make PROFILE=portable
Output: Native binary + generated source
```

### Commercial
```
Purpose: Safety-critical, certification
Ring 2: MATLAB, Rhapsody, RTI DDS
Spec Support: Vendor formats
Build: Vendor toolchain
Output: Qualified code
```

## Generated Code Structure

```
gen/
├── schemagen/
│   ├── GENERATOR_VERSION     # "schemagen 1.0.0"
│   ├── SHA256SUMS            # Checksums
│   ├── types.h               # Type definitions
│   ├── types.c               # Serialization
│   └── validators.c          # Validation functions
├── statesmith/
│   ├── GENERATOR_VERSION     # "StateSmith 0.9.14-alpha"
│   ├── machine1.h
│   └── machine1.c
└── ...
```

## Drift Detection

Ring-2 outputs are committed. Before merge:

```bash
make regen              # Regenerate all
git diff --exit-code    # Must be clean
```

If drift detected:
1. Spec changed → regenerate and commit
2. Generator updated → regenerate and commit
3. Unexpected drift → investigate

## Entity Relationships

```
Stack 1────* Generator
Generator 1────* Specification (processes)
Specification 1────* GeneratedFile (produces)
GeneratedFile *────1 DriftCheck (verified by)
```

## Build Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Specs    │────>│  Generator  │────>│  gen/*.c    │
│ .schema .sm │     │ (Ring 0-2)  │     │  (committed)│
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               v
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   src/*.c   │────>│   Compiler  │────>│   Binary    │
│ (handwritten)│    │ (cc/cosmocc)│     │ (.com/.exe) │
└─────────────┘     └─────────────┘     └─────────────┘
```

## Vendored Libraries (Ring 0)

| Library | Purpose | Size |
|---------|---------|------|
| SQLite | Database | ~230KB |
| Lemon | Parser gen | ~30KB |
| Nuklear | GUI | ~18KB |
| yyjson | JSON | ~25KB |
| CivetWeb | HTTP | ~40KB |
| CLIPS | Rules | ~100KB |
