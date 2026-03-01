/* hsmgen_self.h — Hierarchical State Machine Generator's self-hosted token types
 *
 * X-macro expansion from hsmgen_tokens.def - TRUE dogfooding.
 */
#ifndef HSMGEN_SELF_H
#define HSMGEN_SELF_H

#include <stddef.h>

/* ── Token Enum (X-macro expansion) ──────────────────────────────── */

typedef enum {
    HSMGEN_TOK_EOF = 0,
    HSMGEN_TOK_ERROR,
#define TOK(name, lexeme, kind, doc) HSMGEN_TOK_##name,
#include "hsmgen_tokens.def"
#undef TOK
    HSMGEN_TOK_COUNT
} hsmgen_token_t;

/* ── Token Names (X-macro expansion) ─────────────────────────────── */

static const char *hsmgen_token_names[] = {
    "EOF",
    "ERROR",
#define TOK(name, lexeme, kind, doc) #name,
#include "hsmgen_tokens.def"
#undef TOK
};

/* ── Keyword Table (X-macro expansion) ───────────────────────────── */

typedef struct {
    const char *keyword;
    hsmgen_token_t token;
    const char *kind;
} hsmgen_keyword_t;

static const hsmgen_keyword_t hsmgen_keywords[] = {
#define TOK(name, lexeme, kind, doc) { lexeme, HSMGEN_TOK_##name, #kind },
#include "hsmgen_tokens.def"
#undef TOK
    { NULL, 0, NULL }
};

/* ── Helper ──────────────────────────────────────────────────────── */

static inline const char *hsmgen_token_name(hsmgen_token_t tok) {
    if (tok >= 0 && tok < HSMGEN_TOK_COUNT) {
        return hsmgen_token_names[tok];
    }
    return "UNKNOWN";
}

#endif /* HSMGEN_SELF_H */
