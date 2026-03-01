/* siggen_self.h — Function Signature Generator's self-hosted tokens */
#ifndef SIGGEN_SELF_H
#define SIGGEN_SELF_H
#include <stddef.h>
typedef enum {
    SIGGEN_TOK_EOF = 0, SIGGEN_TOK_ERR,
#define TOK(name, lexeme, kind, doc) SIGGEN_TOK_##name,
#include "siggen_tokens.def"
#undef TOK
    SIGGEN_TOK_COUNT
} siggen_token_t;
__attribute__((unused)) static const char *siggen_token_names[] = { "EOF", "ERROR",
#define TOK(name, lexeme, kind, doc) #name,
#include "siggen_tokens.def"
#undef TOK
};
#endif
