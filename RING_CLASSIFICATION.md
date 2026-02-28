# Ring Classification

> **BDE with Models** — Behavior Driven Engineering with Models.

Tools and dependencies are classified into three rings based on their bootstrap requirements and toolchain dependencies. All rings output C code that compiles with cosmocc.

---

## Classification Criteria

| Ring | Bootstrap Requirement | Toolchain | Outputs |
|------|----------------------|-----------|---------|
| **Ring 0** | C compiler + sh + make | Pure C | May be regenerated or committed |
| **Ring 1** | Ring 0 + optional C tools | C + utilities | Regenerated on demand |
| **Ring 2** | External toolchains | C++, .NET, Java, MATLAB, etc. | **Must be committed** |

---

## Ring 0: Bootstrap Layer

**Requirement**: Must build from clean checkout with only `sh`, `make`, and a C compiler.

### In-Tree Generators

| Tool | Purpose | Source |
|------|---------|--------|
| `schemagen.c` | Generate struct definitions, serializers, validators from `schema.def` | Local |
| `lexgen.c` | Generate table-driven lexer from token definitions | Local |
| `bin2c.c` | Embed binary resources as C arrays | Local |

### Vendored Libraries (C source, compile directly)

| Library | License | Purpose | Source |
|---------|---------|---------|--------|
| SQLite | Public Domain | Embedded database | [sqlite.org](https://sqlite.org) |
| Lemon | Public Domain | LALR(1) parser generator | [sqlite.org/lemon.html](https://sqlite.org/lemon.html) |
| CivetWeb | MIT | Embedded HTTP server | [GitHub](https://github.com/civetweb/civetweb) |
| Nuklear | MIT/Public Domain | Immediate-mode GUI | [GitHub](https://github.com/Immediate-Mode-UI/Nuklear) |
| yyjson | MIT | Fast JSON parser | [GitHub](https://github.com/ibireme/yyjson) |
| CLIPS | Public Domain | Rules/expert system engine | [clipsrules.net](https://www.clipsrules.net) |

### Build Tools

| Tool | Purpose |
|------|---------|
| `sh` | Shell scripting |
| `make` | Build orchestration |
| `cc` | C compiler (gcc, clang, tcc, cosmocc) |

### Cosmopolitan/APE (Optional Profile)

| Tool | License | Notes |
|------|---------|-------|
| cosmocc | ISC | Cross-platform C compiler |
| APE | ISC | Actually Portable Executable format |

**Note**: APE binaries run on Linux, macOS, Windows, FreeBSD, OpenBSD, NetBSD on AMD64 and ARM64. Linux may require APE loader installation for smoother execution.

---

## Ring 1: Velocity Tools

**Requirement**: Ring 0 + additional C-based tools that enhance productivity but aren't strictly required.

| Tool | Purpose | Fallback | Spec File |
|------|---------|----------|-----------|
| gengetopt | CLI argument parser generator | Hand-written parser | `ring1/gengetopt.schema` |
| makeheaders | Auto-generate header files | Manual headers | - |
| AddressSanitizer | Memory error detection | Valgrind or manual testing | `ring1/sanitizers.schema` |
| UBSan | Undefined behavior detection | Manual code review | `ring1/sanitizers.schema` |
| ThreadSanitizer | Data race detection | Manual review | `ring1/sanitizers.schema` |
| cppcheck | Static analysis | Manual review | `ring1/cppcheck.schema` |

### Ring 1 Spec Files

```
strict-purist/specs/ring1/
├── gengetopt.schema    # Meta-spec: what .ggo files contain
├── gengetopt.ggo       # Example CLI specification
├── cppcheck.schema     # Static analysis configuration
└── sanitizers.schema   # Sanitizer options and suppressions
```

### Ring 1 Make Targets

```makefile
gen-cli:    gengetopt < specs/cli.ggo > gen/cmdline.c
lint:       cppcheck --enable=all src/
sanitize:   $(CC) -fsanitize=address,undefined $(SRCS)
```

**Rule**: If a Ring-1 tool is unavailable, the build must still succeed (possibly with reduced functionality or skipped checks).

---

## Ring 2: Authoring Appliances

**Requirement**: These tools require non-C toolchains. Their **outputs must be committed** to the repository.

### Ring 2 Spec Files

```
foss-visual/specs/
├── statesmith.schema        # StateSmith configuration
├── protobuf.schema          # Protocol Buffer structure
├── eez-studio.schema        # EEZ UI definition
├── openmodelica.schema      # Modelica model structure
├── wasm.schema              # Binaryen + WAMR configuration
└── examples/
    ├── blinker.drawio.notes # StateSmith example notes
    ├── message.proto        # Protobuf example
    └── pendulum.mo          # Modelica example
```

### State Machine Generators

| Tool | Toolchain Required | Generated Code | License | Spec File |
|------|--------------------|----------------|---------|-----------|
| StateSmith | .NET (C#) | Zero-dependency C | Apache-2.0 | `statesmith.schema` |
| IBM Rhapsody | IBM installation | C/C++ | Commercial | - |
| Simulink/Stateflow | MATLAB | C/C++ (via Embedded Coder) | Commercial | - |

#### StateSmith Notes
- Tool is implemented in C# (see [GitHub language breakdown](https://github.com/StateSmith/StateSmith))
- Generated code has **zero runtime dependencies**
- Human-readable output
- Perfect for Ring-2 authoring → Ring-0 generated code

### Data/Schema Generators

| Tool | Toolchain Required | Generated Code | License |
|------|--------------------|----------------|---------|
| protobuf-c | C++ compiler, protobuf, pkg-config | C serialization code | BSD-2-Clause |
| rtiddsgen (RTI DDS) | Java | Type support code from IDL/XML/XSD | Commercial |
| OpenModelica | C++ (build), OCaml (parts) | C simulation code | OSMC-PL |

#### protobuf-c Notes
Per the [build documentation](https://github.com/protobuf-c/protobuf-c):
> Requires a C compiler, a C++ compiler, protobuf, and pkg-config

This is why it's Ring-2, not Ring-0.

#### rtiddsgen Notes
Per [RTI documentation](https://community.rti.com/static/documentation/connext-dds/6.1.2/doc/api/connext_dds/api_c/group__DDSNddsgenModule.html):
- Generates **type support code** from IDL/XML/XSD
- Includes: allocation, send/receive helpers, printing utilities
- Does **not** generate the entire networking stack—you still integrate DDS runtime + QoS config

### UI/Visual Editors

| Tool | Toolchain Required | Generated Code | License |
|------|--------------------|----------------|---------|
| EEZ Studio | Node.js/Electron | C or **C++** (template-dependent) | GPL-3.0 |
| Qt Design Studio | Qt installation | QML/C++ | Commercial/GPL |

#### EEZ Studio Notes
Per the [README](https://github.com/eez-open/studio):
- License: **GPL-3.0**
- Can generate **C++ code** for embedded GUI (plan for C++ compiler or verify C-only output)
- EEZ does not claim ownership over generated code (with caveats around EEZ Flow)
- Generated file licensing depends on templates used (MIT/BSD/PD possible)

### Modeling/Simulation

| Tool | Toolchain Required | Generated Code | License | Spec File |
|------|--------------------|----------------|---------|-----------|
| OpenModelica | C++ compiler | C code | OSMC-PL | `openmodelica.schema` |
| Simulink Coder | MATLAB | C/C++ | Commercial | - |
| Embedded Coder | MATLAB | Production C/C++ | Commercial | - |

#### OpenModelica Notes
Per the [scripting documentation](https://build.openmodelica.org/Documentation/OpenModelica.Scripting.html):
- `translateModel` → translate Modelica to **C code**
- `buildModel` → translate to **C** and build executable

### WebAssembly Tools

| Tool | Toolchain Required | Purpose | License | Spec File |
|------|--------------------|---------|---------|-----------|
| Binaryen | C++ compiler | WASM optimization | Apache-2.0 | `wasm.schema` |
| WAMR (interp) | C only! | WASM runtime | Apache-2.0 | `wasm.schema` |

#### WAMR Notes
WAMR in interpreter mode is **Ring 0 compatible**! It compiles with cosmocc and runs WASM modules portably. The AOT/JIT modes require platform-specific code.

---

## BDD Feature Files

Each ring has corresponding BDD test scenarios:

```
.claude/features/
├── schemagen.feature   # Ring 0: Schema generator
├── defgen.feature      # Ring 0: Definition generator
├── lemon.feature       # Ring 0: Parser generator
├── ring1.feature       # Ring 1: gengetopt, cppcheck, sanitizers
└── ring2.feature       # Ring 2: StateSmith, protobuf, EEZ, WASM
```

Run BDD tests:
```bash
./build/bddgen --run .claude/features/
```

---

## Ring Assignment Decision Tree

```
Is the tool written in pure C and buildable with cc+sh+make?
├─ YES → Ring 0
└─ NO
   ├─ Is it a C-based utility that enhances but isn't required?
   │  ├─ YES → Ring 1
   │  └─ NO → Ring 2
   └─ Does it require C++, Java, .NET, MATLAB, or similar?
      └─ YES → Ring 2 (outputs must be committed)
```

---

## Adding New Tools

When adding a new tool:

1. Determine its ring classification using the decision tree
2. Document in this file with:
   - Toolchain requirements
   - License
   - What it generates
   - Source/documentation links
3. If Ring-2:
   - Set up `gen/<tool>/` directory structure
   - Add stamp files (`GENERATOR_VERSION`, `SHA256SUMS`)
   - Commit all generated outputs
4. Update `LICENSES.md` with license details

<!--
One Ring to bootstrap them all, One Ring to bind them,
One Ring to make regen and in the diff gate find them,
In the Land of Cosmopolitan where strange APE aeon binaries lie.

                    ▄▄▄▄▄▄▄▄▄
                   █░░░░░░░░░█
                   █ ◉     ◉ █
                   █    ▲    █        psst...
                   █ ╲_____╱ █    ╭────────────╮
                   █▄▄▄▄▄▄▄▄▄█ ── │ ...I'm    │
                        ║        │ voldemort! │
                   ╔════╩════╗   ╰────────────╯
                   ║  RING   ║        🐍
                   ║    0    ║
                   ╚═════════╝
-->