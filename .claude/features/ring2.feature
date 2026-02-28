Feature: Ring 2 Tools - External Toolchains
  As a developer using CosmicRingForge
  I want to use Ring 2 visual authoring tools
  So that I can design state machines, protocols, and UIs visually

  Background:
    Given Ring 2 tools generate Ring 0 compatible C code
    And generated code is committed to gen/ directory
    And generated code passes drift verification

  # ═══ StateSmith ══════════════════════════════════════════════

  @statesmith
  Scenario: Generate C code from draw.io state machine
    Given a draw.io file with StateSmith-annotated states:
      | State | Entry Action | Exit Action |
      | Idle  | led_off()    |             |
      | Active| led_on()     | led_off()   |
    And transitions:
      | From   | To     | Event   | Guard        |
      | Idle   | Active | START   |              |
      | Active | Idle   | STOP    |              |
      | Active | Active | TICK    | count < 10   |
    When I run StateSmith.Cli on the file
    Then it should generate {name}.h with state enum
    And it should generate {name}.c with transition logic
    And entry/exit actions should be called correctly

  @statesmith
  Scenario: StateSmith generates hierarchical state machine
    Given a draw.io with nested states:
      """
      Operating
        ├── Running
        │   ├── Normal
        │   └── Boosted
        └── Paused
      Error
      """
    When I run StateSmith.Cli
    Then the generated code should handle state hierarchy
    And parent state transitions should propagate to children
    And history states should be supported

  @statesmith @ring0
  Scenario: StateSmith output is Ring 0 compatible
    Given StateSmith generated code
    When I compile with cosmocc
    Then it should compile without errors
    And it should not require C++ runtime
    And it should not require external dependencies

  # ═══ Protobuf-C ══════════════════════════════════════════════

  @protobuf
  Scenario: Generate C code from .proto file
    Given a .proto file:
      """
      syntax = "proto3";
      message Point {
          int32 x = 1;
          int32 y = 2;
          string label = 3;
      }
      """
    When I run protoc-c on the file
    Then it should generate point.pb-c.h
    And it should generate point.pb-c.c
    And Point struct should have x, y, label fields

  @protobuf
  Scenario: Protobuf pack/unpack roundtrip
    Given a protobuf message type
    When I create an instance and pack it
    And I unpack the binary data
    Then the unpacked values should match original

  @protobuf
  Scenario: Protobuf handles nested messages
    Given a .proto with nested messages:
      """
      message Outer {
          message Inner {
              int32 value = 1;
          }
          Inner nested = 1;
          repeated Inner items = 2;
      }
      """
    When I run protoc-c
    Then nested message types should be generated
    And repeated fields should use arrays

  @protobuf @ring0
  Scenario: Protobuf-C output is Ring 0 compatible
    Given protobuf-c generated code
    When I compile with cosmocc
    Then it should compile without errors
    And it should link with protobuf-c runtime

  # ═══ EEZ Studio ══════════════════════════════════════════════

  @eez
  Scenario: Generate LVGL code from EEZ project
    Given an EEZ Studio project with:
      | Page    | Widgets                    |
      | Main    | Label, Button, Slider      |
      | Settings| Checkbox, Dropdown, Input  |
    When I build the EEZ project
    Then it should generate screens/main.c
    And it should generate screens/settings.c
    And it should generate ui.h with screen declarations

  @eez
  Scenario: EEZ generates data bindings
    Given an EEZ project with data items:
      | Name        | Type    | Default |
      | temperature | float   | 25.0    |
      | mode        | enum    | AUTO    |
    When I build the EEZ project
    Then data item getters should be generated
    And data item setters should be generated
    And widgets bound to data should update

  @eez
  Scenario: EEZ generates action handlers
    Given an EEZ project with actions:
      | Action     | Type   |
      | onStart    | native |
      | onSettings | navigate |
    When I build the EEZ project
    Then action stubs should be generated
    And button clicks should trigger actions

  @eez @ring0
  Scenario: EEZ output works with LVGL on embedded
    Given EEZ generated code
    And LVGL library compiled for target
    When I compile the UI code
    Then it should link with LVGL
    And it should render on the display

  # ═══ OpenModelica ════════════════════════════════════════════

  @openmodelica
  Scenario: Generate simulation code from Modelica
    Given a Modelica model:
      """
      model Pendulum
          parameter Real L = 1.0 "length";
          parameter Real g = 9.81 "gravity";
          Real theta(start = 0.1) "angle";
          Real omega(start = 0) "angular velocity";
      equation
          der(theta) = omega;
          der(omega) = -g/L * sin(theta);
      end Pendulum;
      """
    When I compile with omc
    Then it should generate Pendulum.c
    And it should generate Pendulum_functions.c
    And the simulation should solve the ODE

  @openmodelica
  Scenario: Export FMU from Modelica model
    Given a Modelica model
    When I export as FMU 2.0
    Then it should generate {model}.fmu
    And the FMU should be loadable by FMI tools
    And it should support Co-Simulation

  # ═══ WebAssembly (Binaryen + WAMR) ═══════════════════════════

  @wasm @binaryen
  Scenario: Optimize WASM with wasm-opt
    Given a WASM module compiled from C
    When I run wasm-opt -O3
    Then the output should be smaller
    And the output should be functionally equivalent

  @wasm @binaryen
  Scenario: Generate WASM from C with WASI
    Given a C file with main() and stdio:
      """
      #include <stdio.h>
      int main() {
          printf("Hello WASM\n");
          return 0;
      }
      """
    When I compile with clang --target=wasm32-wasi
    And I optimize with wasm-opt
    Then it should produce a valid WASM module
    And it should run in WASI-compatible runtimes

  @wasm @wamr
  Scenario: Execute WASM with WAMR runtime
    Given an optimized WASM module
    And WAMR runtime linked into the application
    When I load and execute the module
    Then exported functions should be callable
    And imports should be resolved to native functions

  @wasm @wamr @ring0
  Scenario: WAMR interpreter is Ring 0 compatible
    Given WAMR compiled in interpreter mode
    When I compile with cosmocc
    Then it should produce a working APE binary
    And it should execute WASM modules portably

  @wasm @embedding
  Scenario: Embed WASM in APE binary
    Given a WASM module
    When I run bin2c to embed it
    And link with WAMR runtime
    Then the APE binary should contain the WASM
    And it should execute the WASM at runtime

  # ═══ Drift Verification ══════════════════════════════════════

  @ring2 @drift
  Scenario: Ring 2 output passes drift check
    Given Ring 2 tools have generated code in gen/
    When I run ./scripts/regen-all.sh --verify
    Then git diff --exit-code gen/ should pass
    And all generated files should be committed

  @ring2 @drift
  Scenario: CI blocks uncommitted Ring 2 changes
    Given a PR with Ring 2 source changes
    But generated code not updated
    When CI runs drift verification
    Then the check should fail
    And it should list files that need regeneration
