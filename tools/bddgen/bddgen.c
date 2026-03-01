/* MBSE Stacks — BDD Feature File Generator
 * Ring 0: Pure C, minimal bootstrap
 *
 * Parses Gherkin .feature files and generates C test harnesses.
 * Output is pure C with no runtime dependencies.
 *
 * TRUE DOGFOODING: Uses bddgen_self.h which expands bddgen_keywords.def
 * via X-macros to define the recognized Gherkin keywords.
 *
 * Usage: bddgen <input.feature> <output_dir> [prefix]
 *
 * Gherkin format:
 *   Feature: Name
 *     Description text
 *
 *     Background:
 *       Given a precondition
 *
 *     @tag
 *     Scenario: Name
 *       Given a step
 *       When an action
 *       Then an outcome
 *
 *     Scenario Outline: Name
 *       Given <param>
 *       Examples:
 *         | param |
 *         | value |
 *
 * Output:
 *   <prefix>_bdd.h   — Step prototypes and scenario declarations
 *   <prefix>_bdd.c   — Scenario runners with step call stubs
 *   <prefix>_runner.c — Main test runner (when generate_runner is set)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdint.h>
#include <time.h>
#include <errno.h>
#include <sys/stat.h>

/* ── Self-hosted keywords (dogfooding) ───────────────────────────── */
#include "bddgen_self.h"

#define BDDGEN_VERSION  "1.0.0"
#define MAX_LINE        1024
#define MAX_NAME        256
#define MAX_TEXT        512
#define MAX_PATH        512
#define MAX_IDENT       64    /* max chars in generated C identifiers */
#define MAX_STEPS       128
#define MAX_SCENARIOS   64
#define MAX_UNIQUE_STEPS 512

/* ── Data Structures ─────────────────────────────────────────────── */

typedef struct {
    uint8_t keyword;   /* 0=Given,1=When,2=Then,3=And,4=But */
    char text[MAX_TEXT];
    int line_number;
} step_t;

typedef struct {
    char name[MAX_NAME];
    char tags[MAX_NAME];
    int is_outline;
    step_t steps[MAX_STEPS];
    int step_count;
    int line_number;
} scenario_t;

typedef struct {
    char name[MAX_NAME];
    char description[2048];
    char tags[MAX_NAME];
    char language[8];
    int line_number;
    int has_background;
    step_t background[MAX_STEPS];
    int background_count;
    scenario_t scenarios[MAX_SCENARIOS];
    int scenario_count;
} feature_t;

static feature_t feature;

/* ── Utilities ────────────────────────────────────────────────────── */

static void trim(char *s) {
    char *start = s;
    while (*start && isspace((unsigned char)*start)) start++;
    if (start != s) memmove(s, start, strlen(start) + 1);
    char *end = s + strlen(s);
    while (end > s && isspace((unsigned char)*(end - 1))) end--;
    *end = '\0';
}

static void to_lower(char *s) {
    for (; *s; s++) *s = (char)tolower((unsigned char)*s);
}

/* Write a C string literal content with special characters escaped.
 * Escapes backslash, double quote, and newline. */
static void fwrite_escaped(FILE *out, const char *s) {
    for (; *s; s++) {
        if (*s == '\\')      { fputc('\\', out); fputc('\\', out); }
        else if (*s == '"')  { fputc('\\', out); fputc('"',  out); }
        else if (*s == '\n') { fputc('\\', out); fputc('n',  out); }
        else                 { fputc(*s,   out); }
    }
}

/* Convert arbitrary text to a valid C identifier (snake_case).
 * Non-alphanumeric runs become a single underscore.
 * Result is truncated to max_len-1 characters.
 */
static void text_to_ident(const char *text, char *out, size_t max_len) {
    size_t j = 0;
    int last_was_sep = 1; /* suppress leading underscores */
    for (const char *p = text; *p && j < max_len - 1; p++) {
        unsigned char c = (unsigned char)*p;
        if (isalnum(c)) {
            out[j++] = (char)tolower(c);
            last_was_sep = 0;
        } else if (!last_was_sep && j < max_len - 2) {
            out[j++] = '_';
            last_was_sep = 1;
        }
    }
    /* Strip trailing underscore */
    while (j > 0 && out[j - 1] == '_') j--;
    out[j] = '\0';
}

/* Build a unique step function name: step_{keyword}_{text_ident} */
static void step_func_name(const step_t *s, char *out, size_t max_len) {
    static const char *kw_prefix[] = { "given", "when", "then", "and", "but" };
    char ident[MAX_IDENT + 1];
    uint8_t kw = s->keyword < 5 ? s->keyword : 0;
    text_to_ident(s->text, ident, sizeof(ident));
    snprintf(out, max_len, "step_%s_%s", kw_prefix[kw], ident);
}

/* Build a scenario function name: scenario_{name_ident} */
static void scenario_func_name(const scenario_t *sc, char *out, size_t max_len) {
    char ident[MAX_IDENT + 1];
    text_to_ident(sc->name, ident, sizeof(ident));
    snprintf(out, max_len, "scenario_%s", ident);
}

/* Build a feature function name: feature_{name_ident} */
static void feature_func_name(const feature_t *f, char *out, size_t max_len) {
    char ident[MAX_IDENT + 1];
    text_to_ident(f->name, ident, sizeof(ident));
    snprintf(out, max_len, "feature_%s", ident);
}

/* ── Parser ───────────────────────────────────────────────────────── */

/* Detect Gherkin keyword at start of a trimmed line.
 * Returns BDDGEN_KW_UNKNOWN if not a keyword line.
 * *rest is set to the text after the keyword (and optional colon+space).
 */
static bddgen_kw_t detect_keyword(const char *line, const char **rest) {
    /* Check longer keywords first to avoid prefix collisions */
    static const struct { bddgen_kw_t kw; const char *prefix; } ordered[] = {
        { BDDGEN_KW_OUTLINE,    "Scenario Outline" },
        { BDDGEN_KW_FEATURE,    "Feature"          },
        { BDDGEN_KW_BACKGROUND, "Background"       },
        { BDDGEN_KW_SCENARIO,   "Scenario"         },
        { BDDGEN_KW_EXAMPLES,   "Examples"         },
        { BDDGEN_KW_GIVEN,      "Given"            },
        { BDDGEN_KW_WHEN,       "When"             },
        { BDDGEN_KW_THEN,       "Then"             },
        { BDDGEN_KW_AND,        "And"              },
        { BDDGEN_KW_BUT,        "But"              },
        { BDDGEN_KW_UNKNOWN,    NULL               },
    };

    for (int i = 0; ordered[i].prefix; i++) {
        size_t len = strlen(ordered[i].prefix);
        if (strncmp(line, ordered[i].prefix, len) == 0) {
            const char *p = line + len;
            /* Allow optional ':' and/or whitespace */
            if (*p == ':') p++;
            while (*p && isspace((unsigned char)*p)) p++;
            *rest = p;
            return ordered[i].kw;
        }
    }
    *rest = line;
    return BDDGEN_KW_UNKNOWN;
}

static int parse_feature(const char *filename) {
    FILE *f = fopen(filename, "r");
    if (!f) {
        fprintf(stderr, "bddgen: error: cannot open '%s': %s\n", filename, strerror(errno));
        return -1;
    }

    memset(&feature, 0, sizeof(feature));
    strncpy(feature.language, "en", sizeof(feature.language) - 1);

    char line[MAX_LINE];
    int line_num = 0;
    int in_description = 0;
    int in_background = 0;
    int in_scenario = 0;
    char pending_tags[MAX_NAME] = {0};
    scenario_t *cur_scenario = NULL;

    while (fgets(line, sizeof(line), f)) {
        line_num++;
        char trimmed[MAX_LINE];
        strncpy(trimmed, line, sizeof(trimmed) - 1);
        trim(trimmed);

        /* Skip blank lines and comments */
        if (trimmed[0] == '\0') {
            in_description = 0;
            continue;
        }
        if (trimmed[0] == '#') continue;

        /* Tags: @tag */
        if (trimmed[0] == '@') {
            strncpy(pending_tags, trimmed, MAX_NAME - 1);
            continue;
        }

        /* Data table row (|...|) — skip for now */
        if (trimmed[0] == '|') continue;

        /* Docstring fence (""") — skip for now */
        if (strncmp(trimmed, "\"\"\"", 3) == 0) continue;

        const char *rest;
        bddgen_kw_t kw = detect_keyword(trimmed, &rest);

        switch (kw) {
        case BDDGEN_KW_FEATURE:
            strncpy(feature.name, rest, MAX_NAME - 1);
            feature.line_number = line_num;
            if (pending_tags[0]) {
                strncpy(feature.tags, pending_tags, MAX_NAME - 1);
                pending_tags[0] = '\0';
            }
            in_description = 1;
            in_background = 0;
            in_scenario = 0;
            cur_scenario = NULL;
            break;

        case BDDGEN_KW_BACKGROUND:
            feature.has_background = 1;
            in_background = 1;
            in_scenario = 0;
            in_description = 0;
            cur_scenario = NULL;
            break;

        case BDDGEN_KW_SCENARIO:
        case BDDGEN_KW_OUTLINE:
            if (feature.scenario_count >= MAX_SCENARIOS) {
                fprintf(stderr, "bddgen: error: too many scenarios (max %d) at line %d\n",
                        MAX_SCENARIOS, line_num);
                fclose(f);
                return -1;
            }
            cur_scenario = &feature.scenarios[feature.scenario_count++];
            memset(cur_scenario, 0, sizeof(*cur_scenario));
            strncpy(cur_scenario->name, rest, MAX_NAME - 1);
            cur_scenario->is_outline = (kw == BDDGEN_KW_OUTLINE) ? 1 : 0;
            cur_scenario->line_number = line_num;
            if (pending_tags[0]) {
                strncpy(cur_scenario->tags, pending_tags, MAX_NAME - 1);
                pending_tags[0] = '\0';
            }
            in_scenario = 1;
            in_background = 0;
            in_description = 0;
            break;

        case BDDGEN_KW_EXAMPLES:
            /* Examples table: just skip the rows (handled by | check above) */
            in_description = 0;
            break;

        case BDDGEN_KW_GIVEN:
        case BDDGEN_KW_WHEN:
        case BDDGEN_KW_THEN:
        case BDDGEN_KW_AND:
        case BDDGEN_KW_BUT: {
            static const uint8_t kw_to_num[] = {
                [BDDGEN_KW_GIVEN] = 0,
                [BDDGEN_KW_WHEN]  = 1,
                [BDDGEN_KW_THEN]  = 2,
                [BDDGEN_KW_AND]   = 3,
                [BDDGEN_KW_BUT]   = 4,
            };
            in_description = 0;
            step_t *step = NULL;
            if (in_background) {
                if (feature.background_count < MAX_STEPS) {
                    step = &feature.background[feature.background_count++];
                } else {
                    fprintf(stderr, "bddgen: warning: too many background steps at line %d\n",
                            line_num);
                }
            } else if (in_scenario && cur_scenario) {
                if (cur_scenario->step_count < MAX_STEPS) {
                    step = &cur_scenario->steps[cur_scenario->step_count++];
                } else {
                    fprintf(stderr, "bddgen: warning: too many steps in scenario '%s' at line %d\n",
                            cur_scenario->name, line_num);
                }
            }
            if (step) {
                step->keyword = kw_to_num[kw];
                strncpy(step->text, rest, MAX_TEXT - 1);
                step->line_number = line_num;
            }
            break;
        }

        default:
            /* Free-form text in feature description */
            if (in_description && feature.name[0]) {
                size_t dlen = strlen(feature.description);
                if (dlen + strlen(trimmed) + 2 < sizeof(feature.description)) {
                    if (dlen > 0) feature.description[dlen++] = '\n';
                    strncpy(feature.description + dlen, trimmed,
                            sizeof(feature.description) - dlen - 1);
                }
            }
            break;
        }
    }

    fclose(f);
    return 0;
}

/* ── Unique Step Tracking ─────────────────────────────────────────── */

static char unique_step_funcs[MAX_UNIQUE_STEPS][MAX_NAME];
static int unique_step_count = 0;

static int step_func_is_new(const char *fname) {
    for (int i = 0; i < unique_step_count; i++) {
        if (strcmp(unique_step_funcs[i], fname) == 0) return 0;
    }
    if (unique_step_count < MAX_UNIQUE_STEPS) {
        strncpy(unique_step_funcs[unique_step_count++], fname, MAX_NAME - 1);
    }
    return 1;
}

static void collect_unique_steps(void) {
    char fname[MAX_NAME];
    unique_step_count = 0;
    /* Background steps */
    for (int i = 0; i < feature.background_count; i++) {
        step_func_name(&feature.background[i], fname, sizeof(fname));
        step_func_is_new(fname); /* registers */
    }
    /* Scenario steps */
    for (int s = 0; s < feature.scenario_count; s++) {
        scenario_t *sc = &feature.scenarios[s];
        for (int i = 0; i < sc->step_count; i++) {
            step_func_name(&sc->steps[i], fname, sizeof(fname));
            step_func_is_new(fname); /* registers */
        }
    }
}

/* ── Code Generation ──────────────────────────────────────────────── */

static int ensure_output_dir(const char *outdir) {
    if (!outdir || !*outdir) return 0;
    if (mkdir(outdir, 0777) == 0 || errno == EEXIST) return 0;
    perror("mkdir");
    return -1;
}

static int generate_bdd_h(const char *outdir, const char *lower_prefix) {
    char path[MAX_PATH];
    snprintf(path, sizeof(path), "%s/%s_bdd.h", outdir, lower_prefix);

    FILE *out = fopen(path, "w");
    if (!out) {
        fprintf(stderr, "bddgen: error: cannot create '%s': %s\n", path, strerror(errno));
        return -1;
    }

    /* Header guard (upper-case prefix) */
    char guard[MAX_NAME + 8]; /* +8 for "_BDD_H\0" */
    snprintf(guard, sizeof(guard), "%s_BDD_H", lower_prefix);
    for (char *p = guard; *p; p++) *p = (char)toupper((unsigned char)*p);

    fprintf(out, "/* AUTO-GENERATED by bddgen %s — DO NOT EDIT */\n", BDDGEN_VERSION);
    fprintf(out, "/* Feature: %s */\n", feature.name);
    fprintf(out, "#ifndef %s\n", guard);
    fprintf(out, "#define %s\n\n", guard);
    fprintf(out, "#ifdef __cplusplus\n");
    fprintf(out, "extern \"C\" {\n");
    fprintf(out, "#endif\n\n");

    /* Step function prototypes */
    fprintf(out, "/* Step function prototypes — implement these */\n");
    char fname[MAX_NAME];
    for (int i = 0; i < unique_step_count; i++) {
        fprintf(out, "int %s(void);\n", unique_step_funcs[i]);
    }
    fprintf(out, "\n");

    /* Scenario runner prototypes */
    fprintf(out, "/* Scenario runner prototypes */\n");
    for (int s = 0; s < feature.scenario_count; s++) {
        scenario_func_name(&feature.scenarios[s], fname, sizeof(fname));
        fprintf(out, "int %s(void);\n", fname);
    }
    fprintf(out, "\n");

    /* Feature runner prototype */
    feature_func_name(&feature, fname, sizeof(fname));
    fprintf(out, "/* Feature runner prototype */\n");
    fprintf(out, "int %s(void);\n\n", fname);

    fprintf(out, "#ifdef __cplusplus\n");
    fprintf(out, "}\n");
    fprintf(out, "#endif\n\n");
    fprintf(out, "#endif /* %s */\n", guard);

    fclose(out);
    fprintf(stderr, "Generated %s\n", path);
    return 0;
}

static int generate_bdd_c(const char *outdir, const char *lower_prefix) {
    char path[MAX_PATH];
    snprintf(path, sizeof(path), "%s/%s_bdd.c", outdir, lower_prefix);

    FILE *out = fopen(path, "w");
    if (!out) {
        fprintf(stderr, "bddgen: error: cannot create '%s': %s\n", path, strerror(errno));
        return -1;
    }

    fprintf(out, "/* AUTO-GENERATED by bddgen %s — DO NOT EDIT */\n", BDDGEN_VERSION);
    fprintf(out, "/* Feature: %s */\n\n", feature.name);
    fprintf(out, "#include \"%s_bdd.h\"\n", lower_prefix);
    fprintf(out, "#include <stdio.h>\n\n");

    /* Scenario runners */
    char sc_fname[MAX_NAME];
    char feat_fname[MAX_NAME];
    char step_fname[MAX_NAME];

    for (int s = 0; s < feature.scenario_count; s++) {
        scenario_t *sc = &feature.scenarios[s];
        scenario_func_name(sc, sc_fname, sizeof(sc_fname));

        fprintf(out, "/* Scenario: %s (line %d) */\n", sc->name, sc->line_number);
        if (sc->tags[0]) {
            fprintf(out, "/* Tags: %s */\n", sc->tags);
        }
        fprintf(out, "int %s(void) {\n", sc_fname);
        fprintf(out, "    int result = 0;\n");

        /* Emit background steps if feature has one */
        if (feature.has_background && feature.background_count > 0) {
            fprintf(out, "    /* Background */\n");
            for (int i = 0; i < feature.background_count; i++) {
                step_t *st = &feature.background[i];
                step_func_name(st, step_fname, sizeof(step_fname));
                fprintf(out, "    result |= %s(); /* %s */\n",
                        step_fname, st->text);
            }
        }

        /* Emit scenario steps */
        if (sc->step_count > 0) {
            fprintf(out, "    /* Steps */\n");
            for (int i = 0; i < sc->step_count; i++) {
                step_t *st = &sc->steps[i];
                step_func_name(st, step_fname, sizeof(step_fname));
                fprintf(out, "    result |= %s(); /* %s */\n",
                        step_fname, st->text);
            }
        }

        fprintf(out, "    return result;\n");
        fprintf(out, "}\n\n");
    }

    /* Feature runner */
    feature_func_name(&feature, feat_fname, sizeof(feat_fname));
    fprintf(out, "/* Feature runner: %s */\n", feature.name);
    fprintf(out, "int %s(void) {\n", feat_fname);
    fprintf(out, "    int pass = 0, fail = 0;\n");

    for (int s = 0; s < feature.scenario_count; s++) {
        scenario_func_name(&feature.scenarios[s], sc_fname, sizeof(sc_fname));
        fprintf(out, "    if (%s() == 0) pass++; else fail++;\n", sc_fname);
    }

    fprintf(out, "    fprintf(stdout, \"Feature: %%s — %%d passed, %%d failed\\n\",\n");
    fprintf(out, "            \"%s\", pass, fail);\n", feature.name);
    fprintf(out, "    return (fail == 0) ? 0 : 1;\n");
    fprintf(out, "}\n");

    fclose(out);
    fprintf(stderr, "Generated %s\n", path);
    return 0;
}

static int generate_runner_c(const char *outdir, const char *lower_prefix) {
    char path[MAX_PATH];
    snprintf(path, sizeof(path), "%s/%s_runner.c", outdir, lower_prefix);

    FILE *out = fopen(path, "w");
    if (!out) {
        fprintf(stderr, "bddgen: error: cannot create '%s': %s\n", path, strerror(errno));
        return -1;
    }

    char feat_fname[MAX_NAME];
    feature_func_name(&feature, feat_fname, sizeof(feat_fname));

    fprintf(out, "/* AUTO-GENERATED by bddgen %s — DO NOT EDIT */\n", BDDGEN_VERSION);
    fprintf(out, "/* Test runner for: %s */\n\n", feature.name);
    fprintf(out, "#include \"%s_bdd.h\"\n", lower_prefix);
    fprintf(out, "#include <stdio.h>\n");
    fprintf(out, "#include <stdlib.h>\n\n");

    /* Stub implementations for all unique steps */
    fprintf(out, "/* Step stub implementations — replace with real logic */\n");

    /* Build a lookup table: function name → original step text */
    for (int i = 0; i < unique_step_count; i++) {
        const char *text = NULL;
        char tmp[MAX_NAME];
        /* Search background steps */
        for (int j = 0; j < feature.background_count && !text; j++) {
            step_func_name(&feature.background[j], tmp, sizeof(tmp));
            if (strcmp(tmp, unique_step_funcs[i]) == 0)
                text = feature.background[j].text;
        }
        /* Search scenario steps */
        for (int s = 0; s < feature.scenario_count && !text; s++) {
            for (int j = 0; j < feature.scenarios[s].step_count && !text; j++) {
                step_func_name(&feature.scenarios[s].steps[j], tmp, sizeof(tmp));
                if (strcmp(tmp, unique_step_funcs[i]) == 0)
                    text = feature.scenarios[s].steps[j].text;
            }
        }
        if (!text) text = unique_step_funcs[i];

        fprintf(out, "int %s(void) {\n", unique_step_funcs[i]);
        fprintf(out, "    fprintf(stderr, \"PENDING: ");
        fwrite_escaped(out, text);
        fprintf(out, "\\n\");\n");
        fprintf(out, "    return 0;\n");
        fprintf(out, "}\n\n");
    }

    fprintf(out, "int main(void) {\n");
    fprintf(out, "    int rc = %s();\n", feat_fname);
    fprintf(out, "    return rc;\n");
    fprintf(out, "}\n");

    fclose(out);
    fprintf(stderr, "Generated %s\n", path);
    return 0;
}

static void generate_version(const char *outdir, const char *profile) {
    char path[MAX_PATH];
    snprintf(path, sizeof(path), "%s/GENERATOR_VERSION", outdir);
    FILE *out = fopen(path, "w");
    if (!out) return;
    time_t now = time(NULL);
    struct tm *t = gmtime(&now);
    fprintf(out, "bddgen %s\n", BDDGEN_VERSION);
    fprintf(out, "generated: %04d-%02d-%02dT%02d:%02d:%02dZ\n",
            t->tm_year + 1900, t->tm_mon + 1, t->tm_mday,
            t->tm_hour, t->tm_min, t->tm_sec);
    fprintf(out, "profile: %s\n", profile);
    fprintf(out, "feature: %s\n", feature.name);
    fprintf(out, "scenarios: %d\n", feature.scenario_count);
    fprintf(out, "background_steps: %d\n", feature.background_count);
    fclose(out);
}

/* ── Main ─────────────────────────────────────────────────────────── */

static void print_usage(void) {
    fprintf(stderr, "bddgen %s — Gherkin Feature File Parser\n", BDDGEN_VERSION);
    fprintf(stderr, "\n");
    fprintf(stderr, "Usage: bddgen <input.feature> [output_dir] [prefix]\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Parses Gherkin .feature files and generates a C test harness.\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Gherkin elements supported:\n");
    fprintf(stderr, "  Feature, Background, Scenario, Scenario Outline\n");
    fprintf(stderr, "  Given, When, Then, And, But, Examples, @tags\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Output files:\n");
    fprintf(stderr, "  <prefix>_bdd.h      — Step and scenario declarations\n");
    fprintf(stderr, "  <prefix>_bdd.c      — Scenario runners\n");
    fprintf(stderr, "  <prefix>_runner.c   — Main runner with step stubs\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Examples:\n");
    fprintf(stderr, "  bddgen specs/testing/e9livereload.feature gen/testing e9livereload\n");
    fprintf(stderr, "  bddgen myfeature.feature . myprefix\n");
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        print_usage();
        return 1;
    }

    /* --run mode: parse and report feature files, no output files generated */
    if (strcmp(argv[1], "--run") == 0) {
        int exit_code = 0;
        for (int i = 2; i < argc; i++) {
            memset(&feature, 0, sizeof(feature));
            if (parse_feature(argv[i]) != 0) {
                exit_code = 1;
                continue;
            }
            if (!feature.name[0]) {
                fprintf(stderr, "bddgen: warning: no Feature: in '%s'\n", argv[i]);
                continue;
            }
            fprintf(stdout, "Feature: %s (%d scenario(s), %d background step(s))\n",
                    feature.name, feature.scenario_count, feature.background_count);
            for (int s = 0; s < feature.scenario_count; s++) {
                fprintf(stdout, "  Scenario: %s (%d step(s))\n",
                        feature.scenarios[s].name, feature.scenarios[s].step_count);
            }
        }
        return exit_code;
    }

    const char *input   = argv[1];
    const char *outdir  = argc > 2 ? argv[2] : ".";
    const char *profile = getenv("PROFILE");
    if (!profile) profile = "portable";

    /* Derive default prefix from input filename stem */
    const char *basename = strrchr(input, '/');
    basename = basename ? basename + 1 : input;
    char default_prefix[MAX_NAME];
    strncpy(default_prefix, basename, sizeof(default_prefix) - 1);
    char *dot = strrchr(default_prefix, '.');
    if (dot) *dot = '\0';
    /* Convert to lower snake_case */
    for (char *p = default_prefix; *p; p++) {
        if (!isalnum((unsigned char)*p)) *p = '_';
        else *p = (char)tolower((unsigned char)*p);
    }

    const char *prefix = argc > 3 ? argv[3] : default_prefix;

    /* Lower-case copy of prefix for filenames */
    char lower_prefix[MAX_NAME];
    strncpy(lower_prefix, prefix, sizeof(lower_prefix) - 1);
    to_lower(lower_prefix);

    if (parse_feature(input) != 0) {
        return 1;
    }

    if (!feature.name[0]) {
        fprintf(stderr, "bddgen: error: no Feature: found in '%s'\n", input);
        return 1;
    }

    fprintf(stderr, "Parsed feature '%s': %d scenario(s), %d background step(s)\n",
            feature.name, feature.scenario_count, feature.background_count);

    if (ensure_output_dir(outdir) != 0) {
        return 1;
    }

    /* Collect unique step function names before generating */
    collect_unique_steps();

    if (generate_bdd_h(outdir, lower_prefix) != 0) return 1;
    if (generate_bdd_c(outdir, lower_prefix) != 0) return 1;
    if (generate_runner_c(outdir, lower_prefix) != 0) return 1;

    generate_version(outdir, profile);

    return 0;
}
