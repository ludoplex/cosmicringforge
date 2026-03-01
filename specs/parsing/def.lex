# Defgen Lexer - Token Definitions
# Pairs with def.grammar for .def file parsing
#
# Build: lexgen def.lex
# Output: def_lexer.h, def_lexer.c

# ═══ Keywords ═══════════════════════════════════════════════════

CONST           "const"
ENUM            "enum"
FLAGS           "flags"
CONFIG          "config"
PREFIX          "prefix"
RANGE           "range"

# ═══ Base Types (for config fields) ═════════════════════════════

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
BOOL            "bool"
STRING          "string"

# ═══ Operators ══════════════════════════════════════════════════

EQUALS          "="
PIPE            "|"
AMPERSAND       "&"
LSHIFT          "<<"
RSHIFT          ">>"

# ═══ Punctuation ════════════════════════════════════════════════

LBRACE          "{"
RBRACE          "}"
LBRACKET        "["
RBRACKET        "]"
LPAREN          "("
RPAREN          ")"
COLON           ":"
COMMA           ","
DOTDOT          ".."

# ═══ Identifiers & Literals ═════════════════════════════════════

IDENT           [a-zA-Z_][a-zA-Z0-9_]*
NUMBER          -?[0-9]+
HEX_NUMBER      0x[0-9a-fA-F]+
STRING_LIT      \"([^\"\\]|\\.)*\"

# ═══ Skip ═══════════════════════════════════════════════════════

WHITESPACE      [ \t\r]+              @skip
NEWLINE         \n                    @skip @newline
COMMENT         #[^\n]*               @skip
