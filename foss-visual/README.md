# FOSS Visual Stack

Best diagram-to-C productivity feel using open-source visual tools.

## Ring 2 Authoring Tools (outputs committed)

| Tool | Purpose | License | Toolchain |
|------|---------|---------|-----------|
| StateSmith | State machine → C | Apache-2.0 | .NET (C#) |
| EEZ Studio | GUI builder → C/C++ | GPL-3.0 | Node.js/Electron |
| LVGL | Embedded graphics library | MIT | N/A (runtime) |
| protobuf-c | Protocol Buffers → C | BSD-2-Clause | C++ compiler |
| OpenModelica | Modelica → C simulation | OSMC-PL | C++ compiler |

## Workflow

1. Create visual models (diagrams, GUIs, schemas)
2. Generate code using Ring-2 tools
3. Commit generated code to `gen/<tool>/`
4. Build with Ring-0 toolchain (C + sh only)

## Directory Structure

```
foss-visual/
├── vendor/           # Ring 2 tools (cloned)
│   ├── StateSmith/
│   ├── eez-studio/
│   ├── lvgl/
│   ├── protobuf-c/
│   └── openmodelica/
├── gen/              # Generated code (committed)
│   ├── statemachines/
│   ├── ui/
│   └── proto/
└── specs/            # Visual model sources
    ├── *.puml        # PlantUML state machines
    ├── *.eez-project # EEZ Studio projects
    └── *.proto       # Protocol Buffer definitions
```

## Usage

### StateSmith (State Machines)

```sh
# Install StateSmith CLI (.NET required)
dotnet tool install --global StateSmith.Cli

# Generate from PlantUML
ss.cli run -i specs/machine.puml -o gen/statemachines/
```

### protobuf-c (Data Serialization)

```sh
# Generate C code from .proto
protoc --c_out=gen/proto/ specs/messages.proto
```

### LVGL (Embedded GUI)

LVGL is a runtime library - include directly:
```c
#include "lvgl/lvgl.h"
```

### EEZ Studio (GUI Builder)

1. Open project in EEZ Studio
2. Build → generates C/C++ code
3. Copy to `gen/ui/`
