/* clipsgen_self.h — Business Rules Generator's self-hosted tokens */
#ifndef CLIPSGEN_SELF_H
#define CLIPSGEN_SELF_H
#include <stddef.h>
typedef enum {
    CLIPSGEN_TOK_EOF = 0, CLIPSGEN_TOK_ERR,
#define TOK(name, lexeme, kind, doc) CLIPSGEN_TOK_##name,
#include "clipsgen_tokens.def"
#undef TOK
    CLIPSGEN_TOK_COUNT
} clipsgen_token_t;
#endif
