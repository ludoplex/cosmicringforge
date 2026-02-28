/* lexgen_self.h — Lexgen's self-hosted token types
 *
 * This header uses X-macro inclusion to generate lexgen's own token
 * definitions from lexgen_tokens.def. TRUE dogfooding.
 */
#ifndef LEXGEN_SELF_H
#define LEXGEN_SELF_H

#include <stddef.h>

/* ── Token Enum (X-macro expansion) ──────────────────────────────── */

typedef enum {
    LEXGEN_TOK_EOF = 0,
    LEXGEN_TOK_ERROR,
#define TOK(name, lexeme, kind, doc) LEXGEN_TOK_##name,
#include "lexgen_tokens.def"
#undef TOK
    LEXGEN_TOK_COUNT
} lexgen_token_t;

/* ── Token Names (X-macro expansion) ─────────────────────────────── */

static const char *lexgen_token_names[] = {
    "EOF",
    "ERROR",
#define TOK(name, lexeme, kind, doc) #name,
#include "lexgen_tokens.def"
#undef TOK
};

/* ── Keyword Table (X-macro expansion) ───────────────────────────── */

typedef struct {
    const char *keyword;
    lexgen_token_t token;
    const char *kind;
} lexgen_keyword_t;

/* Only include keywords (filter by kind at compile time is tricky,
 * so we include all and check kind at runtime) */
static const lexgen_keyword_t lexgen_keywords[] = {
#define TOK(name, lexeme, kind, doc) { lexeme, LEXGEN_TOK_##name, #kind },
#include "lexgen_tokens.def"
#undef TOK
    { NULL, 0, NULL }
};

/* ── Helper to get token name ────────────────────────────────────── */

static inline const char *lexgen_token_name(lexgen_token_t tok) {
    if (tok >= 0 && tok < LEXGEN_TOK_COUNT) {
        return lexgen_token_names[tok];
    }
    return "UNKNOWN";
}

#endif /* LEXGEN_SELF_H */
