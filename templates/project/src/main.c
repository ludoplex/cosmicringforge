/*
 * main.c - cosmo-bde Project Template
 *
 * Uses generated types from specs/domain/app.schema
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "app_types.h"

/* This function can be hot-patched with live reload */
const char *get_greeting(void) {
    return "Hello from cosmo-bde!";
}

void print_config(const AppConfig *config) {
    printf("App: %s v%s\n", config->name, config->version);
    printf("Debug: %s\n", config->debug ? "on" : "off");
    printf("Log level: %d\n", config->log_level);
}

int main(int argc, char **argv) {
    (void)argc;
    (void)argv;

    /* Initialize config using generated init function */
    AppConfig config;
    AppConfig_init(&config);

    /* Set values */
    strncpy(config.name, "MyApp", sizeof(config.name) - 1);
    strncpy(config.version, "1.0.0", sizeof(config.version) - 1);
    config.debug = 1;
    config.log_level = 3;

    /* Validate using generated validate function */
    if (!AppConfig_validate(&config)) {
        fprintf(stderr, "Invalid config\n");
        return 1;
    }

    print_config(&config);
    printf("\n");

    /* Main loop - demonstrates live reload capability */
    printf("Running... (edit src/main.c to see live reload)\n");
    printf("Press Ctrl+C to exit\n\n");

    while (1) {
        printf("[app] %s\n", get_greeting());
        fflush(stdout);
        sleep(2);
    }

    return 0;
}
