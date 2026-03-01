/* bddgen_self.h — BDD Generator's self-hosted token types
 *
 * X-macro expansion from bddgen_tokens.def - TRUE dogfooding.
 */
#ifndef BDDGEN_SELF_H
#define BDDGEN_SELF_H

#include <stddef.h>

/* ── Token Enum (X-macro expansion) ──────────────────────────────── */

typedef enum {
    BDDGEN_TOK_EOF = 0,
    BDDGEN_TOK_ERROR,
#define TOK(name, lexeme, kind, doc) BDDGEN_TOK_##name,
#include "bddgen_tokens.def"
#undef TOK
    BDDGEN_TOK_COUNT
} bddgen_token_t;

/* ── Token Names (X-macro expansion) ─────────────────────────────── */

static const char *bddgen_token_names[] = {
    "EOF",
    "ERROR",
#define TOK(name, lexeme, kind, doc) #name,
#include "bddgen_tokens.def"
#undef TOK
};

/* ── Keyword Table (X-macro expansion) ───────────────────────────── */

typedef struct {
    const char *keyword;
    bddgen_token_t token;
    const char *kind;
} bddgen_keyword_t;

static const bddgen_keyword_t bddgen_keywords[] = {
#define TOK(name, lexeme, kind, doc) { lexeme, BDDGEN_TOK_##name, #kind },
#include "bddgen_tokens.def"
#undef TOK
    { NULL, 0, NULL }
};

/* ── Helper ──────────────────────────────────────────────────────── */

static inline const char *bddgen_token_name(bddgen_token_t tok) {
    if (tok >= 0 && tok < BDDGEN_TOK_COUNT) {
        return bddgen_token_names[tok];
    }
    return "UNKNOWN";
}

#endif /* BDDGEN_SELF_H */
