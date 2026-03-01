/* sqlgen_self.h — SQL Schema Generator's self-hosted token types
 *
 * X-macro expansion from sqlgen_tokens.def - TRUE dogfooding.
 */
#ifndef SQLGEN_SELF_H
#define SQLGEN_SELF_H

#include <stddef.h>

/* ── Token Enum (X-macro expansion) ──────────────────────────────── */

typedef enum {
    SQLGEN_TOK_EOF = 0,
    SQLGEN_TOK_ERR,
#define TOK(name, lexeme, kind, doc) SQLGEN_TOK_##name,
#include "sqlgen_tokens.def"
#undef TOK
    SQLGEN_TOK_COUNT
} sqlgen_token_t;

/* ── Token Names (X-macro expansion) ─────────────────────────────── */

static const char *sqlgen_token_names[] = {
    "EOF",
    "ERROR",
#define TOK(name, lexeme, kind, doc) #name,
#include "sqlgen_tokens.def"
#undef TOK
};

/* ── Keyword Table (X-macro expansion) ───────────────────────────── */

typedef struct {
    const char *keyword;
    sqlgen_token_t token;
    const char *kind;
} sqlgen_keyword_t;

static const sqlgen_keyword_t sqlgen_keywords[] = {
#define TOK(name, lexeme, kind, doc) { lexeme, SQLGEN_TOK_##name, #kind },
#include "sqlgen_tokens.def"
#undef TOK
    { NULL, 0, NULL }
};

/* ── Helper ──────────────────────────────────────────────────────── */

static inline const char *sqlgen_token_name(sqlgen_token_t tok) {
    if (tok >= 0 && tok < SQLGEN_TOK_COUNT) {
        return sqlgen_token_names[tok];
    }
    return "UNKNOWN";
}

#endif /* SQLGEN_SELF_H */
