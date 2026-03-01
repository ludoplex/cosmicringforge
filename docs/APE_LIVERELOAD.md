# APE Live Reload Reference

> **LLM Reference Document** - Detailed architecture for APE binary hot-patching.
>
> See also: `docs/ARCHITECTURE.md`, `vendors/e9studio/docs/`

---

## 1. What is APE?

APE (Actually Portable Executable) is a polyglot binary format created by Justine Tunney
for the [Cosmopolitan libc](https://github.com/jart/cosmopolitan) project.

### Key Properties

- **Single binary runs everywhere**: Linux, macOS, Windows, FreeBSD, OpenBSD, NetBSD
- **No runtime dependencies**: Statically linked, self-contained
- **Polyglot structure**: Simultaneously valid as DOS/PE, shell script, ELF, Mach-O, ZIP
- **ZipOS**: Embedded virtual filesystem accessible via `/zip/` paths
- **PE is ground truth**: Section layout defined by PE headers, not ELF

### File Structure

```
+===========================================================================+
|                          APE BINARY LAYOUT                                 |
+===========================================================================+
|                                                                            |
|  Offset 0x00-0x01: MZ Header (0x4D 0x5A)                                   |
|    - Required for Windows PE recognition                                   |
|    - Also begins valid shell script: "MZ" is harmless in shell             |
|                                                                            |
|  Offset 0x02-0x3B: DOS Stub + Shell Script Polyglot                        |
|    - Contains: #!/bin/sh or similar                                        |
|    - Encoded to be valid DOS stub AND shell script                         |
|    - Shell interprets this; DOS/Windows skip to PE header                  |
|                                                                            |
|  Offset 0x3C-0x3F: PE Header Offset (e_lfanew)                             |
|    - Points to PE signature for Windows loader                             |
|                                                                            |
|  Offset 0x40-0x7F: Extended Shell Script                                   |
|    - More shell commands                                                   |
|    - Typically: exec or dd commands to extract/run                         |
|                                                                            |
|  Offset 0x80+: PE Header (if Windows)                                      |
|    - PE\0\0 signature                                                      |
|    - COFF header                                                           |
|    - Optional header (PE32+)                                               |
|    - Section headers  <-- GROUND TRUTH FOR APE LAYOUT                      |
|                                                                            |
|  ELF Header (embedded in shell script region)                              |
|    - 0x7F ELF magic                                                        |
|    - Placed where shell treats it as comment/string                        |
|    - Program headers point to actual code sections                         |
|                                                                            |
|  Mach-O Header (for macOS)                                                 |
|    - 0xFEEDFACF magic (64-bit)                                             |
|    - Load commands                                                         |
|    - Segment definitions                                                   |
|                                                                            |
|  .text Section                                                             |
|    - Actual x86-64 machine code                                            |
|    - Position-independent (PIC)                                            |
|    - Cosmopolitan runtime startup code                                     |
|                                                                            |
|  .data / .rodata / .bss Sections                                           |
|    - Initialized and uninitialized data                                    |
|    - String constants, global variables                                    |
|                                                                            |
|  ZIP Central Directory Entries  <-- ZipOS                                  |
|    - File metadata (names, sizes, offsets)                                 |
|    - CRC checksums                                                         |
|    - Compression method (usually STORE for mmap)                           |
|                                                                            |
|  ZIP Local File Headers + Data  <-- ZipOS                                  |
|    - Actual embedded files                                                 |
|    - Can include: assets, libraries, models (llamafile)                    |
|    - Memory-mappable when uncompressed                                     |
|                                                                            |
|  ZIP End of Central Directory (EOCD)  <-- ZipOS                            |
|    - Points back to central directory                                      |
|    - This is what makes the whole file a valid ZIP                         |
|                                                                            |
+===========================================================================+
```

---

## 2. ZipOS Virtual Filesystem

ZipOS allows APE binaries to embed files that are accessible at runtime via `/zip/` paths.

### How ZipOS Works

```c
// When you open("/zip/myfile.txt", O_RDONLY):

1. Cosmopolitan intercepts the open() call
2. Checks if path starts with "/zip/"
3. Locates the ZIP central directory (from EOCD at EOF)
4. Binary searches for the file entry
5. Returns a special fd that:
   - For STORE'd files: mmap's directly from executable
   - For DEFLATE'd files: decompresses on read

// Memory mapping (zero-copy for uncompressed):
void *data = mmap(NULL, size, PROT_READ, MAP_PRIVATE, exe_fd, zip_offset);
```

### ZipOS in llamafile (Example)

```
llamafile.com (4.2 GB example)
+-- [0x000000 - 0x100000]  APE headers + bootstrap (~1MB)
+-- [0x100000 - 0x200000]  Executable code (~1MB)
+-- [0x200000 - 0x300000]  Cosmopolitan runtime (~1MB)
+-- [0x300000 - 0xFFFFFFFF] ZIP containing:
    +-- weights.gguf (4GB, STORED uncompressed)
        |
        v
        Accessed via: open("/zip/weights.gguf")
        Memory-mapped directly from offset 0x300000
        No copy, no extraction, just mmap()
```

### ZipOS Characteristics

| Feature | Behavior | Implication |
|---------|----------|-------------|
| **STORE compression** | Zero-copy mmap | Target binaries can be mmap'd directly |
| **DEFLATE compression** | Streamed decompression | Source files can be compressed |
| **Append-only** | Can add files to running exe | Hot-add patches without restart |
| **Central directory at EOF** | Easy to update | Can modify ZIP without rewriting whole file |

---

## 3. Live Reload Data Flow

```
+===========================================================================+
|                          LIVE RELOAD WORKFLOW                              |
+===========================================================================+

  +-------------+     +-------------+     +-------------+     +-----------+
  |   Editor    |     |  File Watch |     |   cosmocc   |     | Binaryen  |
  |  (vim/vsc)  |---->|  inotify/   |---->|  -c -O2 -g  |---->|   Diff    |
  |             |     |  stat()     |     |             |     |           |
  +-------------+     +-------------+     +-------------+     +-----+-----+
       |                    |                    |                   |
       | save               | IN_MODIFY          | .c -> .o          |
       v                    v                    v                   v
  +-----------------------------------------------------------------------+
  |                        livereload.c                                    |
  |  +------------------+  +------------------+  +----------------------+  |
  |  | poll_events()    |  | compile_source() |  | generate_patches()   |  |
  |  | g_last_mtime     |  | popen(cosmocc)   |  | e9_binaryen_diff()   |  |
  |  +--------+---------+  +--------+---------+  +----------+-----------+  |
  |           |                    |                       |               |
  |           v                    v                       v               |
  |  +---------------------------------------------------------------------+
  |  |                    PATCH APPLICATION                                |
  |  |                                                                     |
  |  |   +-------------------------------------------------------------+   |
  |  |   | e9_ape_rva_to_offset(&ape_info, rva)                        |   |
  |  |   |   PE Section Table -> File Offset Translation               |   |
  |  |   +-------------------------------------------------------------+   |
  |  |                           |                                         |
  |  |                           v                                         |
  |  |   +-------------------------------------------------------------+   |
  |  |   | process_vm_writev() [Linux]                                 |   |
  |  |   | WriteProcessMemory() [Windows]                              |   |
  |  |   |   --- No ptrace, no stop, atomic write ---                  |   |
  |  |   +-------------------------------------------------------------+   |
  |  |                           |                                         |
  |  |                           v                                         |
  |  |   +-------------------------------------------------------------+   |
  |  |   | e9wasm_flush_icache(addr, size)                             |   |
  |  |   |   __builtin___clear_cache() / FlushInstructionCache()       |   |
  |  |   +-------------------------------------------------------------+   |
  |  +---------------------------------------------------------------------+
  +-----------------------------------------------------------------------+
                                    |
                                    v
  +-----------------------------------------------------------------------+
  |                     TARGET APE PROCESS                                 |
  |   +---------------------------------------------------------------+   |
  |   |  .text: 0x401000  [original code]  ->  [PATCHED CODE]         |   |
  |   |         +-- function bytes overwritten in-place --+           |   |
  |   |                                                               |   |
  |   |  Execution continues with new code immediately!               |   |
  |   +---------------------------------------------------------------+   |
  +-----------------------------------------------------------------------+
```

---

## 4. Unified Process Memory API

The `e9procmem.h` API provides cross-platform memory access using X-macros.

### X-Macro Definitions

```c
/* Platform detection */
#define PROCMEM_OS_XMACRO(X) \
    X(PROCMEM_OS_UNKNOWN, 0, "unknown") \
    X(PROCMEM_OS_LINUX,   1, "linux")   \
    X(PROCMEM_OS_WINDOWS, 2, "windows") \
    X(PROCMEM_OS_MACOS,   3, "macos")   \
    X(PROCMEM_OS_BSD,     4, "bsd")

/* Memory access modes */
#define MEMACCESS_XMACRO(X) \
    X(PROCMEM_READ,  1, "read")  \
    X(PROCMEM_WRITE, 2, "write") \
    X(PROCMEM_EXEC,  4, "exec")

/* Status codes */
#define PROCMEM_STATUS_XMACRO(X) \
    X(PROCMEM_OK,           0, "success")           \
    X(PROCMEM_ERR_OPEN,    -1, "open failed")       \
    X(PROCMEM_ERR_READ,    -2, "read failed")       \
    X(PROCMEM_ERR_WRITE,   -3, "write failed")      \
    X(PROCMEM_ERR_PERM,    -4, "permission denied") \
    X(PROCMEM_ERR_NOENT,   -5, "process not found")

/* Expand to constants */
#define X(name, val, str) static const int name = val;
PROCMEM_OS_XMACRO(X)
MEMACCESS_XMACRO(X)
PROCMEM_STATUS_XMACRO(X)
#undef X

/* String conversion */
static inline const char* procmem_os_str(int os) {
    switch(os) {
#define X(name, val, str) case val: return str;
        PROCMEM_OS_XMACRO(X)
#undef X
    }
    return "unknown";
}
```

### Platform Implementations

| Platform | Read API | Write API | Notes |
|----------|----------|-----------|-------|
| Linux | `process_vm_readv()` | `process_vm_writev()` | No ptrace needed if same user |
| Windows | `ReadProcessMemory()` | `WriteProcessMemory()` | Requires PROCESS_VM_* access |
| macOS | `task_for_pid()` + `vm_read()` | `vm_write()` | Requires entitlements |
| BSD | `/proc/pid/mem` | `/proc/pid/mem` | Varies by BSD variant |

### Why No ptrace?

Traditional debugging uses `ptrace(PTRACE_ATTACH)` which:
- Stops the target process
- Requires root or same user
- Slow for frequent patches

`process_vm_readv/writev` on Linux:
- No process stop required
- Atomic memory access
- Works on running process
- Faster for hot-patching

---

## 5. APE Address Translation

APE binaries use PE sections as the authoritative layout. Address translation converts
between different address spaces.

### Address Types

| Type | Description | Example |
|------|-------------|---------|
| **File Offset** | Byte position in file | `0x1234` |
| **RVA** | Relative Virtual Address (PE) | `0x1000` |
| **VA** | Virtual Address (loaded) | `0x401000` |

### Translation Function

```c
/*
 * Convert PE RVA to file offset using section headers.
 * PE sections are ground truth for APE (no ELF for x86-64!).
 */
off_t e9_ape_rva_to_offset(const E9_APEInfo *ape, uint32_t rva)
{
    for (int i = 0; i < ape->num_sections; i++) {
        PE_Section *sec = &ape->sections[i];

        if (rva >= sec->virtual_address &&
            rva < sec->virtual_address + sec->virtual_size) {
            // RVA is within this section
            uint32_t offset_in_section = rva - sec->virtual_address;
            return sec->raw_data_offset + offset_in_section;
        }
    }

    return -1;  // RVA not found in any section
}
```

### PE Section Layout (Typical)

```
+-------------------+------------------+------------------+------------------+
| Section           | Virtual Addr     | Virtual Size     | Raw Offset       |
+-------------------+------------------+------------------+------------------+
| .text             | 0x1000           | 0x5000           | 0x400            |
| .data             | 0x6000           | 0x1000           | 0x5400           |
| .rdata            | 0x7000           | 0x800            | 0x6400           |
| .bss              | 0x8000           | 0x2000           | 0x0 (no raw)     |
+-------------------+------------------+------------------+------------------+

Example: RVA 0x2500 (in .text)
  -> offset_in_section = 0x2500 - 0x1000 = 0x1500
  -> file_offset = 0x400 + 0x1500 = 0x1900
```

---

## 6. e9studio Component Architecture

```
+===========================================================================+
|                              e9studio                                      |
|                    Binary Patching for APE Polyglots                       |
+===========================================================================+

  +-----------------------------------------------------------------------+
  |                         PUBLIC API LAYER                               |
  |                                                                        |
  |   e9livereload.h              e9ape.h                e9procmem.h       |
  |   +-- init/shutdown           +-- parse              +-- open/close    |
  |   +-- watch/unwatch           +-- rva_to_offset      +-- read          |
  |   +-- poll                    +-- patch_offset       +-- write         |
  |   +-- apply_patch             +-- get_section        +-- flush         |
  |   +-- revert_patch            +-- dump_info          +-- error         |
  +-----------------------------------------------------------------------+
                                    |
                                    v
  +-----------------------------------------------------------------------+
  |                       INTERNAL COMPONENTS                              |
  |                                                                        |
  |   +------------------+    +------------------+    +------------------+ |
  |   |   e9ape.c        |    |  e9binaryen.c    |    |  e9wasm_host.c   | |
  |   |                  |    |                  |    |                  | |
  |   | PE Parser        |    | Object Differ    |    | WASM Runtime     | |
  |   | +-- DOS Header   |    | +-- Load .o      |    | +-- wasm3/WAMR   | |
  |   | +-- PE Header    |    | +-- Symbol diff  |    | +-- Host funcs   | |
  |   | +-- Sections     |    | +-- Byte diff    |    | +-- Memory map   | |
  |   | +-- RVA xlate    |    | +-- Gen patches  |    | +-- ICache       | |
  |   +------------------+    +------------------+    +------------------+ |
  |            |                      |                      |             |
  |            +----------------------+----------------------+             |
  |                                   |                                    |
  |                                   v                                    |
  |   +----------------------------------------------------------------+   |
  |   |                    X-MACRO DEFINITIONS                          |   |
  |   |                                                                 |   |
  |   |   e9procmem.h:                                                  |   |
  |   |   #define PROCMEM_OS_XMACRO(X) \                                |   |
  |   |       X(PROCMEM_OS_LINUX,   1, "linux")   \                     |   |
  |   |       X(PROCMEM_OS_WINDOWS, 2, "windows") \                     |   |
  |   |       X(PROCMEM_OS_MACOS,   3, "macos")                         |   |
  |   +----------------------------------------------------------------+   |
  +-----------------------------------------------------------------------+

  +-----------------------------------------------------------------------+
  |                      GENERATED FROM SPECS                              |
  |                                                                        |
  |   specs/e9livereload.schema  -->  gen/domain/e9livereload_types.h     |
  |   specs/e9ape.schema         -->  gen/domain/e9ape_types.h            |
  |   specs/features/*.feature   -->  (BDD tests when bddgen ready)       |
  +-----------------------------------------------------------------------+
```

---

## 7. Why APE Helps Live Reload

| Aspect | Pure ELF | APE |
|--------|----------|-----|
| **Tool portability** | Linux only | Single binary everywhere |
| **Embedded assets** | External files | ZipOS `/zip/` paths |
| **Self-modification** | Requires separate files | Can append to own ZIP |
| **Memory patching** | process_vm_writev | Same, but with COW mmap |
| **Section layout** | ELF sections | PE sections (simpler) |
| **Distribution** | Separate binaries per OS | Single .com file |

### Key Benefits

1. **livereload binary is itself an APE**
   - Same tool works on Linux, Windows, macOS, BSD

2. **PE sections are ground truth**
   - `e9_ape_rva_to_offset()` works identically everywhere

3. **ZipOS can embed source/patches**
   - Self-contained development environment possible

4. **Unified procmem API**
   - `process_vm_writev` (Linux)
   - `WriteProcessMemory` (Windows)
   - `task_for_pid` + `vm_write` (macOS)

---

## 8. Developer Feedback Loop

```
   Terminal 1                 Terminal 2                 Terminal 3
   ----------                 ----------                 ----------

   +---------------+         +---------------+         +---------------+
   |  ./build/app  |         |  sudo         |         |  vim src/app.c|
   |               |         |  ./build/     |         |               |
   |  Running...   |         |  livereload   |         |  Edit function|
   |  msg: "Hello" |         |  $(pgrep app) |         |  :w (save)    |
   |               |<--------|  src/app.c    |<--------|               |
   |  msg: "World" |  100ms  |  [OK] Patched |  inotify|               |
   |  ^            |         |  get_message  |         |               |
   |  +-- Changed! |         |  @ 0x401234   |         |               |
   +---------------+         +---------------+         +---------------+

   Total latency: ~200-500ms (dominated by compilation)

   UNDER THE HOOD:
   1. inotify detects IN_CLOSE_WRITE on src/app.c
   2. cosmocc -c src/app.c -o .e9cache/app.new.o
   3. e9_binaryen_diff(.e9cache/app.o, .e9cache/app.new.o)
   4. For each changed function:
      a. e9_ape_rva_to_offset() -> file offset
      b. process_vm_writev(pid, new_bytes, offset)
      c. __builtin___clear_cache(addr, addr + size)
   5. Running process executes new code immediately
```

---

## 9. Quick Start

```bash
# Build everything
make tools e9studio

# Terminal 1: Start your application
./build/app &

# Terminal 2: Attach live reload
sudo ./build/livereload $(pgrep app) src/main.c

# Terminal 3: Edit source
vim src/main.c
# Make changes, save with :w
# Watch Terminal 1 - changes appear immediately!

# Cleanup
kill $(pgrep app)
```

---

## 10. Files Reference

| Purpose | Path |
|---------|------|
| Test livereload | `vendors/e9studio/test/livereload/livereload.c` |
| Full API | `vendors/e9studio/src/e9patch/e9livereload.c` |
| API header | `vendors/e9studio/src/e9patch/e9livereload.h` |
| APE parser | `vendors/e9studio/src/e9patch/e9ape.c` |
| Procmem API | `vendors/e9studio/src/e9patch/e9procmem.h` |
| RE notes | `vendors/e9studio/doc/ape-anatomy-analysis.md` |

---

*Generated for LLM reference. Last updated: 2024*
