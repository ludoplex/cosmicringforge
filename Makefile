# MBSE Stacks — Build System
# Minimal bootstrap: sh + make + cc
#
# Build Profiles:
#   make PROFILE=portable    Native toolchain (default)
#   make PROFILE=ape         Cosmopolitan APE binary
#
# Targets:
#   make                     Build default stack
#   make regen               Regenerate all Ring-2 outputs
#   make regen-check         Regen + verify no drift
#   make test                Run tests
#   make clean               Remove build artifacts

PROFILE ?= portable
STACK ?= strict-purist

# ── Toolchain ─────────────────────────────────────────────────
# Note: -Wno-stringop-truncation silences false positives (we null-terminate manually)
ifeq ($(PROFILE),ape)
    CC := cosmocc
    CFLAGS := -mcosmo -O2 -Wall -Werror -std=c11 -Wno-stringop-truncation
    LDFLAGS := -mcosmo
    EXE_EXT := .com
else
    CC ?= cc
    CFLAGS := -O2 -Wall -Werror -std=c11 -D_POSIX_C_SOURCE=200809L -Wno-stringop-truncation
    LDFLAGS :=
    EXE_EXT :=
endif

# ── Directories ───────────────────────────────────────────────
BUILD_DIR := build/$(PROFILE)
GEN_DIR := $(STACK)/gen
SRC_DIR := $(STACK)/src
VENDOR_DIR := $(STACK)/vendor
SPEC_DIR := $(STACK)/specs
TEST_DIR := $(STACK)/tests

# ── Ring-0 Generator Sources ──────────────────────────────────
GENERATORS := schemagen lexgen bin2c smgen uigen

GEN_SRCS := $(foreach g,$(GENERATORS),$(GEN_DIR)/$(g)/$(g).c)
GEN_BINS := $(foreach g,$(GENERATORS),$(BUILD_DIR)/$(g)$(EXE_EXT))

# ── Common flags ──────────────────────────────────────────────
INCLUDES := -I$(VENDOR_DIR) -I$(GEN_DIR) -I$(SRC_DIR)

.PHONY: all clean regen regen-check test generators help bootstrap example

# ══════════════════════════════════════════════════════════════
# Primary Targets
# ══════════════════════════════════════════════════════════════

all: generators
	@echo "Build complete (PROFILE=$(PROFILE), STACK=$(STACK))"

help:
	@echo "MBSE Stacks Build System"
	@echo ""
	@echo "Profiles:"
	@echo "  PROFILE=portable   Native toolchain (default)"
	@echo "  PROFILE=ape        Cosmopolitan APE"
	@echo ""
	@echo "Stacks:"
	@echo "  STACK=strict-purist   Ring-0 only (default)"
	@echo "  STACK=foss-visual     FOSS tools"
	@echo "  STACK=commercial      Vendor tools"
	@echo ""
	@echo "Targets:"
	@echo "  make               Build generators"
	@echo "  make example       Build and run example"
	@echo "  make regen         Regenerate all outputs"
	@echo "  make regen-check   Regen + drift check"
	@echo "  make test          Run tests"
	@echo "  make clean         Remove artifacts"

# ══════════════════════════════════════════════════════════════
# Bootstrap (Self-Hosting)
# ══════════════════════════════════════════════════════════════

bootstrap:
	@echo "Running bootstrap for $(STACK)..."
	cd $(STACK) && ./bootstrap.sh $(PROFILE)

# ══════════════════════════════════════════════════════════════
# Generator Builds (Ring-0)
# ══════════════════════════════════════════════════════════════

generators: $(BUILD_DIR) $(GEN_BINS)
	@echo "Built $(words $(GEN_BINS)) generators"

$(BUILD_DIR):
	mkdir -p $@

# Bootstrap schemagen (no self-hosting, for initial build)
$(BUILD_DIR)/schemagen-bootstrap$(EXE_EXT): $(GEN_DIR)/schemagen/schemagen.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<

# Self-hosted schemagen (uses its own generated types - DOGFOODING)
$(BUILD_DIR)/schemagen$(EXE_EXT): $(GEN_DIR)/schemagen/schemagen.c $(GEN_DIR)/schemagen/schemagen_types.h | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -DSCHEMAGEN_SELF_HOST -I$(GEN_DIR)/schemagen -o $@ $< $(GEN_DIR)/schemagen/schemagen_types.c

$(BUILD_DIR)/lexgen$(EXE_EXT): $(GEN_DIR)/lexgen/lexgen.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<

$(BUILD_DIR)/bin2c$(EXE_EXT): $(GEN_DIR)/bin2c/bin2c.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<

$(BUILD_DIR)/smgen$(EXE_EXT): $(GEN_DIR)/smgen/smgen.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<

$(BUILD_DIR)/uigen$(EXE_EXT): $(GEN_DIR)/uigen/uigen.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<

# ══════════════════════════════════════════════════════════════
# Regeneration
# ══════════════════════════════════════════════════════════════

regen: generators
	@echo "Regenerating from specs..."
	@for spec in $(SPEC_DIR)/*.schema; do \
		[ -f "$$spec" ] && $(BUILD_DIR)/schemagen$(EXE_EXT) "$$spec" || true; \
	done
	@for spec in $(SPEC_DIR)/*.sm; do \
		[ -f "$$spec" ] && $(BUILD_DIR)/smgen$(EXE_EXT) "$$spec" || true; \
	done
	@for spec in $(SPEC_DIR)/*.ui; do \
		[ -f "$$spec" ] && $(BUILD_DIR)/uigen$(EXE_EXT) "$$spec" || true; \
	done
	@echo "Regeneration complete"

regen-check: regen
	@echo "Checking for drift..."
	@git diff --exit-code $(GEN_DIR) || \
		(echo "ERROR: Uncommitted generated code detected!" && exit 1)
	@echo "No drift detected"

# ══════════════════════════════════════════════════════════════
# Example
# ══════════════════════════════════════════════════════════════

EXAMPLE_DIR := examples
EXAMPLE_GEN := $(EXAMPLE_DIR)/gen

example: $(BUILD_DIR)/example$(EXE_EXT)
	@echo ""
	@$(BUILD_DIR)/example$(EXE_EXT)

$(BUILD_DIR)/example$(EXE_EXT): $(EXAMPLE_GEN)/config_types.c $(EXAMPLE_DIR)/main.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(EXAMPLE_GEN) -o $@ $(EXAMPLE_DIR)/main.c $(EXAMPLE_GEN)/config_types.c

$(EXAMPLE_GEN)/config_types.c: $(EXAMPLE_DIR)/config.schema $(BUILD_DIR)/schemagen$(EXE_EXT) | $(EXAMPLE_GEN)
	$(BUILD_DIR)/schemagen$(EXE_EXT) $< $(EXAMPLE_GEN) config

$(EXAMPLE_GEN):
	mkdir -p $@

# ══════════════════════════════════════════════════════════════
# Testing
# ══════════════════════════════════════════════════════════════

test: generators
	@echo "Running tests..."
	@if [ -d "$(TEST_DIR)" ]; then \
		for t in $(TEST_DIR)/test_*.c; do \
			[ -f "$$t" ] && \
			$(CC) $(CFLAGS) $(INCLUDES) -o $(BUILD_DIR)/$$(basename $$t .c) $$t && \
			$(BUILD_DIR)/$$(basename $$t .c) || exit 1; \
		done; \
	fi
	@echo "Tests passed"

# ══════════════════════════════════════════════════════════════
# Cleanup
# ══════════════════════════════════════════════════════════════

clean:
	rm -rf build/
	rm -rf $(EXAMPLE_GEN)
	@echo "Build artifacts removed (gen/ preserved)"

distclean: clean
	@echo "WARNING: This would remove gen/ - not implemented for safety"
