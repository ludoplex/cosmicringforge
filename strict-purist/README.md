# Strict Purist Stack

Self-hostable, minimal bootstrap stack - C + sh only.

## Ring 0 Philosophy

Everything builds from a clean checkout with only:
- `sh` (POSIX shell)
- `make`
- `cc` (any C compiler: gcc, clang, tcc, cosmocc)

## Vendored Libraries

| Library | License | Purpose |
|---------|---------|---------|
| SQLite | Public Domain | Embedded database |
| Lemon | Public Domain | LALR(1) parser generator |
| CLIPS | Public Domain | Rules/expert system engine |
| CivetWeb | MIT | Embedded HTTP server |
| Nuklear | MIT/PD | Immediate-mode GUI |
| yyjson | MIT | Fast JSON parser |
| Cosmopolitan | ISC | Cross-platform C, APE binaries |
| kilo | BSD | Minimal text editor |
| e9patch | GPL-3.0 | Binary rewriting tool |

## In-Tree Generators

| Tool | Purpose | Input |
|------|---------|-------|
| schemagen.c | Structs, serializers, validators | schema.def |
| lexgen.c | Table-driven lexer | token definitions |
| bin2c.c | Embed binary resources | binary files |

## Build Profiles

### PROFILE=portable (default)
```sh
make PROFILE=portable
```
- Native toolchain
- System libs where needed
- Best for debugging/sanitizers

### PROFILE=ape
```sh
make PROFILE=ape
```
- cosmocc toolchain
- Actually Portable Executable
- Single binary runs on 6 OSes, 2 architectures

## Directory Structure

```
strict-purist/
├── vendor/           # Ring 0 libraries (vendored)
│   ├── sqlite/
│   ├── lemon/
│   ├── clips/
│   ├── civetweb/
│   ├── nuklear/
│   ├── yyjson/
│   ├── cosmopolitan/
│   ├── kilo/
│   └── e9patch/
├── gen/              # In-tree generators
│   ├── schemagen/
│   ├── lexgen/
│   └── bin2c/
├── src/              # Application source
└── specs/            # Spec files (.def, .schema, etc.)
```

## Quick Start

```sh
cd strict-purist

# Bootstrap generators
./bootstrap.sh

# Build application
make

# Build APE (portable) binary
make PROFILE=ape
```
