/* bddgen_self.h — BDD Generator's self-hosted keyword types
 *
 * X-macro expansion from bddgen_keywords.def - TRUE dogfooding.
 */
#ifndef BDDGEN_SELF_H
#define BDDGEN_SELF_H

#include <stddef.h>

/* ── Keyword Enum (X-macro expansion) ────────────────────────────── */

typedef enum {
    BDDGEN_KW_UNKNOWN = 0,
#define KW(name, lexeme, kind, doc) BDDGEN_KW_##name,
#include "bddgen_keywords.def"
#undef KW
    BDDGEN_KW_COUNT
} bddgen_kw_t;

/* ── Keyword Names (X-macro expansion) ───────────────────────────── */

static const char *bddgen_kw_names[] = {
    "UNKNOWN",
#define KW(name, lexeme, kind, doc) #name,
#include "bddgen_keywords.def"
#undef KW
};

/* ── Keyword Table (X-macro expansion) ───────────────────────────── */

typedef struct {
    const char *keyword;
    bddgen_kw_t token;
    const char *kind;
} bddgen_keyword_t;

static const bddgen_keyword_t bddgen_keywords[] = {
#define KW(name, lexeme, kind, doc) { lexeme, BDDGEN_KW_##name, #kind },
#include "bddgen_keywords.def"
#undef KW
    { NULL, 0, NULL }
};

/* ── Helper ──────────────────────────────────────────────────────── */

static inline const char *bddgen_kw_name(bddgen_kw_t kw) {
    if (kw >= 0 && kw < BDDGEN_KW_COUNT) {
        return bddgen_kw_names[kw];
    }
    return "UNKNOWN";
}

#endif /* BDDGEN_SELF_H */
