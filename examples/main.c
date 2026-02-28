/*
 * CosmicRingForge Example
 * Demonstrates generated types from config.schema
 *
 * Build: make example
 */

#include <stdio.h>
#include <string.h>

/* Generated types from config.schema */
#include "config_types.h"

int main(void)
{
    printf("╔══════════════════════════════════════════════════════════════╗\n");
    printf("║           CosmicRingForge - Example Application              ║\n");
    printf("╚══════════════════════════════════════════════════════════════╝\n\n");

    /* Initialize with defaults */
    AppConfig app;
    AppConfig_init(&app);

    /* Set values */
    strncpy(app.name, "MyApp", sizeof(app.name) - 1);
    app.name[sizeof(app.name) - 1] = '\0';
    app.port = 3000;
    app.debug_mode = 1;

    /* Display */
    printf("── App Configuration ──\n");
    printf("  Name:            %s\n", app.name);
    printf("  Version:         %s\n", app.version);
    printf("  Port:            %d\n", app.port);
    printf("  Max Connections: %d\n", app.max_connections);
    printf("  Debug Mode:      %s\n", app.debug_mode ? "ON" : "OFF");
    printf("  Timeout:         %d ms\n", app.timeout_ms);

    if (AppConfig_validate(&app)) {
        printf("  Status:          ✓ Valid\n");
    } else {
        printf("  Status:          ✗ Invalid\n");
    }

    printf("\n── Database Configuration ──\n");
    DatabaseConfig db;
    DatabaseConfig_init(&db);
    strncpy(db.database, "cosmicforge", sizeof(db.database) - 1);
    db.database[sizeof(db.database) - 1] = '\0';
    strncpy(db.username, "admin", sizeof(db.username) - 1);
    db.username[sizeof(db.username) - 1] = '\0';

    printf("  Host:            %s\n", db.host);
    printf("  Port:            %d\n", db.port);
    printf("  Database:        %s\n", db.database);
    printf("  Username:        %s\n", db.username);
    printf("  Pool Size:       %d\n", db.max_pool_size);

    if (DatabaseConfig_validate(&db)) {
        printf("  Status:          ✓ Valid\n");
    } else {
        printf("  Status:          ✗ Invalid\n");
    }

    printf("\n── Full Server Configuration ──\n");
    ServerConfig server;
    ServerConfig_init(&server);
    server.app = app;
    server.db = db;
    server.log_level = 3;

    printf("  Log Level:       %d\n", server.log_level);

    if (ServerConfig_validate(&server)) {
        printf("  Status:          ✓ Valid\n");
    } else {
        printf("  Status:          ✗ Invalid\n");
    }

    printf("\n── Ring Classification ──\n");
    printf("  This example uses:\n");
    printf("    Ring 0: schemagen (generated config_types.h)\n");
    printf("    Ring 0: Pure C, no external dependencies\n");
    printf("\n");
    printf("  Schema: examples/config.schema\n");
    printf("  Generated: examples/gen/config_types.{h,c}\n");
    printf("\n");

    return 0;
}
