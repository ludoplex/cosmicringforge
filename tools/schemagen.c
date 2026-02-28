/* MBSE Stacks — Schema Generator
 * Ring 0: Pure C, minimal bootstrap
 *
 * Generates C types, serializers, and validators from .schema specs.
 * This is the SELF-HOSTED version - types come from schemagen.schema.
 *
 * If schemagen_types.h doesn't exist, fall back to bootstrap types.
 * Usage: schemagen <input.schema> [output_dir] [prefix]
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdint.h>
#include <time.h>

#define SCHEMAGEN_VERSION "1.0.0"
#define MAX_LINE 1024
#define MAX_TYPES 256
#define MAX_FIELDS 64
#define MAX_NAME 64

/* ── Type System ────────────────────────────────────────────────────
 * DOGFOODING: When SCHEMAGEN_SELF_HOST is defined, use generated types.
 * Otherwise, fall back to bootstrap types (for initial build only).
 */

#ifdef SCHEMAGEN_SELF_HOST
/* ═══ SELF-HOSTED MODE ═══
 * Types come from schemagen_types.h (generated from schemagen.schema)
 * This is the correct dogfooding path.
 */
#include "schemagen_types.h"

typedef enum {
    TYPE_I8, TYPE_I16, TYPE_I32, TYPE_I64,
    TYPE_U8, TYPE_U16, TYPE_U32, TYPE_U64,
    TYPE_F32, TYPE_F64,
    TYPE_BOOL,
    TYPE_STRING,
    TYPE_STRUCT,
    TYPE_ARRAY,
    TYPE_POINTER,
} base_type_t;

/* Map generated types to internal names */
typedef SchemaField field_t;

/* type_def_t needs fields array which isn't in generated type */
typedef struct {
    char name[MAX_NAME];
    field_t fields[MAX_FIELDS];
    int field_count;
    int has_json;
} type_def_t;

#else
/* ═══ BOOTSTRAP MODE ═══
 * Hand-written types for initial bootstrap only.
 * Once schemagen_types.h exists, build with -DSCHEMAGEN_SELF_HOST
 */

typedef enum {
    TYPE_I8, TYPE_I16, TYPE_I32, TYPE_I64,
    TYPE_U8, TYPE_U16, TYPE_U32, TYPE_U64,
    TYPE_F32, TYPE_F64,
    TYPE_BOOL,
    TYPE_STRING,
    TYPE_STRUCT,
    TYPE_ARRAY,
    TYPE_POINTER,
} base_type_t;

typedef struct {
    char name[MAX_NAME];
    base_type_t base;
    char struct_name[MAX_NAME];
    int array_size;
    int is_pointer;
    int has_range;
    int64_t range_min, range_max;
    int has_default;
    int64_t default_val;
    int not_empty;
} field_t;

typedef struct {
    char name[MAX_NAME];
    field_t fields[MAX_FIELDS];
    int field_count;
    int has_json;
} type_def_t;

#endif /* SCHEMAGEN_SELF_HOST */

static type_def_t types[MAX_TYPES];
static int type_count = 0;

/* ── Utilities ────────────────────────────────────────────────────── */

/* Safe string copy that always null-terminates */
static void safe_strcpy(char *dest, const char *src, size_t dest_size) {
    if (dest_size == 0) return;
    size_t i;
    for (i = 0; i < dest_size - 1 && src[i] != '\0'; i++) {
        dest[i] = src[i];
    }
    dest[i] = '\0';
}

static void trim(char *s) {
    char *start = s;
    while (*start && isspace((unsigned char)*start)) start++;
    if (start != s) memmove(s, start, strlen(start) + 1);
    char *end = s + strlen(s) - 1;
    while (end > s && isspace((unsigned char)*end)) *end-- = '\0';
}

static const char* base_type_to_c(base_type_t t) {
    switch (t) {
        case TYPE_I8:  return "int8_t";
        case TYPE_I16: return "int16_t";
        case TYPE_I32: return "int32_t";
        case TYPE_I64: return "int64_t";
        case TYPE_U8:  return "uint8_t";
        case TYPE_U16: return "uint16_t";
        case TYPE_U32: return "uint32_t";
        case TYPE_U64: return "uint64_t";
        case TYPE_F32: return "float";
        case TYPE_F64: return "double";
        case TYPE_BOOL: return "bool";
        case TYPE_STRING: return "char";
        default: return "void";
    }
}

static base_type_t parse_base_type(const char *s) {
    if (strcmp(s, "i8") == 0)  return TYPE_I8;
    if (strcmp(s, "i16") == 0) return TYPE_I16;
    if (strcmp(s, "i32") == 0) return TYPE_I32;
    if (strcmp(s, "i64") == 0) return TYPE_I64;
    if (strcmp(s, "u8") == 0)  return TYPE_U8;
    if (strcmp(s, "u16") == 0) return TYPE_U16;
    if (strcmp(s, "u32") == 0) return TYPE_U32;
    if (strcmp(s, "u64") == 0) return TYPE_U64;
    if (strcmp(s, "f32") == 0) return TYPE_F32;
    if (strcmp(s, "f64") == 0) return TYPE_F64;
    if (strcmp(s, "bool") == 0) return TYPE_BOOL;
    if (strncmp(s, "string", 6) == 0) return TYPE_STRING;
    return TYPE_STRUCT;
}

/* ── Parser ───────────────────────────────────────────────────────── */

static int parse_field(const char *line, field_t *f) {
    memset(f, 0, sizeof(*f));

    char name[MAX_NAME], type_str[MAX_NAME];
    const char *colon = strchr(line, ':');
    if (!colon) return -1;

    int name_len = (int)(colon - line);
    if (name_len >= MAX_NAME) name_len = MAX_NAME - 1;
    memcpy(name, line, (size_t)name_len);
    name[name_len] = '\0';
    trim(name);
    safe_strcpy(f->name, name, MAX_NAME);

    const char *type_start = colon + 1;
    while (*type_start && isspace((unsigned char)*type_start)) type_start++;

    const char *bracket = strchr(type_start, '[');
    const char *space = strchr(type_start, ' ');
    const char *type_end = bracket ? bracket : (space ? space : type_start + strlen(type_start));

    int type_len = (int)(type_end - type_start);
    if (type_len >= MAX_NAME) type_len = MAX_NAME - 1;
    memcpy(type_str, type_start, (size_t)type_len);
    type_str[type_len] = '\0';
    trim(type_str);

    size_t len = strlen(type_str);
    if (len > 0 && type_str[len-1] == '*') {
        f->is_pointer = 1;
        type_str[len-1] = '\0';
        trim(type_str);
    }

    f->base = parse_base_type(type_str);
    if (f->base == TYPE_STRUCT) {
        safe_strcpy(f->struct_name, type_str, MAX_NAME);
    }

    if (bracket) {
        int size = 0;
        sscanf(bracket, "[%d]", &size);
        f->array_size = size;
    }

    const char *constraint = strstr(line, "range:");
    if (constraint) {
        sscanf(constraint, "range: %ld..%ld", &f->range_min, &f->range_max);
        f->has_range = 1;
    }

    constraint = strstr(line, "default:");
    if (constraint) {
        sscanf(constraint, "default: %ld", &f->default_val);
        f->has_default = 1;
    }

    if (strstr(line, "[not_empty]")) {
        f->not_empty = 1;
    }

    return 0;
}

static int parse_schema(const char *filename) {
    FILE *f = fopen(filename, "r");
    if (!f) {
        fprintf(stderr, "Error: Cannot open %s\n", filename);
        return -1;
    }

    char line[MAX_LINE];
    type_def_t *current = NULL;

    while (fgets(line, sizeof(line), f)) {
        trim(line);

        if (line[0] == '\0' || line[0] == '#') continue;

        if (line[0] == '@') {
            if (strncmp(line, "@json", 5) == 0 && current) {
                current->has_json = 1;
            }
            continue;
        }

        if (strncmp(line, "type ", 5) == 0) {
            if (type_count >= MAX_TYPES) {
                fprintf(stderr, "Error: Too many types\n");
                fclose(f);
                return -1;
            }

            current = &types[type_count++];
            memset(current, 0, sizeof(*current));

            char *name_start = line + 5;
            while (*name_start && isspace((unsigned char)*name_start)) name_start++;
            char *brace = strchr(name_start, '{');
            if (brace) *brace = '\0';
            trim(name_start);
            safe_strcpy(current->name, name_start, MAX_NAME);
            continue;
        }

        if (line[0] == '}') {
            current = NULL;
            continue;
        }

        if (current && strchr(line, ':')) {
            if (current->field_count >= MAX_FIELDS) {
                fprintf(stderr, "Error: Too many fields in %s\n", current->name);
                fclose(f);
                return -1;
            }
            parse_field(line, &current->fields[current->field_count++]);
        }
    }

    fclose(f);
    return 0;
}

/* ── Code Generation ──────────────────────────────────────────────── */

static void generate_header(FILE *out, const char *guard) {
    fprintf(out, "/* AUTO-GENERATED by schemagen %s — DO NOT EDIT */\n", SCHEMAGEN_VERSION);
    fprintf(out, "#ifndef %s\n", guard);
    fprintf(out, "#define %s\n\n", guard);
    fprintf(out, "#include <stdint.h>\n");
    fprintf(out, "#include <stdbool.h>\n");
    fprintf(out, "#include <stddef.h>\n\n");
}

static void generate_types_h(FILE *out, const char *guard_prefix) {
    char guard[128];
    snprintf(guard, sizeof(guard), "%s_TYPES_H", guard_prefix);

    generate_header(out, guard);

    /* Forward declarations */
    for (int i = 0; i < type_count; i++) {
        fprintf(out, "typedef struct %s %s;\n", types[i].name, types[i].name);
    }
    fprintf(out, "\n");

    /* Struct definitions */
    for (int i = 0; i < type_count; i++) {
        type_def_t *t = &types[i];
        fprintf(out, "struct %s {\n", t->name);

        for (int j = 0; j < t->field_count; j++) {
            field_t *f = &t->fields[j];

            if (f->base == TYPE_STRING) {
                fprintf(out, "    char %s[%d];\n", f->name, f->array_size > 0 ? f->array_size : 256);
            } else if (f->base == TYPE_STRUCT) {
                if (f->is_pointer) {
                    fprintf(out, "    %s *%s;\n", f->struct_name, f->name);
                } else {
                    fprintf(out, "    %s %s;\n", f->struct_name, f->name);
                }
            } else {
                fprintf(out, "    %s %s;\n", base_type_to_c(f->base), f->name);
            }
        }

        fprintf(out, "};\n\n");
    }

    /* Function declarations */
    for (int i = 0; i < type_count; i++) {
        type_def_t *t = &types[i];
        fprintf(out, "/* %s functions */\n", t->name);
        fprintf(out, "void %s_init(%s *obj);\n", t->name, t->name);
        fprintf(out, "bool %s_validate(const %s *obj);\n", t->name, t->name);
        if (t->has_json) {
            fprintf(out, "int %s_to_json(const %s *obj, char *buf, size_t size);\n", t->name, t->name);
            fprintf(out, "int %s_from_json(const char *json, %s *obj);\n", t->name, t->name);
        }
        fprintf(out, "\n");
    }

    fprintf(out, "#endif /* %s */\n", guard);
}

static void generate_types_c(FILE *out, const char *header_name) {
    fprintf(out, "/* AUTO-GENERATED by schemagen %s — DO NOT EDIT */\n\n", SCHEMAGEN_VERSION);
    fprintf(out, "#include \"%s\"\n", header_name);
    fprintf(out, "#include <string.h>\n\n");

    for (int i = 0; i < type_count; i++) {
        type_def_t *t = &types[i];

        /* Init function */
        fprintf(out, "void %s_init(%s *obj) {\n", t->name, t->name);
        fprintf(out, "    memset(obj, 0, sizeof(*obj));\n");
        for (int j = 0; j < t->field_count; j++) {
            field_t *f = &t->fields[j];
            if (f->has_default && f->base != TYPE_STRING) {
                fprintf(out, "    obj->%s = %ld;\n", f->name, f->default_val);
            }
            /* String defaults handled via default_str if implemented */
        }
        fprintf(out, "}\n\n");

        /* Validate function */
        fprintf(out, "bool %s_validate(const %s *obj) {\n", t->name, t->name);
        fprintf(out, "    if (!obj) return false;\n");
        for (int j = 0; j < t->field_count; j++) {
            field_t *f = &t->fields[j];
            if (f->has_range) {
                fprintf(out, "    if (obj->%s < %ld || obj->%s > %ld) return false;\n",
                        f->name, f->range_min, f->name, f->range_max);
            }
            if (f->not_empty && f->base == TYPE_STRING) {
                fprintf(out, "    if (obj->%s[0] == '\\0') return false;\n", f->name);
            }
        }
        fprintf(out, "    return true;\n");
        fprintf(out, "}\n\n");
    }
}

static void generate_version(FILE *out, const char *profile) {
    time_t now = time(NULL);
    struct tm *t = gmtime(&now);
    fprintf(out, "schemagen %s\n", SCHEMAGEN_VERSION);
    fprintf(out, "generated: %04d-%02d-%02dT%02d:%02d:%02dZ\n",
            t->tm_year + 1900, t->tm_mon + 1, t->tm_mday,
            t->tm_hour, t->tm_min, t->tm_sec);
    fprintf(out, "profile: %s\n", profile);
}

/* ── Main ─────────────────────────────────────────────────────────── */

static void print_usage(void) {
    fprintf(stderr, "schemagen %s — Schema-Driven C Type Generator\n", SCHEMAGEN_VERSION);
    fprintf(stderr, "\n");
    fprintf(stderr, "Usage: schemagen <input.schema> [output_dir] [prefix]\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Arguments:\n");
    fprintf(stderr, "  input.schema   Schema specification file\n");
    fprintf(stderr, "  output_dir     Output directory (default: current dir)\n");
    fprintf(stderr, "  prefix         Header guard prefix (default: MBSE)\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Environment:\n");
    fprintf(stderr, "  PROFILE        Build profile: portable (default), ape\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Example:\n");
    fprintf(stderr, "  schemagen types.schema gen/types MYAPP\n");
    fprintf(stderr, "  -> Generates: gen/types/myapp_types.h, myapp_types.c\n");
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        print_usage();
        return 1;
    }

    const char *input = argv[1];
    const char *outdir = argc > 2 ? argv[2] : ".";
    const char *prefix = argc > 3 ? argv[3] : "MBSE";
    const char *profile = getenv("PROFILE");
    if (!profile) profile = "portable";

    if (parse_schema(input) != 0) {
        return 1;
    }

    fprintf(stderr, "Parsed %d types from %s\n", type_count, input);

    char cmd[512];
    snprintf(cmd, sizeof(cmd), "mkdir -p %s", outdir);
    system(cmd);

    /* Generate <prefix>_types.h */
    char path[512];
    char header_name[128];
    snprintf(header_name, sizeof(header_name), "%s_types.h", prefix);
    for (char *p = header_name; *p; p++) *p = (char)tolower((unsigned char)*p);

    snprintf(path, sizeof(path), "%s/%s", outdir, header_name);
    FILE *out = fopen(path, "w");
    if (!out) {
        fprintf(stderr, "Error: Cannot create %s\n", path);
        return 1;
    }
    generate_types_h(out, prefix);
    fclose(out);
    fprintf(stderr, "Generated %s\n", path);

    /* Generate <prefix>_types.c */
    char impl_name[128];
    snprintf(impl_name, sizeof(impl_name), "%s_types.c", prefix);
    for (char *p = impl_name; *p; p++) *p = (char)tolower((unsigned char)*p);

    snprintf(path, sizeof(path), "%s/%s", outdir, impl_name);
    out = fopen(path, "w");
    if (!out) {
        fprintf(stderr, "Error: Cannot create %s\n", path);
        return 1;
    }
    generate_types_c(out, header_name);
    fclose(out);
    fprintf(stderr, "Generated %s\n", path);

    /* Generate version stamp */
    snprintf(path, sizeof(path), "%s/GENERATOR_VERSION", outdir);
    out = fopen(path, "w");
    if (out) {
        generate_version(out, profile);
        fclose(out);
    }

    return 0;
}
