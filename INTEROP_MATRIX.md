# Complete Format Interoperability Matrix

**CosmicRingForge — BDE with Models**

> **GROUND TRUTH DOCUMENT** — This is the single source of truth for format relationships.

---

## Required Reading

Before working with CosmicRingForge, read these documents in order:

| Document | Purpose | Why Required |
|----------|---------|--------------|
| **RING_CLASSIFICATION.md** | Tool rings, portability, cosmocc | Understand the bootstrap hierarchy |
| **INTEROP_MATRIX.md** (this) | Format relationships | Understand what generates what |
| **LITERATE.md** | Conventions, traceability | Understand naming and structure |

---

## The Key Insight

Every format exists in relationship to other formats. Understanding these relationships enables:
1. **Automated dependency tracking** - what must regenerate when a source changes
2. **Literate traceability** - every output links back to its inputs
3. **Universal workflow** - one script handles all format transitions
4. **Self-documenting builds** - the makefile IS the documentation

---

## Format Categories by Role

### SOURCE (Authored by humans or tools)
Specs and models that humans or Ring 2 tools create.

### INTERMEDIATE (Generated, may feed others)
Formats generated that become inputs to other generators.

### TERMINAL (Final C code for compilation)
The `.c` and `.h` files that compile into the application.

---

## Complete Format Inventory

### Category: DATA DEFINITION

| Format | Role | Generator | Consumes | Produces | Notes |
|--------|------|-----------|----------|----------|-------|
| `.schema` | SOURCE | human | - | `.c`, `.h`, `.json`, `.sql`, `.proto`, `.fbs`, `.idl` | Master data definition |
| `.def` | SOURCE | human | - | `.c`, `.h` | Constants, enums, X-Macros |
| `.proto` | INTERMEDIATE | protoc | `.schema` | `.c`, `.h` | Wire protocol |
| `.fbs` | INTERMEDIATE | flatcc | `.schema` | `.c`, `.h` | Zero-copy serialization |
| `.idl` | INTERMEDIATE | idlc/rtiddsgen | `.schema` | `.c`, `.h` | DDS type definition |
| `.json` | INTERMEDIATE | schemagen | `.schema` | `.c` (yyjson binding) | Config, exchange |
| `.sql` | INTERMEDIATE | schemagen | `.schema` | `.c` (SQLite binding) | Persistence |
| `.xml` | INTERMEDIATE | various | `.schema` | config | Config, exchange |
| `.yaml` | INTERMEDIATE | various | `.schema` | config | Config, exchange |
| `.mat` | INTERMEDIATE | MATLAB | `.slx` | embedded data | Simulation data |

### Category: BEHAVIOR DEFINITION

| Format | Role | Generator | Consumes | Produces | Notes |
|--------|------|-----------|----------|----------|-------|
| `.sm` | SOURCE | human | - | `.c`, `.h`, `.feature` | Flat state machine |
| `.hsm` | SOURCE | human | - | `.c`, `.h` | Hierarchical state machine |
| `.msm` | SOURCE | human | `.sm`, `.hsm` | `.c`, `.h` | Multi-level composition |
| `.drawio` | SOURCE | StateSmith | - | `.c`, `.h` | Visual state machine |
| `.plantuml` | SOURCE | StateSmith | - | `.c`, `.h` | Text-based UML SM |
| `.sfx` | SOURCE | Stateflow | - | `.c`, `.h` | Simulink state machine |
| `.stm` | SOURCE | Rhapsody | - | `.c`, `.h` | Rhapsody statechart |
| `.ssm` | SOURCE | SCADE | - | `.c`, `.h` | SCADE state machine |
| `.clp` | SOURCE | CLIPS | `.rules` | runtime | Rule-based behavior |
| `.rules` | SOURCE | human | `.schema` | `.c`, `.h`, `.clp` | Business rules |
| `.mo` | SOURCE | OpenModelica | - | `.c`, `.h`, `.xml` | Physics/continuous |

### Category: INTERFACE DEFINITION

| Format | Role | Generator | Consumes | Produces | Notes |
|--------|------|-----------|----------|----------|-------|
| `.api` | SOURCE | human | `.schema` | `.c`, `.h`, `.json`, `.proto` | API contract |
| `.ggo` | SOURCE | human | - | `.c`, `.h` | CLI options |
| `.ui` | SOURCE | human | `.schema` | `.c`, `.h` | UI layout (Nuklear) |
| `.eez-project` | SOURCE | EEZ Studio | - | `.c`, `.h`, `.lvgl` | Embedded UI |
| `.qml` | SOURCE | Qt | - | `.cpp`, `.h` | Qt UI |
| `.lvgl` | INTERMEDIATE | EEZ Studio | `.eez-project` | `.c`, `.h` | LVGL config |

### Category: PARSING DEFINITION

| Format | Role | Generator | Consumes | Produces | Notes |
|--------|------|-----------|----------|----------|-------|
| `.lex` | SOURCE | human | - | `.c`, `.h` | Lexer tokens |
| `.grammar` / `.y` | SOURCE | human | `.lex` | `.c`, `.h` | Parser (LALR) |
| `.l` | SOURCE | human | - | `.c` | Flex lexer |
| `.re` | SOURCE | human | - | `.c` | re2c lexer |

### Category: TESTING/VERIFICATION

| Format | Role | Generator | Consumes | Produces | Notes |
|--------|------|-----------|----------|----------|-------|
| `.feature` | SOURCE | human | `.schema`, `.sm` | `.c` (tests) | BDD scenarios |
| `.suppress` | SOURCE | human | - | config | cppcheck suppressions |
| `.cppcheck` | SOURCE | human | - | config | Static analysis config |
| `.tsan` | SOURCE | human | - | config | Thread sanitizer supp |

### Category: BUILD/CONFIG

| Format | Role | Generator | Consumes | Produces | Notes |
|--------|------|-----------|----------|----------|-------|
| `.cfg` | SOURCE | human | - | `.c`, `.h` | Configuration |
| `.tbl` | SOURCE | human | - | `.c`, `.h` | Table definitions |
| `.impl` | SOURCE | human | `.schema` | `.c`, `.h` | Platform hints |
| `.com` | SOURCE | human | `.schema` | `.c`, `.h` | Command definitions |

### Category: TERMINAL (C Code Output)

| Format | Role | Generator | Consumes | Produces | Notes |
|--------|------|-----------|----------|----------|-------|
| `.c` | TERMINAL | all generators | varies | `.o` | Implementation |
| `.h` | TERMINAL | all generators | varies | - | Interface |
| `.o` | TERMINAL | compiler | `.c` | binary | Object code |

---

## Interoperability Matrix: Which Formats Feed Which

### Row = Source, Column = Can Produce

```
                 PRODUCES →
                 .c  .h  .json .sql .proto .fbs .idl .feature .clp
CONSUMES ↓
─────────────────────────────────────────────────────────────────────
.schema          ✓   ✓   ✓     ✓    ✓      ✓    ✓    →        →
.def             ✓   ✓
.sm              ✓   ✓                            →    →
.hsm             ✓   ✓                                 →
.drawio          ✓   ✓
.rules           ✓   ✓                                          ✓
.feature         ✓
.lex             ✓   ✓
.grammar         ✓   ✓
.ggo             ✓   ✓
.api             ✓   ✓   ✓          ✓
.ui              ✓   ✓
.proto           ✓   ✓
.fbs             ✓   ✓
.idl             ✓   ✓
.mo              ✓   ✓
.slx             ✓   ✓
.emx             ✓   ✓
.eez-project     ✓   ✓

Legend: ✓ = directly produces, → = references/uses types from
```

### Dependency Graph (ASCII)

```
                    ┌─────────────────────────────────────────┐
                    │           SOURCE SPECS                   │
                    │  .schema  .sm  .rules  .lex  .grammar   │
                    │  .def     .hsm .api    .ggo  .feature   │
                    │  .ui      .cfg .com    .impl .tbl       │
                    └──────────────────┬──────────────────────┘
                                       │
                    ┌──────────────────┼──────────────────────┐
                    │                  │                      │
                    ▼                  ▼                      ▼
          ┌─────────────────┐  ┌─────────────┐    ┌────────────────┐
          │ RING 0 GENS     │  │ RING 2 FOSS │    │ RING 2 COMMERCIAL│
          │ schemagen       │  │ StateSmith  │    │ Simulink       │
          │ smgen           │  │ protobuf-c  │    │ Rhapsody       │
          │ bddgen          │  │ flatcc      │    │ SCADE          │
          │ Lemon           │  │ OpenModelica│    │ Qt             │
          └────────┬────────┘  └──────┬──────┘    └───────┬────────┘
                   │                  │                   │
                   │    INTERMEDIATE FORMATS              │
                   │    .proto .fbs .idl .json .sql       │
                   │                  │                   │
                   └──────────────────┼───────────────────┘
                                      │
                                      ▼
                    ┌─────────────────────────────────────────┐
                    │           TERMINAL: gen/**/*.c          │
                    │  gen/domain/        gen/imported/       │
                    │  gen/behavior/      gen/statesmith/     │
                    │  gen/interface/     gen/simulink/       │
                    │  gen/parsing/       gen/rhapsody/       │
                    └──────────────────┬──────────────────────┘
                                       │
                                       ▼
                    ┌─────────────────────────────────────────┐
                    │           cosmocc / cc                   │
                    │                                          │
                    │              APE BINARY                  │
                    └─────────────────────────────────────────┘
```

---

## The Critical Relationships

### 1. Schema is the Root
`.schema` can feed into EVERY serialization format:
```
.schema ──┬──> .c/.h      (schemagen native)
          ├──> .json      (schemagen --json → yyjson)
          ├──> .sql       (schemagen --sql → SQLite)
          ├──> .proto     (schemagen --proto → protobuf)
          ├──> .fbs       (schemagen --fbs → FlatBuffers)
          └──> .idl       (schemagen --idl → DDS)
```

### 2. State Machines are Interchangeable Sources
```
.sm ────────┐
.hsm ───────┤
.drawio ────┼──> gen/{layer}/*_sm.c,h
.sfx ───────┤
.stm ───────┤
.ssm ───────┘

All produce equivalent C state machine code.
Different authoring, same output structure.
```

### 3. BDD Tests Reference Generated Types
```
.feature ──> bddgen ──> test_*.c
                         │
                         ├── #include "example_types.h"  (from .schema)
                         ├── #include "door_sm.h"        (from .sm)
                         └── #include "sensor_types.h"   (from .schema)
```

### 4. Parsers Compose Lexer + Grammar
```
.lex ──> lexgen ──> *_lex.c,h ─┐
                                ├──> combined_parser.c
.grammar ──> Lemon ──> *_parse.c,h ─┘
```

### 5. Multi-Vendor SM Composition
```
model/simulink/motor_control.slx ──> gen/imported/simulink/motor_control.c
model/statesmith/safety_fsm.drawio ──> gen/imported/statesmith/safety_fsm.c
specs/behavior/supervisor.sm ──> gen/behavior/supervisor_sm.c

src/main.c:
  #include "gen/imported/simulink/motor_control.h"
  #include "gen/imported/statesmith/safety_fsm.h"
  #include "gen/behavior/supervisor_sm.h"

  // All three state machines run together
```

---

## Format-Driven Automation

### Makefile Pattern: Format Discovery
```makefile
# Discover all source formats
SCHEMAS := $(shell find specs -name "*.schema")
STATEMACHINES := $(shell find specs -name "*.sm" -o -name "*.hsm")
FEATURES := $(shell find specs -name "*.feature")
GRAMMARS := $(shell find specs -name "*.y" -o -name "*.grammar")
LEXERS := $(shell find specs -name "*.lex")

# Ring 2 sources (visual models)
DRAWIO := $(shell find model -name "*.drawio" 2>/dev/null)
SIMULINK := $(shell find model -name "*.slx" 2>/dev/null)
MODELICA := $(shell find model -name "*.mo" 2>/dev/null)
```

### Regen Rule Pattern
```makefile
# Pattern: source → generator → output
gen/domain/%_types.c gen/domain/%_types.h: specs/domain/%.schema
	$(BUILD_DIR)/schemagen $< gen/domain $*

gen/behavior/%_sm.c gen/behavior/%_sm.h: specs/behavior/%.sm
	$(BUILD_DIR)/smgen $< gen/behavior $*

gen/testing/%_bdd.c: specs/testing/%.feature
	$(BUILD_DIR)/bddgen $< gen/testing $*
```

### Dependency Declaration
```makefile
# BDD tests depend on types they reference
gen/testing/door_bdd.c: gen/behavior/door_sm.h gen/domain/door_types.h

# Parser depends on lexer
gen/parsing/config_parse.c: gen/parsing/config_lex.h
```

---

## Literate Traceability

### Every Generated File Contains
```c
/* ═══════════════════════════════════════════════════════════════════════
 * AUTO-GENERATED — DO NOT EDIT
 * ═══════════════════════════════════════════════════════════════════════
 * Generator:  schemagen 1.0.0
 * Source:     specs/domain/sensor.schema
 * Generated:  2024-02-28T14:30:00Z
 *
 * Dependencies (this file uses types from):
 *   - (none - root type)
 *
 * Dependents (files that include this):
 *   - gen/testing/sensor_bdd.c
 *   - gen/interface/sensor_api.c
 *   - src/sensor_driver.c
 *
 * Regenerate with: make regen
 * ═══════════════════════════════════════════════════════════════════════
 */
```

### Cross-Reference Tags
```c
/* @source specs/domain/sensor.schema:15-23 */
typedef struct Sensor {
    /* @field temperature - specs/domain/sensor.schema:17 */
    float temperature;
    /* @field humidity - specs/domain/sensor.schema:18 */
    float humidity;
} Sensor;

/* @feature specs/testing/sensor.feature:12 "Given a valid sensor reading" */
void Sensor_init(Sensor *s) { ... }
```

---

## Universal Convention: File Naming

### Pattern: `{entity}_{role}.{ext}`

| Role | Suffix | Example |
|------|--------|---------|
| Types | `_types` | `sensor_types.c` |
| State Machine | `_sm` | `door_sm.c` |
| Parser | `_parse` | `config_parse.c` |
| Lexer | `_lex` | `config_lex.c` |
| BDD Tests | `_bdd` | `sensor_bdd.c` |
| JSON | `_json` | `sensor_json.c` |
| SQL | `_sql` | `sensor_sql.c` |
| API | `_api` | `sensor_api.c` |

### Directory Convention
```
gen/
├── domain/           # From .schema, .def
├── behavior/         # From .sm, .hsm
├── interface/        # From .api, .ggo
├── parsing/          # From .lex, .grammar
├── testing/          # From .feature
├── persistence/      # From .schema --sql
├── serialization/    # From .proto, .fbs
└── imported/         # From Ring 2 tools
    ├── statesmith/
    ├── simulink/
    ├── rhapsody/
    ├── openmodelica/
    └── eez/
```

---

## What This Means for GitHub Template

1. **The template IS the specification** - directory structure encodes format relationships
2. **Makefile discovers formats** - no manual list of files
3. **regen-all.sh is universal** - handles any combination of formats
4. **Generated code is self-documenting** - includes traceability headers
5. **CI verifies drift** - any format change triggers full regen
6. **README generated from structure** - introspect specs/ and model/ to build docs

The next step is making the Makefile truly format-driven rather than file-list-driven.
