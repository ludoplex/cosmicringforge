# Project Context

cosmo-bde project using spec-driven development.

## Workflow

```
Edit spec → make regen → make verify → make → commit
```

**ALWAYS** edit specs first, then regenerate. Never hand-edit gen/*.

## Directory Structure

| Path | Purpose |
|------|---------|
| `specs/domain/*.schema` | Type definitions |
| `specs/behavior/*.sm` | State machines |
| `specs/behavior/*.feature` | BDD scenarios |
| `gen/` | Generated code (DO NOT EDIT) |
| `src/` | Hand-written implementation |

## Format → Output

| Spec | Generator | Output |
|------|-----------|--------|
| `.schema` | schemagen | `_types.c,h` |
| `.sm` | smgen | `_sm.c,h` |
| `.feature` | bddgen | `_bdd.c` |

## Commands

```bash
make regen      # Regenerate from specs
make verify     # Check for drift
make            # Build
make run        # Run app
make livereload # Hot-patch running app
make ape        # Build portable binary
```

## Live Reload

Edit `src/*.c` while app is running - changes appear instantly:

```bash
# Terminal 1
make run

# Terminal 2
make livereload

# Terminal 3
vim src/main.c  # Edit and save
# Watch Terminal 1 - function changes in real-time!
```

## Naming

- Types: `MyType` (PascalCase)
- Functions: `MyType_action()` (generated), `my_function()` (hand-written)
- Files: `mytype_types.c` (generated), `main.c` (hand-written)
