/* ═══════════════════════════════════════════════════════════════════════
 * cosmo-bde — BDE with Models
 * Template main.c
 * ═══════════════════════════════════════════════════════════════════════
 */

#include <stdio.h>
#include "example_types.h"

int main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;

    printf("cosmo-bde — BDE with Models\n");
    printf("Behavior Driven Engineering with Models\n\n");

    /* Use generated type */
    Example ex;
    Example_init(&ex);
    ex.id = 42;
    snprintf(ex.name, sizeof(ex.name), "Hello from specs!");
    ex.value = 100;
    ex.enabled = 1;

    printf("Example struct:\n");
    printf("  id:      %lu\n", (unsigned long)ex.id);
    printf("  name:    %s\n", ex.name);
    printf("  value:   %d\n", ex.value);
    printf("  enabled: %d\n", ex.enabled);
    printf("\n");

    if (Example_validate(&ex)) {
        printf("Validation: PASSED\n");
    } else {
        printf("Validation: FAILED\n");
    }

    return 0;
}
