/* uigen_self.h — UI Generator's self-hosted token types
 *
 * X-macro expansion from uigen_tokens.def - TRUE dogfooding.
 */
#ifndef UIGEN_SELF_H
#define UIGEN_SELF_H

#include <stddef.h>

/* ── Token Enum (X-macro expansion) ──────────────────────────────── */

typedef enum {
    UIGEN_TOK_EOF = 0,
    UIGEN_TOK_ERROR,
#define TOK(name, lexeme, kind, doc) UIGEN_TOK_##name,
#include "uigen_tokens.def"
#undef TOK
    UIGEN_TOK_COUNT
} uigen_token_t;

/* ── Token Names (X-macro expansion) ─────────────────────────────── */

static const char *uigen_token_names[] = {
    "EOF",
    "ERROR",
#define TOK(name, lexeme, kind, doc) #name,
#include "uigen_tokens.def"
#undef TOK
};

/* ── Keyword Table (X-macro expansion) ───────────────────────────── */

typedef struct {
    const char *keyword;
    uigen_token_t token;
    const char *kind;
} uigen_keyword_t;

static const uigen_keyword_t uigen_keywords[] = {
#define TOK(name, lexeme, kind, doc) { lexeme, UIGEN_TOK_##name, #kind },
#include "uigen_tokens.def"
#undef TOK
    { NULL, 0, NULL }
};

/* ── Helper ──────────────────────────────────────────────────────── */

static inline const char *uigen_token_name(uigen_token_t tok) {
    if (tok >= 0 && tok < UIGEN_TOK_COUNT) {
        return uigen_token_names[tok];
    }
    return "UNKNOWN";
}

#endif /* UIGEN_SELF_H */
