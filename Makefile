# ══════════════════════════════════════════════════════════════════════════════
# CosmicRingForge — BDE with Models
# Behavior Driven Engineering with Models
# ══════════════════════════════════════════════════════════════════════════════
#
# Minimal bootstrap: sh + make + cc
# All Ring 2 tools auto-detected, all output C, all compile with cosmocc
#
# Targets:
#   make              Build APE binary
#   make regen        Regenerate all code (auto-detects Ring 2 tools)
#   make verify       Regen + drift check
#   make test         Run BDD tests
#   make clean        Remove build artifacts
#
# ══════════════════════════════════════════════════════════════════════════════

# ── Toolchain ─────────────────────────────────────────────────────────────────
CC ?= cc
COSMOCC ?= cosmocc
CFLAGS := -O2 -Wall -Werror -std=c11 -Wno-stringop-truncation

# ── Directories ───────────────────────────────────────────────────────────────
BUILD_DIR := build
TOOLS_DIR := tools
SPECS_DIR := specs
GEN_DIR := gen
SRC_DIR := src
VENDOR_DIR := vendor
MODEL_DIR := model

# ── Ring 0 Generators ─────────────────────────────────────────────────────────
GENERATORS := schemagen lemon

# ── Sources ───────────────────────────────────────────────────────────────────
GEN_SRCS := $(shell find $(GEN_DIR) -name '*.c' 2>/dev/null)
SRC_SRCS := $(shell find $(SRC_DIR) -name '*.c' 2>/dev/null)
VENDOR_SRCS := $(shell find $(VENDOR_DIR) -name '*.c' 2>/dev/null)

.PHONY: all clean regen verify test tools help new-spec app run

# ══════════════════════════════════════════════════════════════════════════════
# Primary Targets
# ══════════════════════════════════════════════════════════════════════════════

all: tools app
	@echo ""
	@echo "CosmicRingForge — BDE with Models"
	@echo "Build complete. Run 'make run' to execute."

help:
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│  CosmicRingForge — BDE with Models                      │"
	@echo "│  Behavior Driven Engineering with Models                │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│  make              Build Ring 0 tools                   │"
	@echo "│  make regen        Regenerate all (auto-detect Ring 2)  │"
	@echo "│  make verify       Regen + drift check                  │"
	@echo "│  make test         Run BDD tests                        │"
	@echo "│  make clean        Remove build artifacts               │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│  make new-spec LAYER=domain NAME=user TYPE=schema       │"
	@echo "└─────────────────────────────────────────────────────────┘"

# ══════════════════════════════════════════════════════════════════════════════
# Ring 0 Tools
# ══════════════════════════════════════════════════════════════════════════════

tools: $(BUILD_DIR) $(BUILD_DIR)/schemagen $(BUILD_DIR)/lemon
	@echo "Ring 0 tools ready"

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/schemagen: $(TOOLS_DIR)/schemagen.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/lemon: $(TOOLS_DIR)/lemon.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

# ══════════════════════════════════════════════════════════════════════════════
# Application
# ══════════════════════════════════════════════════════════════════════════════

app: $(BUILD_DIR)/app
	@echo "Application built"

$(BUILD_DIR)/app: $(SRC_DIR)/main.c $(GEN_DIR)/domain/example_types.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(GEN_DIR)/domain -o $@ $(SRC_DIR)/main.c $(GEN_DIR)/domain/example_types.c

run: app
	@$(BUILD_DIR)/app

# ══════════════════════════════════════════════════════════════════════════════
# Regeneration
# ══════════════════════════════════════════════════════════════════════════════

regen: tools
	@./scripts/regen-all.sh

verify: tools
	@./scripts/regen-all.sh --verify

# ══════════════════════════════════════════════════════════════════════════════
# Testing
# ══════════════════════════════════════════════════════════════════════════════

test: tools
	@echo "Running BDD tests..."
	@if [ -x "$(BUILD_DIR)/bddgen" ]; then \
		$(BUILD_DIR)/bddgen --run $(SPECS_DIR)/testing/*.feature; \
	else \
		echo "bddgen not built yet, skipping BDD tests"; \
	fi

# ══════════════════════════════════════════════════════════════════════════════
# New Spec Helper
# ══════════════════════════════════════════════════════════════════════════════

new-spec:
	@./scripts/new-spec.sh $(LAYER) $(NAME) $(TYPE)

# ══════════════════════════════════════════════════════════════════════════════
# Cleanup
# ══════════════════════════════════════════════════════════════════════════════

clean:
	rm -rf $(BUILD_DIR)
	@echo "Build artifacts removed (gen/ preserved)"

distclean: clean
	rm -rf $(GEN_DIR)/*
	@echo "Generated code removed"
