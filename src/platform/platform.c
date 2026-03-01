/* MBSE Stacks — Unified Platform Layer
 * Ring 0: Pure C
 *
 * When compiled with cosmocc (PROFILE=ape):
 *   - Single binary runs on Linux, macOS, Windows, *BSD
 *   - Uses Cosmopolitan's unified libc
 *   - NO platform-specific code needed
 *
 * When compiled with native cc (PROFILE=portable):
 *   - Uses POSIX APIs (works on Linux, macOS, *BSD)
 *   - Windows requires MinGW or similar POSIX layer
 *
 * The Cosmopolitan way: write once, run anywhere.
 * No #ifdef __linux__, no #ifdef _WIN32, no platform dispatch.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <sys/stat.h>

#ifdef __COSMOPOLITAN__
#include <cosmo.h>
#endif

/* ── Filesystem ────────────────────────────────────────────────────
 * These are standard POSIX, work everywhere including Cosmopolitan.
 */

int plat_file_exists(const char *path) {
    return access(path, F_OK) == 0;
}

int plat_mkdir(const char *path) {
    return mkdir(path, 0755);
}

int plat_is_dir(const char *path) {
    struct stat st;
    if (stat(path, &st) != 0) return 0;
    return S_ISDIR(st.st_mode);
}

/* ── Time ──────────────────────────────────────────────────────────
 * Standard C/POSIX time functions work everywhere.
 */

int64_t plat_time_ms(void) {
    struct timespec ts;
#ifdef __COSMOPOLITAN__
    /* Cosmopolitan provides clock_gettime */
    clock_gettime(CLOCK_MONOTONIC, &ts);
#elif defined(_POSIX_TIMERS) && _POSIX_TIMERS > 0
    clock_gettime(CLOCK_MONOTONIC, &ts);
#else
    /* Fallback for minimal systems */
    ts.tv_sec = time(NULL);
    ts.tv_nsec = 0;
#endif
    return (int64_t)ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
}

void plat_sleep_ms(int ms) {
    struct timespec ts;
    ts.tv_sec = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000000L;
    nanosleep(&ts, NULL);
}

/* ── Platform Info ─────────────────────────────────────────────────
 * Cosmopolitan provides runtime detection via IsLinux(), IsWindows(), etc.
 * For native builds, we detect at compile time.
 */

const char* plat_os_name(void) {
#ifdef __COSMOPOLITAN__
    if (IsLinux()) return "Linux";
    if (IsWindows()) return "Windows";
    if (IsXnu()) return "macOS";
    if (IsFreebsd()) return "FreeBSD";
    if (IsOpenbsd()) return "OpenBSD";
    if (IsNetbsd()) return "NetBSD";
    return "Cosmopolitan";
#elif defined(__linux__)
    return "Linux";
#elif defined(__APPLE__)
    return "macOS";
#elif defined(_WIN32)
    return "Windows";
#elif defined(__FreeBSD__)
    return "FreeBSD";
#else
    return "Unknown";
#endif
}

const char* plat_arch_name(void) {
#ifdef __COSMOPOLITAN__
    /* Cosmopolitan APE detects at runtime */
    #if defined(__x86_64__) || defined(__amd64__)
    return "x86_64 (APE polyglot)";
    #elif defined(__aarch64__)
    return "arm64 (APE polyglot)";
    #else
    return "APE";
    #endif
#elif defined(__x86_64__) || defined(__amd64__)
    return "x86_64";
#elif defined(__aarch64__) || defined(__arm64__)
    return "arm64";
#elif defined(__i386__)
    return "x86";
#elif defined(__arm__)
    return "arm";
#else
    return "unknown";
#endif
}

/* ── Example: Unified code that works everywhere ─────────────────── */

void plat_print_info(void) {
    printf("Platform: %s\n", plat_os_name());
    printf("Architecture: %s\n", plat_arch_name());
#ifdef __COSMOPOLITAN__
    printf("Runtime: Cosmopolitan APE (Actually Portable Executable)\n");
    printf("  - Single binary runs on: Linux, macOS, Windows, *BSD\n");
    printf("  - Architectures: x86_64, arm64\n");
#else
    printf("Runtime: Native\n");
#endif
}
