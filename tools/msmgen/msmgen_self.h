/* msmgen_self.h — Modal State Machine Generator's self-hosted token types
 *
 * X-macro expansion from msmgen_tokens.def - TRUE dogfooding.
 */
#ifndef MSMGEN_SELF_H
#define MSMGEN_SELF_H

#include <stddef.h>

typedef enum {
    MSMGEN_TOK_EOF = 0,
    MSMGEN_TOK_ERR,
#define TOK(name, lexeme, kind, doc) MSMGEN_TOK_##name,
#include "msmgen_tokens.def"
#undef TOK
    MSMGEN_TOK_COUNT
} msmgen_token_t;

static const char *msmgen_token_names[] = {
    "EOF", "ERROR",
#define TOK(name, lexeme, kind, doc) #name,
#include "msmgen_tokens.def"
#undef TOK
};

static inline const char *msmgen_token_name(msmgen_token_t tok) {
    return (tok >= 0 && tok < MSMGEN_TOK_COUNT) ? msmgen_token_names[tok] : "UNKNOWN";
}

#endif /* MSMGEN_SELF_H */
