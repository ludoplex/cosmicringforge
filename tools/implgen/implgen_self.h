/* implgen_self.h — Implementation Directive Generator's self-hosted token types
 *
 * X-macro expansion from implgen_tokens.def - TRUE dogfooding.
 */
#ifndef IMPLGEN_SELF_H
#define IMPLGEN_SELF_H

#include <stddef.h>

/* ── Token Enum (X-macro expansion) ──────────────────────────────── */

typedef enum {
    IMPLGEN_TOK_EOF = 0,
    IMPLGEN_TOK_ERR,
#define TOK(name, lexeme, kind, doc) IMPLGEN_TOK_##name,
#include "implgen_tokens.def"
#undef TOK
    IMPLGEN_TOK_COUNT
} implgen_token_t;

/* ── Token Names (X-macro expansion) ─────────────────────────────── */

static const char *implgen_token_names[] = {
    "EOF",
    "ERROR",
#define TOK(name, lexeme, kind, doc) #name,
#include "implgen_tokens.def"
#undef TOK
};

/* ── Keyword Table (X-macro expansion) ───────────────────────────── */

typedef struct {
    const char *keyword;
    implgen_token_t token;
    const char *kind;
} implgen_keyword_t;

static const implgen_keyword_t implgen_keywords[] = {
#define TOK(name, lexeme, kind, doc) { lexeme, IMPLGEN_TOK_##name, #kind },
#include "implgen_tokens.def"
#undef TOK
    { NULL, 0, NULL }
};

/* ── Helper ──────────────────────────────────────────────────────── */

static inline const char *implgen_token_name(implgen_token_t tok) {
    if (tok >= 0 && tok < IMPLGEN_TOK_COUNT) {
        return implgen_token_names[tok];
    }
    return "UNKNOWN";
}

#endif /* IMPLGEN_SELF_H */
