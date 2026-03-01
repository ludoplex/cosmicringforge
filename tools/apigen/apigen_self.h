/* apigen_self.h — API Generator's self-hosted token types
 *
 * X-macro expansion from apigen_tokens.def - TRUE dogfooding.
 */
#ifndef APIGEN_SELF_H
#define APIGEN_SELF_H

#include <stddef.h>

/* ── Token Enum (X-macro expansion) ──────────────────────────────── */

typedef enum {
    APIGEN_TOK_EOF = 0,
    APIGEN_TOK_ERROR,
#define TOK(name, lexeme, kind, doc) APIGEN_TOK_##name,
#include "apigen_tokens.def"
#undef TOK
    APIGEN_TOK_COUNT
} apigen_token_t;

/* ── Token Names (X-macro expansion) ─────────────────────────────── */

static const char *apigen_token_names[] = {
    "EOF",
    "ERROR",
#define TOK(name, lexeme, kind, doc) #name,
#include "apigen_tokens.def"
#undef TOK
};

/* ── Keyword Table (X-macro expansion) ───────────────────────────── */

typedef struct {
    const char *keyword;
    apigen_token_t token;
    const char *kind;
} apigen_keyword_t;

static const apigen_keyword_t apigen_keywords[] = {
#define TOK(name, lexeme, kind, doc) { lexeme, APIGEN_TOK_##name, #kind },
#include "apigen_tokens.def"
#undef TOK
    { NULL, 0, NULL }
};

/* ── Helper ──────────────────────────────────────────────────────── */

static inline const char *apigen_token_name(apigen_token_t tok) {
    if (tok >= 0 && tok < APIGEN_TOK_COUNT) {
        return apigen_token_names[tok];
    }
    return "UNKNOWN";
}

#endif /* APIGEN_SELF_H */
