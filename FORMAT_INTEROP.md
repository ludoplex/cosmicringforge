# Complete File Format Interoperability Matrix

**cosmo-bde — BDE with Models**

This document catalogs ALL file formats from ALL vendors and shows EXACTLY how each format can be used with every other format through the code generation pipeline.

---

## Master Format Inventory (~140 formats)

### Ring 0: In-Tree Specs (Native Generators)

| Ext | Name | Generator | Output | Input From | Feeds Into |
|-----|------|-----------|--------|------------|------------|
| `.schema` | Data Schema | schemagen | `.c`, `.h`, `.json`, `.sql` | - | `.c`, `.feature`, `.api` |
| `.def` | Definitions | defgen | `.c`, `.h` | - | `.c`, `.schema` |
| `.impl` | Implementation | implgen | `.c`, `.h` | `.schema` | `.c` |
| `.sm` | State Machine | smgen | `.c`, `.h` | - | `.c`, `.feature` |
| `.hsm` | Hierarchical SM | hsmgen | `.c`, `.h` | - | `.c`, `.feature` |
| `.msm` | Multi-level SM | msmgen | `.c`, `.h` | `.sm`, `.hsm` | `.c` |
| `.lex` | Lexer | lexgen | `.c`, `.h` | - | `.grammar` |
| `.grammar` / `.y` | Parser | Lemon | `.c`, `.h` | `.lex` | `.c` |
| `.feature` | BDD Specs | bddgen | `.c`, `.h` | `.schema`, `.sm` | `.c` (tests) |
| `.rules` | Business Rules | rulesgen | `.c`, `.h` | `.schema` | `.c` |
| `.api` | API Contract | apigen | `.c`, `.h`, `.json` | `.schema` | `.c`, `.proto` |
| `.ui` | UI Layout | uigen | `.c`, `.h` | `.schema` | `.c` |
| `.sql` | SQL Schema | sqlgen | `.c`, `.h` | `.schema` | `.c` |
| `.cfg` | Config | cfggen | `.c`, `.h` | - | `.c` |
| `.tbl` | Table | tblgen | `.c`, `.h` | - | `.c` |
| `.com` | Commands | comgen | `.c`, `.h` | `.schema` | `.c` |

### Ring 1: Velocity Tools

| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.ggo` | CLI Options | gengetopt | `.c`, `.h` | - | `.c` |
| `.h` | Headers | makeheaders | `.h` | `.c` | `.c` |
| `.c` | C Source | cppcheck | lint | - | - |
| `.c` | C Source | ASan | instrumented | - | - |
| `.c` | C Source | UBSan | instrumented | - | - |
| `.c` | C Source | TSan | instrumented | - | - |
| `.suppress` | Suppressions | cppcheck | - | - | - |
| `.cppcheck` | Config | cppcheck | - | - | - |
| `.tsan` | TSan Supp | TSan | - | - | - |

### Ring 2: FOSS Visual Tools

#### StateSmith (.NET)
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.drawio` | Draw.io Diagram | StateSmith | `.c`, `.h` | - | `.c`, `.sm` |
| `.svg` | SVG Diagram | StateSmith | `.c`, `.h` | - | `.c` |
| `.plantuml` | PlantUML | StateSmith | `.c`, `.h` | - | `.c` |
| `.csx` | C# Script | StateSmith | config | - | - |
| `.toml` | Config | StateSmith | - | - | - |

#### protobuf-c
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.proto` | Protocol Buffer | protoc | `.c`, `.h` | `.schema`, `.api` | `.c` |

#### flatcc
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.fbs` | FlatBuffers | flatcc | `.c`, `.h` | `.schema`, `.api` | `.c` |

#### EEZ Studio
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.eez-project` | EEZ Project | EEZ Studio | `.c`, `.h`, `.lvgl` | - | `.c`, `.ui` |
| `.png` | Images | EEZ Studio | `.c` (bin2c) | - | `.c` |
| `.ttf` | Fonts | EEZ Studio | `.c` (bin2c) | - | `.c` |
| `.json` | Flow | EEZ Studio | `.c` | - | `.c` |

#### LVGL
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.lvgl` | LVGL Config | LVGL | `.c`, `.h` | `.eez-project` | `.c` |
| `.ui` | SquareLine | SquareLine | `.c`, `.h` | - | `.c` |

#### OpenModelica
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.mo` | Modelica | omc | `.c`, `.h`, `.xml` | - | `.c` |
| `.mos` | Script | omc | - | - | - |
| `.mat` | Results | omc | - | - | `.mo` |
| `.xml` | Init | omc | `.c` | - | `.c` |

#### WebAssembly (Binaryen + WAMR)
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.wat` | WebAsm Text | wat2wasm | `.wasm` | - | `.c` |
| `.wasm` | WebAsm Binary | wasm2c | `.c`, `.h` | `.wat` | `.c` |
| `.wast` | Test Format | wast2json | `.json` | - | - |
| `.aot` | AOT Compiled | wamrc | binary | `.wasm` | `.c` |

#### e9patch
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.e9` | Patch Script | e9patch | binary | - | - |
| `.json` | Patch Config | e9patch | binary | - | - |

#### DDS/Cyclone
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.idl` | IDL | idlc | `.c`, `.h` | `.schema`, `.api` | `.c` |
| `.xml` | QoS | DDS | - | - | - |

#### mruby
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.rb` | Ruby Script | mrbc | `.c`, `.mrb` | - | `.c` |
| `.mrb` | Bytecode | mruby | - | `.rb` | `.c` |
| `.gembox` | Config | mruby | - | - | - |

#### CLIPS
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.clp` | CLIPS Rules | CLIPS | runtime | `.rules` | `.c` |
| `.bat` | Batch | CLIPS | - | - | - |

### Ring 2: Commercial Tools

#### MATLAB/Simulink/Embedded Coder
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.slx` | Simulink Model | slbuild | `.c`, `.h` | - | `.c` |
| `.mdl` | Legacy Model | slbuild | `.c`, `.h` | - | `.c` |
| `.m` | MATLAB Script | codegen | `.c`, `.h` | - | `.c` |
| `.mlx` | Live Script | MATLAB | `.m` | - | `.c` |
| `.mat` | Data | MATLAB | `.c` (embedded) | - | `.c` |
| `.sfx` | Stateflow | slbuild | `.c`, `.h` | - | `.c` |
| `.tlc` | Target Lang | TLC | `.c`, `.h` | - | `.c` |
| `.rtw` | RTW File | slbuild | - | - | `.c` |
| `.prj` | Project | MATLAB | - | - | - |
| `.sldd` | Data Dict | Simulink | - | - | `.slx` |
| `.ssc` | Simscape | Simulink | `.c` | - | `.c` |
| `.sscp` | Simscape Parts | Simulink | `.c` | - | `.c` |
| `.slxp` | Protected Model | Simulink | ref | - | `.slx` |
| `.slxc` | Cache | Simulink | - | - | - |
| `.mexw64/.mexa64` | MEX | MATLAB | - | `.c` | runtime |
| `.mlapp` | App Designer | MATLAB | - | - | - |
| `.mlappinstall` | Install | MATLAB | - | - | - |
| `.p` | P-Code | pcode | - | `.m` | - |
| `.fig` | Figure | MATLAB | - | - | - |
| `.rpt` | Report | Report Gen | docs | - | - |
| `.sltx` | Test Harness | Simulink | `.slx` | - | `.c` |

#### IBM Rhapsody
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.emx` | EMF Model | rhapsodycl | `.c`, `.h` | - | `.c` |
| `.epx` | Project | Rhapsody | - | - | `.emx` |
| `.rpyx` | Profile | Rhapsody | - | - | `.emx` |
| `.efx` | Fragment | Rhapsody | - | `.emx` | `.emx` |
| `.sbs` | Subsystem | Rhapsody | `.c`, `.h` | - | `.c` |
| `.cls` | Class | Rhapsody | `.c`, `.h` | - | `.c` |
| `.stm` | Statechart | Rhapsody | `.c`, `.h` | - | `.c` |
| `.ssd` | Sequence | Rhapsody | docs | - | - |
| `.ucd` | Use Case | Rhapsody | docs | - | - |
| `.cld` | Collaboration | Rhapsody | docs | - | - |
| `.odd` | Object | Rhapsody | docs | - | - |
| `.cmpd` | Component | Rhapsody | `.c`, `.h` | - | `.c` |
| `.dpd` | Deployment | Rhapsody | config | - | - |
| `.rqd` | Requirements | Rhapsody | docs | - | - |
| `.rpy` | Legacy | Rhapsody | - | - | `.emx` |

#### Qt Design Studio
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.qml` | QML UI | qmlc | C++ | - | `.c` (via wrapper) |
| `.ui.qml` | Form | Qt Creator | `.qml` | - | C++ |
| `.qmlproject` | Project | Qt | - | - | - |
| `.qmltypes` | Types | Qt | - | - | `.qml` |
| `.qrc` | Resources | rcc | `.cpp`, `.h` | - | C++ |
| `.ts` | Translation | lrelease | `.qm` | - | `.qrc` |
| `.qm` | Compiled Trans | - | - | `.ts` | `.qrc` |
| `.ui` | Qt Designer | uic | `.h` | - | C++ |
| `.pro` | qmake Project | qmake | Makefile | - | - |
| `.qbs` | Qbs Build | qbs | - | - | - |
| `.cmake` | CMake | cmake | Makefile | - | - |

#### RTI Connext DDS
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.idl` | IDL | rtiddsgen | `.c`, `.h` | `.schema`, `.api` | `.c` |
| `.xml` | Type Def | rtiddsgen | `.c`, `.h` | - | `.c` |
| `.lua` | Type Def | rtiddsgen | `.c`, `.h` | - | `.c` |
| `.json` | Type Def | rtiddsgen | `.c`, `.h` | - | `.c` |
| `.xsd` | Schema | - | - | - | `.xml` |
| `.qos` | QoS Profile | DDS | - | - | - |
| `.rtps` | Capture | DDS | - | - | - |

#### NI LabVIEW/VeriStand
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.vi` | Virtual Instr | LabVIEW | `.c`, `.dll` | - | `.c` |
| `.lvproj` | Project | LabVIEW | - | - | - |
| `.lvlib` | Library | LabVIEW | - | - | - |
| `.lvclass` | Class | LabVIEW | - | - | - |
| `.ctl` | Control | LabVIEW | - | - | `.vi` |
| `.lvlps` | Palette | LabVIEW | - | - | - |
| `.nivsdf` | VeriStand | VeriStand | `.c` | - | `.c` |
| `.nivssdf` | System Def | VeriStand | - | - | - |

#### dSPACE
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.sdf` | System Desc | TargetLink | `.c`, `.h` | - | `.c` |
| `.tl` | TargetLink | TargetLink | `.c`, `.h` | `.slx` | `.c` |
| `.cdd` | ConfigDesk | ConfigDesk | - | - | - |
| `.cdp` | ConfigDesk Proj | ConfigDesk | - | - | - |
| `.a2l` | ASAM A2L | TargetLink | calibration | - | - |
| `.dcm` | Calibration | - | - | `.a2l` | - |

#### ETAS ASCET
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.asd` | ASCET Model | ASCET | `.c`, `.h` | - | `.c` |
| `.exp` | Experiment | ASCET | - | - | - |
| `.prj` | Project | ASCET | - | - | - |

#### SCADE Suite
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.scade` | SCADE Model | KCG | `.c`, `.h` | - | `.c` |
| `.etp` | Project | SCADE | - | - | - |
| `.sdy` | Display | SCADE | - | - | - |
| `.ssm` | State Machine | SCADE | `.c`, `.h` | - | `.c` |
| `.ann` | Annotations | SCADE | - | - | `.scade` |

#### PTC Integrity Modeler
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.uml` | UML Model | Modeler | `.c`, `.h` | - | `.c` |
| `.xmi` | XMI Export | Modeler | - | - | - |
| `.zip` | Archive | Modeler | - | - | - |

#### Enterprise Architect
| Ext | Name | Tool | Output | Input From | Feeds Into |
|-----|------|------|--------|------------|------------|
| `.eapx` | EA Project | EA | `.c`, `.h`, `.xmi` | - | `.c` |
| `.eap` | Legacy | EA | - | - | `.eapx` |
| `.xmi` | XMI Export | EA | - | - | - |
| `.qea` | Cloud | EA | - | - | - |

---

## Format Interoperability Flows

### Data Schema Flow
```
.schema ─┬─> schemagen ─┬─> .c/.h (structs)
         │              ├─> .json (yyjson)
         │              ├─> .sql (SQLite)
         │              └─> .proto (protobuf-c)
         │
         ├─> .feature (bddgen tests)
         ├─> .api (apigen contracts)
         └─> .idl (DDS type definitions)
```

### State Machine Flow
```
.sm ─────┬─> smgen ─────────────> .c/.h
.hsm ────┤
.drawio ─┴─> StateSmith ─────────> .c/.h
.sfx ────────> Embedded Coder ───> .c/.h
.stm ────────> Rhapsody ─────────> .c/.h
.ssm ────────> SCADE ────────────> .c/.h
                    │
                    └─> All feed into same .c application
```

### Parser/Lexer Flow
```
.lex ────> lexgen ─┐
                   ├─> combined parser ─> .c/.h
.grammar ─> Lemon ─┘

.y ───────> Bison ─┐
.l ───────> Flex ──┴─> combined parser ─> .c/.h
```

### UI/GUI Flow
```
.ui ─────────> uigen ────────────> .c/.h (Nuklear)
.eez-project ─> EEZ Studio ──────> .c/.h (LVGL)
.qml ────────> Qt ───────────────> .cpp/.h
.slx (HMI) ──> Simulink ─────────> .c/.h
```

### Serialization Flow
```
.schema ──┬─> schemagen --json ──> .c (yyjson)
          ├─> schemagen --sql ───> .c (SQLite)
          │
          ├─> .proto ─> protoc ──> .c (protobuf-c)
          ├─> .fbs ──> flatcc ───> .c (FlatBuffers)
          └─> .idl ──> idlc ─────> .c (DDS)
```

### BDD/Testing Flow
```
.feature ──> bddgen ─────────> test_*.c
                │
                └─> Uses types from:
                    .schema → example_types.h
                    .sm → statemachine.h
```

### Cross-Vendor Interop
```
┌─────────────────────────────────────────────────────────────────────────┐
│                     VENDOR → C OUTPUT → UNIFIED APP                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  MATLAB/Simulink (.slx)                                                 │
│       ↓ Embedded Coder                                                  │
│       ↓                                                                 │
│  IBM Rhapsody (.emx)                                                    │
│       ↓ rhapsodycl                                                      │
│       ↓                                                                 │
│  StateSmith (.drawio)    ───────────────────────────┐                   │
│       ↓ StateSmith CLI                              │                   │
│       ↓                                             ↓                   │
│  EEZ Studio (.eez-project)                    gen/imported/*.c          │
│       ↓ EEZ generator                               │                   │
│       ↓                                             │                   │
│  OpenModelica (.mo)                                 │                   │
│       ↓ omc                                         │                   │
│       ↓                                             ↓                   │
│  cosmo-bde (.schema, .sm)              gen/domain/*.c             │
│       ↓ Ring 0 generators                           │                   │
│       ↓                                             │                   │
│       └─────────────────────────────────────────────┴──> cosmocc ──> APE│
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Concrete Interop Examples

### Example 1: Schema → Multiple Outputs
```bash
# Define once in .schema
type SensorData {
    timestamp: u64
    temperature: f32
    humidity: f32
}

# Generate multiple formats
build/schemagen specs/domain/sensor.schema gen/domain sensor --json --sql --proto

# Outputs:
#   gen/domain/sensor_types.h      (C struct)
#   gen/domain/sensor_types.c      (init/validate)
#   gen/domain/sensor_json.c       (yyjson serialization)
#   gen/domain/sensor_sql.c        (SQLite binding)
#   gen/proto/sensor.proto         (protobuf definition)
```

### Example 2: State Machine → BDD Tests
```bash
# Define state machine
# specs/behavior/door.sm

# Define BDD tests that reference it
# specs/testing/door.feature
Feature: Door Controller
  Scenario: Open when unlocked
    Given the door is in "Closed" state
    When the user sends "Open" command
    Then the door transitions to "Opening" state

# Generate both
build/smgen specs/behavior/door.sm gen/behavior door
build/bddgen specs/testing/door.feature gen/testing door

# Test references generated types
# gen/testing/door_bdd.c includes gen/behavior/door_sm.h
```

### Example 3: Vendor SM → Native Integration
```bash
# StateSmith generates from .drawio
statesmith run model/statesmith/motor.drawio --lang=C99 -o gen/imported/statesmith/

# Native code uses both vendor and Ring 0 outputs
#include "gen/imported/statesmith/motor_sm.h"  // From StateSmith
#include "gen/domain/motor_types.h"            // From schemagen

void motor_update(Motor *m) {
    // Mix vendor and native code
    motor_sm_step(&m->sm);
    Motor_validate(m);
}
```

### Example 4: Simulink + Rhapsody + Native
```bash
# gen/imported/simulink/ ─── from MATLAB/Embedded Coder
# gen/imported/rhapsody/ ─── from IBM Rhapsody
# gen/domain/           ─── from Ring 0 generators

# main.c ties it all together
#include "gen/imported/simulink/controller_ert.h"
#include "gen/imported/rhapsody/system_model.h"
#include "gen/domain/config_types.h"

int main() {
    controller_initialize();   // Simulink
    system_model_init();       // Rhapsody
    Config cfg;
    Config_init(&cfg);         // Native schemagen

    while (running) {
        controller_step();
        system_model_step();
    }
}
```

---

## Automation Scripts

### Universal Regen Script (Already Implemented)
```bash
# scripts/regen-all.sh auto-detects ALL tools:

# Ring 0: Always available
schemagen, defgen, smgen, hsmgen, lexgen, Lemon, bddgen, rulesgen

# Ring 2 FOSS: Auto-detected
StateSmith (dotnet), protobuf-c (protoc), flatcc, OpenModelica (omc)

# Ring 2 Commercial: Auto-detected
Embedded Coder (matlab), Rhapsody (rhapsodycl), Qt (qmlc), RTI (rtiddsgen)
```

### Format Discovery Script
```bash
#!/bin/sh
# scripts/discover-formats.sh - Find all processable formats

echo "Ring 0 Specs:"
find specs -name "*.schema" -o -name "*.def" -o -name "*.sm" \
           -o -name "*.hsm" -o -name "*.lex" -o -name "*.y" \
           -o -name "*.feature" -o -name "*.rules" -o -name "*.api"

echo "Ring 2 Models:"
find model -name "*.drawio" -o -name "*.proto" -o -name "*.fbs" \
           -o -name "*.mo" -o -name "*.slx" -o -name "*.emx" \
           -o -name "*.eez-project" -o -name "*.idl"
```

---

## Literate Documentation Conventions

### Spec File Headers
All spec files follow this pattern:
```
/* ═══════════════════════════════════════════════════════════════════════
 * FILENAME.EXT — Purpose
 * ═══════════════════════════════════════════════════════════════════════
 *
 * @desc     Brief description
 * @author   Author name
 * @version  1.0.0
 * @feeds    What formats/files this feeds into
 * @uses     What formats/files this consumes
 *
 * ═══════════════════════════════════════════════════════════════════════
 */
```

### Generated File Headers
All generated files include:
```c
/* AUTO-GENERATED by {generator} {version} — DO NOT EDIT
 * Source: {source_file}
 * Generated: {timestamp}
 * Feeds: {downstream_files}
 */
```

### Traceability Tags
```c
/* @source specs/domain/example.schema:15 */
/* @trace REQ-FUNC-042 */
/* @feature specs/testing/example.feature:23 */
```

---

## Universal Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         UNIFIED WORKFLOW                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. AUTHOR (Ring 0, 1, or 2 tools - your choice)                        │
│     └── Edit specs/ or model/ files                                     │
│                                                                         │
│  2. REGENERATE (auto-detects available tools)                           │
│     └── make regen                                                      │
│                                                                         │
│  3. VERIFY (drift gate)                                                 │
│     └── make verify  # git diff --exit-code gen/                        │
│                                                                         │
│  4. BUILD (always Ring 0, cosmocc optional)                             │
│     └── make         # or CC=cosmocc make                               │
│                                                                         │
│  5. TEST (BDD from .feature specs)                                      │
│     └── make test                                                       │
│                                                                         │
│  6. COMMIT (gen/ is checked in, drift-gated)                            │
│     └── git add -A && git commit                                        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Ring 0 Native Specs | 16 |
| Ring 1 Tool Formats | 8 |
| Ring 2 FOSS Formats | 28 |
| Ring 2 Commercial Formats | 88 |
| **Total Unique Formats** | **~140** |

All paths lead to `.c` → `cosmocc` → APE binary.
