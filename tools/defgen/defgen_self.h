/* defgen_self.h — Defgen's self-hosted macro definitions
 *
 * X-macro expansion from defgen_macros.def - TRUE dogfooding.
 */
#ifndef DEFGEN_SELF_H
#define DEFGEN_SELF_H

#include <stddef.h>

/* ── Macro Kind Enum (X-macro expansion) ─────────────────────────── */

typedef enum {
    DEFGEN_MACRO_UNKNOWN = 0,
#define MACRO(name, args, kind, doc) DEFGEN_MACRO_##name,
#include "defgen_macros.def"
#undef MACRO
    DEFGEN_MACRO_COUNT
} defgen_macro_t;

/* ── Macro Names (X-macro expansion) ─────────────────────────────── */

static const char *defgen_macro_names[] = {
    "UNKNOWN",
#define MACRO(name, args, kind, doc) #name,
#include "defgen_macros.def"
#undef MACRO
};

/* ── Macro Info Table (X-macro expansion) ────────────────────────── */

typedef struct {
    const char *name;
    const char *args;
    const char *kind;
    const char *doc;
} defgen_macro_info_t;

static const defgen_macro_info_t defgen_macros[] = {
    { "UNKNOWN", "()", "unknown", "Unknown macro" },
#define MACRO(name, args, kind, doc) { #name, args, #kind, doc },
#include "defgen_macros.def"
#undef MACRO
    { NULL, NULL, NULL, NULL }
};

/* ── Helper ──────────────────────────────────────────────────────── */

static inline const char *defgen_macro_name(defgen_macro_t macro) {
    if (macro >= 0 && macro < DEFGEN_MACRO_COUNT) {
        return defgen_macro_names[macro];
    }
    return "UNKNOWN";
}

#endif /* DEFGEN_SELF_H */
