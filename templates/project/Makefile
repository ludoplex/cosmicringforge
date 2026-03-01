# CosmicRingForge Project Makefile
#
# Workflow: make regen → make verify → make → make run

CC ?= cc
COSMOCC ?= cosmocc

CFLAGS = -O2 -g -Wall -Wextra
LDFLAGS =

# Directories
SRC_DIR = src
GEN_DIR = gen/domain
SPEC_DIR = specs/domain
BUILD_DIR = build

# CosmicRingForge root (adjust if installed elsewhere)
FORGE_ROOT ?= $(HOME)/workspace/mbse-stacks

# Sources
SRCS = $(wildcard $(SRC_DIR)/*.c)
GEN_SRCS = $(wildcard $(GEN_DIR)/*_types.c)
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o) $(GEN_SRCS:$(GEN_DIR)/%.c=$(BUILD_DIR)/%.o)

# Include paths
INCLUDES = -I$(GEN_DIR)

# Output
TARGET = $(BUILD_DIR)/app

.PHONY: all clean regen verify run livereload ape

all: $(TARGET)
	@echo "Build complete: $(TARGET)"

$(TARGET): $(OBJS) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

$(BUILD_DIR)/%.o: $(GEN_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

$(BUILD_DIR):
	mkdir -p $@

# Regenerate from specs (uses cosmicringforge tools)
regen:
	@echo "Regenerating from specs..."
	@mkdir -p $(GEN_DIR)
	@for schema in $(SPEC_DIR)/*.schema; do \
		name=$$(basename $$schema .schema); \
		$(FORGE_ROOT)/build/schemagen $$schema $(GEN_DIR)/$$name; \
	done
	@echo "Done. Run 'make verify' to check for drift."

# Verify no uncommitted changes in gen/
verify: regen
	@if git diff --quiet $(GEN_DIR)/; then \
		echo "[OK] gen/ is clean"; \
	else \
		echo "[FAIL] gen/ has uncommitted changes"; \
		git diff --stat $(GEN_DIR)/; \
		exit 1; \
	fi

# Run the application
run: $(TARGET)
	./$(TARGET)

# Live reload: hot-patch running binary
livereload: $(TARGET)
	@PID=$$(pgrep -f "$(TARGET)"); \
	if [ -z "$$PID" ]; then \
		echo "Start the app first: make run"; \
		exit 1; \
	fi; \
	echo "Attaching live reload to PID $$PID..."; \
	sudo $(FORGE_ROOT)/upstream/e9studio/test/livereload/livereload $$PID $(SRC_DIR)/main.c

# Build APE (Actually Portable Executable)
ape: $(BUILD_DIR)/app.ape
	@echo "APE build complete: $(BUILD_DIR)/app.ape"
	@echo "Runs on Linux, macOS, Windows, FreeBSD, OpenBSD, NetBSD"

$(BUILD_DIR)/app.ape: $(SRCS) $(GEN_SRCS) | $(BUILD_DIR)
	$(COSMOCC) $(CFLAGS) $(INCLUDES) -o $@ $^ $(LDFLAGS)

clean:
	rm -rf $(BUILD_DIR)

# Help
help:
	@echo "CosmicRingForge Project"
	@echo ""
	@echo "Targets:"
	@echo "  make          - Build native binary"
	@echo "  make ape      - Build APE (portable)"
	@echo "  make run      - Run the app"
	@echo "  make regen    - Regenerate from specs"
	@echo "  make verify   - Check gen/ for drift"
	@echo "  make livereload - Attach live reload to running app"
	@echo "  make clean    - Remove build artifacts"
	@echo ""
	@echo "Workflow:"
	@echo "  1. Edit specs/domain/*.schema"
	@echo "  2. make regen"
	@echo "  3. make verify"
	@echo "  4. make"
	@echo "  5. git commit"
