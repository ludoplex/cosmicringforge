# CosmicRingForge - LLM Context

## 🚨 MANDATORY: Read Upstream Docs FIRST

**BEFORE writing ANY code**, you MUST read and understand these repositories:

| Priority | Repository | What to Read | Why |
|----------|------------|--------------|-----|
| **1** | [jart/cosmopolitan](https://github.com/jart/cosmopolitan) | README, tool/cosmocc/README.md, ape/ | ALL code compiles with cosmocc |
| **2** | Vendor repos below | README + examples | Integration patterns |

**Vendor Repositories (must understand):**

| Repo | Purpose | Key Files |
|------|---------|-----------|
| ludoplex/binaryen | WASM IR diffing (.com + .wasm) | README, examples/ |
| ludoplex/cosmo-sokol | GUI (Sokol + Nuklear) | README, demos/ |
| nicbarker/clay | Layout engine (single-header C) | clay.h, examples/ |

**Implemented:** `tools/uigen/` generates Nuklear UI from `.ui` specs (self-hosted).
**Composable:** lexgen + Lemon can target Clay, LVGL, or any UI framework.

**If you skip this step**, you WILL make mistakes like:
- Using TinyCC (incompatible - relocation errors)
- Using libclang library (incompatible - relocation errors)
- Missing cosmocc flags (-mclang for 3x faster C++)
- Wrong APE structure assumptions (PE is ground truth, not ELF)

**Full vendor documentation:** [VENDORS.md](../VENDORS.md)

---

## Overview
**Behavior Driven Engineering with Models** — BDE with Models.

Framework for the design and development of any application. All paths lead to C.
All tools compile with cosmocc to APE (Actually Portable Executable).

## Required Reading (after upstream docs)
1. **RING_CLASSIFICATION.md** — Tool rings, portability, cosmocc setup
2. **INTEROP_MATRIX.md** — Format relationships (ground truth)
3. **LITERATE.md** — Conventions, traceability

## The Enlightened Principle
```
Directory Structure = Format Graph = Build Rules = Documentation
```

The Makefile discovers formats, not lists files. Conventions derive from format relationships.

## Ring Classification

| Ring | Bootstrap | Tools | Directory |
|------|-----------|-------|-----------|
| **0** | C + sh + make | schemagen, lexgen, defgen, smgen, uigen, Lemon | `tools/` |
| **1** | Ring 0 + C tools | makeheaders, gengetopt, cppcheck, ASan/UBSan/TSan | `tools/ring1/` |
| **2** | External toolchains | StateSmith, Rhapsody, Simulink, OpenModelica, EEZ, protobuf-c | `model/` → `gen/imported/` |

**The Rule:** Ring 2 outputs committed, builds succeed with Ring 0 only.

**Ring 2 Categories:**
- **State Machines:** StateSmith (.drawio), Rhapsody (.emx), Simulink/Stateflow (.sfx)
- **Data/Schema:** protobuf-c (.proto), RTI DDS (.idl), flatcc (.fbs)
- **UI/Visual:** EEZ Studio (.eez-project), Qt Design Studio (.qml)
- **Modeling:** OpenModelica (.mo), Simulink Coder (.slx)
- **WebAssembly:** Binaryen (.wat), WAMR (interpreter is Ring 0!)

See **RING_CLASSIFICATION.md** for full details.

## ⚠️ CRITICAL: Tool Compatibility

| Tool | Status | Notes |
|------|--------|-------|
| **TinyCC (libtcc)** | ❌ BANNED | "Invalid relocation entry" with cosmopolitan.a |
| **Binaryen** | ✅ OK | Use ludoplex/binaryen (.com + .wasm outputs) |
| **Clang (cosmocc)** | ✅ OK | cosmocc bundles Clang 19 (`-mclang` flag) |
| **libclang (library)** | ⚠️ Avoid | Programmatic AST access has relocation issues |

TinyCC appears attractive for fast compilation but is fundamentally incompatible with Cosmopolitan.
Note: cosmocc bundles Clang 19 and GCC 14.1.0 - use `-mclang` for 3x faster C++ compile.

**Platform issues exist** - check [VENDORS.md](../VENDORS.md) and [GitHub issues](https://github.com/jart/cosmopolitan/issues) before debugging.

## Format → Output Mapping

### Ring 0 (tools/)
| Source | Generator | Output Pattern |
|--------|-----------|----------------|
| `.schema` | schemagen | `{name}_types.c,h` |
| `.def` | defgen | `{name}_tokens.h`, `{name}_model.h` |
| `.sm` | smgen | `{name}_sm.c,h` |
| `.hsm` | hsmgen | `{name}_hsm.c,h` |
| `.lex` | lexgen | `{name}_lex.c,h` |
| `.grammar` | Lemon | `{name}_parse.c,h` |
| `.ui` | uigen | `{name}_ui.c` (Nuklear) |
| `.feature` | bddgen | `{name}_bdd.c` |

### Ring 1 (tools/ring1/)
| Source | Tool | Output |
|--------|------|--------|
| `.c` | makeheaders | `{name}.h` (auto-generated) |
| `.ggo` | gengetopt | `{name}_cli.c,h` |
| `.c` | cppcheck | lint report |
| `.c` | ASan/UBSan/TSan | instrumented binary |

### Ring 2 (model/ → gen/imported/)
| Source | Tool | Output |
|--------|------|--------|
| `.drawio` | StateSmith | `{name}_sm.c,h` |
| `.proto` | protobuf-c | `{name}.pb-c.c,h` |
| `.mo` | OpenModelica | `{name}_sim.c,h` |
| `.slx` | Simulink Coder | `{name}_ert.c,h` |
| `.emx` | Rhapsody | `{name}_model.c,h` |
| `.eez-project` | EEZ Studio | `{name}_gui.c,h` |
| `.wat` | Binaryen/WAMR | `{name}_wasm.c,h` |

**Lemon Bindings:** lexgen + Lemon compose to parse ANY DSL → generate ANY target.
All Ring 0 generators are self-hosted (`*_self.h` + `*_tokens.def`).

## Directory Structure
```
specs/{layer}/*.{format}  →  gen/{layer}/*_{role}.c,h
model/*                   →  gen/imported/*
```

Layers: `domain`, `behavior`, `interface`, `parsing`, `testing`

## Commands
```bash
make formats    # Show discovered formats
make regen      # Regenerate all (auto-detect tools)
make verify     # Regen + drift check
make            # Build
make run        # Execute
```

## Live Reload

Hot-patch running binaries in real-time (e9studio):

```bash
# Terminal 1: Run target
./build/app

# Terminal 2: Attach live reload
sudo ./upstream/e9studio/test/livereload/livereload $(pgrep app) src/main.c

# Terminal 3: Edit and save
vim src/main.c
# Changes appear instantly in Terminal 1!
```

Live reload uses stat-based polling (100ms) - works on all platforms.

## Universal Workflow
```
Edit spec → make regen → make verify → make → commit
```

Same workflow for ALL formats (native or Ring 2).

## Key Files
| Purpose | Path |
|---------|------|
| **Vendor Repos** | `VENDORS.md` (**READ FIRST**) |
| Format Matrix | `INTEROP_MATRIX.md` |
| Spec Types | `SPEC_TYPES.md` |
| Literate System | `LITERATE.md` |
| Stacks Reference | `STACKS_REFERENCE.md` |

## Naming Convention
- Files: `{name}_{role}.c` (role from format: `_types`, `_sm`, `_bdd`, etc.)
- Functions: `{Type}_{action}()` (init, validate, step, etc.)
- Generators: `{name}gen.c`

## Generated File Header
```c
/* AUTO-GENERATED by {generator} {version} — DO NOT EDIT
 * @source {spec_file}:{lines}
 * @generated {timestamp}
 * Regenerate: make regen
 */
```

## When Working on This Repo
1. Check `make formats` to see what exists
2. Edit specs in `specs/{layer}/`
3. Run `make regen` then `make verify`
4. All generated code in `gen/` is committed (drift-gated)
