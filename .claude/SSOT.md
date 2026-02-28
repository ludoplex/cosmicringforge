# MBSE Stacks - Single Source of Truth Index

## Purpose
This document indexes all authoritative sources in the project.
When information conflicts, defer to the SSOT listed here.

## Ring Classification
**SSOT:** `RING_CLASSIFICATION.md`
- Tool classifications (Ring 0/1/2)
- Bootstrap requirements
- Decision tree for new tools

## License Tracking
**SSOT:** `LICENSES.md`
- Component licenses
- Compatibility matrix
- Compliance verification

## BDD Specifications
**SSOT:** `.claude/features/*.feature`
- `generators.feature` - Code generation behavior
- `specs.feature` - Specification parsing
- `build.feature` - Build system behavior
- `drift.feature` - Drift detection
- `stacks.feature` - Stack-specific scenarios

## LLM Context
**SSOT:** `.claude/CLAUDE.md`
- Architecture overview
- Quick reference
- Key file locations

## Conventions
**SSOT:** `.claude/CONVENTIONS.md`
- Naming patterns
- Code style
- Build system

## Domain Model
**SSOT:** `.claude/DOMAIN.md`
- Entity definitions
- Three Specs Model
- Stack profiles

## Stack Implementations

### Strict Purist
**SSOT:** `strict-purist/README.md`
- Ring-0 only implementation
- In-tree generators
- Vendored libraries

### FOSS Visual
**SSOT:** `foss-visual/README.md`
- StateSmith integration
- EEZ Studio setup
- Generated code management

### Commercial
**SSOT:** `commercial/README.md`
- Vendor toolchain setup
- Qualification requirements
- License management

## Build System
**SSOT:** `Makefile`
- Build targets
- Profile configuration
- Regen-and-diff gate

## Generator Specifications

### schemagen
**SSOT:** `strict-purist/gen/schemagen/README.md`
- Input format (.schema)
- Output format (types.h/c)
- Generation rules

### lexgen
**SSOT:** `strict-purist/gen/lexgen/README.md`
- Token definitions
- Lexer table format

## Vendored Libraries
**SSOT:** `strict-purist/vendor/README.md`
- Library versions
- Upstream sources
- Local modifications

## File Locations Quick Reference

| Category | Path |
|----------|------|
| LLM Context | `.claude/CLAUDE.md` |
| BDD Specs | `.claude/features/*.feature` |
| Ring Classification | `RING_CLASSIFICATION.md` |
| Licenses | `LICENSES.md` |
| Build | `Makefile` |
| Strict Purist | `strict-purist/` |
| FOSS Visual | `foss-visual/` |
| Commercial | `commercial/` |

## Update Protocol

1. **Ring changes** - Update `RING_CLASSIFICATION.md`
2. **License changes** - Update `LICENSES.md`
3. **New feature** - Add `.claude/features/*.feature` first
4. **Generator changes** - Update generator README
5. **Convention changes** - Update `.claude/CONVENTIONS.md`
