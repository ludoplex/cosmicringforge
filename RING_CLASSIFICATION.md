# Ring Classification

Tools and dependencies are classified into three rings based on their bootstrap requirements and toolchain dependencies.

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

| Tool | Purpose | Fallback |
|------|---------|----------|
| gengetopt | CLI argument parser generator | Hand-written parser |
| makeheaders | Auto-generate header files | Manual headers |
| AddressSanitizer | Memory error detection | Valgrind or manual testing |
| UBSan | Undefined behavior detection | Manual code review |
| cppcheck | Static analysis | Manual review |

**Rule**: If a Ring-1 tool is unavailable, the build must still succeed (possibly with reduced functionality or skipped checks).

---

## Ring 2: Authoring Appliances

**Requirement**: These tools require non-C toolchains. Their **outputs must be committed** to the repository.

### State Machine Generators

| Tool | Toolchain Required | Generated Code | License |
|------|--------------------|----------------|---------|
| StateSmith | .NET (C#) | Zero-dependency C | Apache-2.0 |
| IBM Rhapsody | IBM installation | C/C++ | Commercial |
| Simulink/Stateflow | MATLAB | C/C++ (via Embedded Coder) | Commercial |

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

| Tool | Toolchain Required | Generated Code | License |
|------|--------------------|----------------|---------|
| OpenModelica | C++ compiler | C code | OSMC-PL |
| Simulink Coder | MATLAB | C/C++ | Commercial |
| Embedded Coder | MATLAB | Production C/C++ | Commercial |

#### OpenModelica Notes
Per the [scripting documentation](https://build.openmodelica.org/Documentation/OpenModelica.Scripting.html):
- `translateModel` → translate Modelica to **C code**
- `buildModel` → translate to **C** and build executable

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