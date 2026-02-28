# MBSE Stacks — Strict Purist Makefile
# Ring 0: C + sh + make only
#
# Build profiles:
#   make PROFILE=portable  (default) - native toolchain
#   make PROFILE=ape       - cosmocc for Actually Portable Executable

PROFILE ?= portable
BUILD_DIR := ../build/$(PROFILE)

# Toolchain selection
ifeq ($(PROFILE),ape)
    CC := cosmocc
    CFLAGS := -mcosmo -O2 -Wall -std=c11
    EXE_EXT := .com
else
    CC := cc
    CFLAGS := -O2 -Wall -std=c11 -D_POSIX_C_SOURCE=200809L
    EXE_EXT :=
endif

# Vendored library paths
VENDOR := vendor
LEMON := $(VENDOR)/lemon/lemon
SQLITE_SRC := $(VENDOR)/sqlite/sqlite3.c
YYJSON_SRC := $(VENDOR)/yyjson/yyjson.c
NUKLEAR_H := $(VENDOR)/nuklear/nuklear.h

.PHONY: all clean vendor-tools generators test

all: vendor-tools generators

# ── Vendor Tools ────────────────────────────────────────────────────

vendor-tools: $(LEMON) $(BUILD_DIR)/bin2c$(EXE_EXT)

$(LEMON): $(VENDOR)/lemon/lemon.c
	$(CC) -o $@ $<

$(BUILD_DIR)/bin2c$(EXE_EXT): $(VENDOR)/bin2c/bin2c_simple.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

# ── Generators ──────────────────────────────────────────────────────

generators: $(BUILD_DIR)/schemagen$(EXE_EXT) $(BUILD_DIR)/lexgen$(EXE_EXT) \
            $(BUILD_DIR)/smgen$(EXE_EXT) $(BUILD_DIR)/defgen$(EXE_EXT)

$(BUILD_DIR)/schemagen$(EXE_EXT): gen/schemagen/schemagen.c gen/schemagen/schemagen_types.h | $(BUILD_DIR)
	$(CC) $(CFLAGS) -Igen/schemagen -o $@ $<

$(BUILD_DIR)/lexgen$(EXE_EXT): gen/lexgen/lexgen.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -Igen/lexgen -o $@ $<

$(BUILD_DIR)/smgen$(EXE_EXT): gen/smgen/smgen.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -Igen/smgen -o $@ $<

$(BUILD_DIR)/defgen$(EXE_EXT): gen/defgen/defgen.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -Igen/defgen -o $@ $<

# ── Self-hosting (Dogfooding) ───────────────────────────────────────

# schemagen generates its own types from its spec
gen/schemagen/schemagen_types.h: specs/schemagen.schema $(BUILD_DIR)/schemagen-bootstrap$(EXE_EXT)
	$(BUILD_DIR)/schemagen-bootstrap$(EXE_EXT) $< gen/schemagen SCHEMAGEN

$(BUILD_DIR)/schemagen-bootstrap$(EXE_EXT): gen/schemagen/schemagen_bootstrap.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

# ── Directory Creation ──────────────────────────────────────────────

$(BUILD_DIR):
	mkdir -p $@

# ── Testing ─────────────────────────────────────────────────────────

test: all
	@echo "=== Testing generators ==="
	$(BUILD_DIR)/schemagen$(EXE_EXT) specs/schemagen.schema /tmp/test SCHEMA
	$(BUILD_DIR)/smgen$(EXE_EXT) specs/example.sm /tmp/test EXAMPLE
	$(BUILD_DIR)/defgen$(EXE_EXT) specs/tokens.def /tmp/test MBSE
	@echo "=== All tests passed ==="

# ── Regen-and-Diff Gate ─────────────────────────────────────────────

regen: all
	$(BUILD_DIR)/schemagen$(EXE_EXT) specs/schemagen.schema gen/schemagen SCHEMAGEN

regen-check: regen
	git diff --exit-code gen/

# ── Clean ───────────────────────────────────────────────────────────

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(LEMON)
