# Schemagen Lexer - Token Definitions
# Pairs with schemagen.grammar for .schema file parsing
#
# Build: lexgen schemagen.lex
# Output: schemagen_lexer.h, schemagen_lexer.c

# ═══ Keywords ═══════════════════════════════════════════════════

TYPE            "type"
STRING          "string"
BOOL            "bool"

# ═══ Base Types ═════════════════════════════════════════════════

I8              "i8"
I16             "i16"
I32             "i32"
I64             "i64"
U8              "u8"
U16             "u16"
U32             "u32"
U64             "u64"
F32             "f32"
F64             "f64"

# ═══ Constraint Keywords ════════════════════════════════════════

DEFAULT         "default"
RANGE           "range"
NOT_EMPTY       "not_empty"

# ═══ Punctuation ════════════════════════════════════════════════

LBRACE          "{"
RBRACE          "}"
LBRACKET        "["
RBRACKET        "]"
COLON           ":"
COMMA           ","
DOTDOT          ".."

# ═══ Identifiers & Literals ═════════════════════════════════════

IDENT           [a-zA-Z_][a-zA-Z0-9_]*
NUMBER          -?[0-9]+
STRING_LIT      \"([^\"\\]|\\.)*\"

# ═══ Skip ═══════════════════════════════════════════════════════

WHITESPACE      [ \t\r]+              @skip
NEWLINE         \n                    @skip @newline
COMMENT         #[^\n]*               @skip
