# BDDgen Lexer - Token Definitions for Gherkin
# Pairs with feature.grammar for .feature file parsing
#
# Build: lexgen feature.lex
# Output: feature_lexer.h, feature_lexer.c
#
# Gherkin is line-oriented with specific keywords

# ═══ Keywords ═══════════════════════════════════════════════════

FEATURE         "Feature"
BACKGROUND      "Background"
SCENARIO        "Scenario"
SCENARIO_OUTLINE "Scenario Outline"
EXAMPLES        "Examples"
RULE            "Rule"

# ═══ Step Keywords ══════════════════════════════════════════════

GIVEN           "Given"
WHEN            "When"
THEN            "Then"
AND             "And"
BUT             "But"

# ═══ Punctuation ════════════════════════════════════════════════

COLON           ":"
PIPE            "|"
AT_TAG          @[a-zA-Z0-9_-]+

# ═══ Docstring Delimiters ═══════════════════════════════════════

DOCSTRING_START \"\"\"
DOCSTRING_END   \"\"\"

# ═══ Text & Data ════════════════════════════════════════════════

# Everything after a keyword until end of line
TEXT_LINE       [^\n]+                @context

# Placeholder in Scenario Outline
PLACEHOLDER     <[a-zA-Z_][a-zA-Z0-9_]*>

# ═══ Skip ═══════════════════════════════════════════════════════

WHITESPACE      [ \t\r]+              @skip
NEWLINE         \n                    @newline
COMMENT         #[^\n]*               @skip

# ═══ Lexer Notes ════════════════════════════════════════════════
#
# Gherkin lexing is context-sensitive:
# - After FEATURE/SCENARIO/etc. + COLON, capture rest as TEXT_LINE
# - Inside docstring ("""), capture raw text
# - Inside table row (|...|), split by |
#
# The @context directive tells lexgen to switch modes
