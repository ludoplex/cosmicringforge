/* Step definitions for BDD tests
 * Generated skeleton by bddgen 1.0.0
 * Implement each step function to make tests pass.
 */

#include "e9livereload_bdd.h"
#include <stdio.h>

/* Given an APE binary "target.com" is loaded */
E9LIVERELOAD_result_t step_an_ape_binary_targetcom_is_loaded(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given live reload is initialized with source directory "src/" */
E9LIVERELOAD_result_t step_live_reload_is_initialized_with_source_directory_src(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given the compiler "cosmocc" is available */
E9LIVERELOAD_result_t step_the_compiler_cosmocc_is_available(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a source file "src/main.c" exists */
E9LIVERELOAD_result_t step_a_source_file_srcmainc_exists(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When I modify "src/main.c" */
E9LIVERELOAD_result_t step_i_modify_srcmainc(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then a FILE_CHANGE event should be emitted */
E9LIVERELOAD_result_t step_a_file_change_event_should_be_emitted(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the event should contain the file path "src/main.c" */
E9LIVERELOAD_result_t step_the_event_should_contain_the_file_path_srcmainc(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a source file "src/README.md" exists */
E9LIVERELOAD_result_t step_a_source_file_srcreadmemd_exists(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When I modify "src/README.md" */
E9LIVERELOAD_result_t step_i_modify_srcreadmemd(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then no FILE_CHANGE event should be emitted */
E9LIVERELOAD_result_t step_no_file_change_event_should_be_emitted(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a valid C source file "src/func.c" */
E9LIVERELOAD_result_t step_a_valid_c_source_file_srcfuncc(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When a FILE_CHANGE event is detected for "src/func.c" */
E9LIVERELOAD_result_t step_a_file_change_event_is_detected_for_srcfuncc(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then a COMPILE_START event should be emitted */
E9LIVERELOAD_result_t step_a_compile_start_event_should_be_emitted(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then cosmocc should be invoked with "-c src/func.c" */
E9LIVERELOAD_result_t step_cosmocc_should_be_invoked_with_c_srcfuncc(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then a COMPILE_DONE event should be emitted */
E9LIVERELOAD_result_t step_a_compile_done_event_should_be_emitted(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the object file should be cached in ".e9cache/" */
E9LIVERELOAD_result_t step_the_object_file_should_be_cached_in_e9cache(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given an invalid C source file "src/broken.c" with syntax errors */
E9LIVERELOAD_result_t step_an_invalid_c_source_file_srcbrokenc_with_syntax_errors(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When a FILE_CHANGE event is detected for "src/broken.c" */
E9LIVERELOAD_result_t step_a_file_change_event_is_detected_for_srcbrokenc(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then a COMPILE_ERROR event should be emitted */
E9LIVERELOAD_result_t step_a_compile_error_event_should_be_emitted(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the error message should contain the compiler output */
E9LIVERELOAD_result_t step_the_error_message_should_contain_the_compiler_output(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then no patches should be generated */
E9LIVERELOAD_result_t step_no_patches_should_be_generated(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a cached object "func.c.o" from previous compilation */
E9LIVERELOAD_result_t step_a_cached_object_funcco_from_previous_compilation(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a new object "func.c.new.o" with changes to function "process_data" */
E9LIVERELOAD_result_t step_a_new_object_funccnewo_with_changes_to_function_process_data(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When Binaryen diffs the two objects */
E9LIVERELOAD_result_t step_binaryen_diffs_the_two_objects(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then a PATCH_GENERATED event should be emitted */
E9LIVERELOAD_result_t step_a_patch_generated_event_should_be_emitted(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the patch should target function "process_data" */
E9LIVERELOAD_result_t step_the_patch_should_target_function_process_data(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the patch should contain the address and replacement bytes */
E9LIVERELOAD_result_t step_the_patch_should_contain_the_address_and_replacement_bytes(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a cached object "func.c.o" */
E9LIVERELOAD_result_t step_a_cached_object_funcco(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a new object "func.c.new.o" with only whitespace changes */
E9LIVERELOAD_result_t step_a_new_object_funccnewo_with_only_whitespace_changes(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then no PATCH_GENERATED event should be emitted */
E9LIVERELOAD_result_t step_no_patch_generated_event_should_be_emitted(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the status should indicate "No changes detected" */
E9LIVERELOAD_result_t step_the_status_should_indicate_no_changes_detected(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a patch targeting PE RVA 0x11234 */
E9LIVERELOAD_result_t step_a_patch_targeting_pe_rva_0x11234(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given the APE has .text section at file offset 0x11000 with RVA 0x11000 */
E9LIVERELOAD_result_t step_the_ape_has_text_section_at_file_offset_0x11000_with_rva_0x11000(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When the patch is applied */
E9LIVERELOAD_result_t step_the_patch_is_applied(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the file offset should be calculated as 0x11234 */
E9LIVERELOAD_result_t step_the_file_offset_should_be_calculated_as_0x11234(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the bytes should be written to the memory-mapped binary */
E9LIVERELOAD_result_t step_the_bytes_should_be_written_to_the_memory_mapped_binary(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then a PATCH_APPLIED event should be emitted */
E9LIVERELOAD_result_t step_a_patch_applied_event_should_be_emitted(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a patch targeting PE RVA 0x2F100 */
E9LIVERELOAD_result_t step_a_patch_targeting_pe_rva_0x2f100(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given the APE has .rdata section at file offset 0x2F000 with RVA 0x2F000 */
E9LIVERELOAD_result_t step_the_ape_has_rdata_section_at_file_offset_0x2f000_with_rva_0x2f000(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the file offset should be calculated as 0x2F100 */
E9LIVERELOAD_result_t step_the_file_offset_should_be_calculated_as_0x2f100(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the patch should succeed */
E9LIVERELOAD_result_t step_the_patch_should_succeed(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given an APE with ZipOS starting at offset 0x60000 */
E9LIVERELOAD_result_t step_an_ape_with_zipos_starting_at_offset_0x60000(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a patch targeting file offset 0x60010 */
E9LIVERELOAD_result_t step_a_patch_targeting_file_offset_0x60010(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then a warning should be emitted about ZipOS overlap */
E9LIVERELOAD_result_t step_a_warning_should_be_emitted_about_zipos_overlap(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the patch may proceed with user acknowledgment */
E9LIVERELOAD_result_t step_the_patch_may_proceed_with_user_acknowledgment(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a patch was applied to executable .text section */
E9LIVERELOAD_result_t step_a_patch_was_applied_to_executable_text_section(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When the patch is finalized */
E9LIVERELOAD_result_t step_the_patch_is_finalized(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then e9wasm_flush_icache should be called */
E9LIVERELOAD_result_t step_e9wasm_flush_icache_should_be_called(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the flushed range should cover the patched bytes */
E9LIVERELOAD_result_t step_the_flushed_range_should_cover_the_patched_bytes(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given live reload is initialized with target NULL (self) */
E9LIVERELOAD_result_t step_live_reload_is_initialized_with_target_null_self(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When the executable path is determined via /proc/self/exe */
E9LIVERELOAD_result_t step_the_executable_path_is_determined_via_procselfexe(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the running APE should be memory-mapped */
E9LIVERELOAD_result_t step_the_running_ape_should_be_memory_mapped(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then patches should be applied in-place */
E9LIVERELOAD_result_t step_patches_should_be_applied_in_place(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then execution should continue with the new code */
E9LIVERELOAD_result_t step_execution_should_continue_with_the_new_code(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given live reload has processed multiple source changes */
E9LIVERELOAD_result_t step_live_reload_has_processed_multiple_source_changes(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When I query the statistics */
E9LIVERELOAD_result_t step_i_query_the_statistics(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then I should see: */
E9LIVERELOAD_result_t step_i_should_see(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given patch #1 was applied at offset 0x11234 */
E9LIVERELOAD_result_t step_patch_1_was_applied_at_offset_0x11234(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given the original bytes were saved */
E9LIVERELOAD_result_t step_the_original_bytes_were_saved(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When I revert patch #1 */
E9LIVERELOAD_result_t step_i_revert_patch_1(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the original bytes should be restored */
E9LIVERELOAD_result_t step_the_original_bytes_should_be_restored(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then a PATCH_REVERTED event should be emitted */
E9LIVERELOAD_result_t step_a_patch_reverted_event_should_be_emitted(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then the instruction cache should be flushed */
E9LIVERELOAD_result_t step_the_instruction_cache_should_be_flushed(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given the compiler "cosmocc" is not in PATH */
E9LIVERELOAD_result_t step_the_compiler_cosmocc_is_not_in_path(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When I call e9_livereload_compiler_available() */
E9LIVERELOAD_result_t step_i_call_e9_livereload_compiler_available(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then it should return false */
E9LIVERELOAD_result_t step_it_should_return_false(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then compilation attempts should fail with a clear error message */
E9LIVERELOAD_result_t step_compilation_attempts_should_fail_with_a_clear_error_message(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Given a target file that does not exist */
E9LIVERELOAD_result_t step_a_target_file_that_does_not_exist(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* When I initialize live reload with that target */
E9LIVERELOAD_result_t step_i_initialize_live_reload_with_that_target(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then initialization should fail with error "Cannot open target" */
E9LIVERELOAD_result_t step_initialization_should_fail_with_error_cannot_open_target(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

/* Then e9_livereload_get_error() should return the error message */
E9LIVERELOAD_result_t step_e9_livereload_get_error_should_return_the_error_message(E9LIVERELOAD_context_t *ctx) {
    (void)ctx; /* TODO: implement */
    return E9LIVERELOAD_PENDING;
}

