/* smgen_self.h — State Machine Generator's self-hosted token types
 *
 * X-macro expansion from smgen_tokens.def - TRUE dogfooding.
 */
#ifndef SMGEN_SELF_H
#define SMGEN_SELF_H

#include <stddef.h>

/* ── Token Enum (X-macro expansion) ──────────────────────────────── */

typedef enum {
    SMGEN_TOK_EOF = 0,
    SMGEN_TOK_ERROR,
#define TOK(name, lexeme, kind, doc) SMGEN_TOK_##name,
#include "smgen_tokens.def"
#undef TOK
    SMGEN_TOK_COUNT
} smgen_token_t;

/* ── Token Names (X-macro expansion) ─────────────────────────────── */

static const char *smgen_token_names[] = {
    "EOF",
    "ERROR",
#define TOK(name, lexeme, kind, doc) #name,
#include "smgen_tokens.def"
#undef TOK
};

/* ── Keyword Table (X-macro expansion) ───────────────────────────── */

typedef struct {
    const char *keyword;
    smgen_token_t token;
    const char *kind;
} smgen_keyword_t;

static const smgen_keyword_t smgen_keywords[] = {
#define TOK(name, lexeme, kind, doc) { lexeme, SMGEN_TOK_##name, #kind },
#include "smgen_tokens.def"
#undef TOK
    { NULL, 0, NULL }
};

/* ── Helper ──────────────────────────────────────────────────────── */

static inline const char *smgen_token_name(smgen_token_t tok) {
    if (tok >= 0 && tok < SMGEN_TOK_COUNT) {
        return smgen_token_names[tok];
    }
    return "UNKNOWN";
}

#endif /* SMGEN_SELF_H */
