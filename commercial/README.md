# Commercial MBSE Stack

This stack supports safety-critical and certification-oriented code generation using vendor toolchains.

## Required Tools (Proprietary)

| Tool | Vendor | Purpose | License |
|------|--------|---------|---------|
| IBM Rhapsody | IBM | State machines, UML → C/C++ | Commercial |
| MATLAB/Simulink | MathWorks | Model-based design | Commercial |
| Simulink Coder | MathWorks | C/C++ code generation | Commercial |
| Embedded Coder | MathWorks | Production-quality codegen | Commercial |
| RTI Connext DDS | RTI | DDS middleware, IDL→C | Commercial/Community |
| Qt Design Studio | Qt Company | QML/C++ UI generation | Commercial/GPL |

## Installation

Install required tools from their respective vendors:

- **Rhapsody**: https://www.ibm.com/products/rhapsody
- **MATLAB/Simulink**: https://www.mathworks.com/products/simulink.html
- **RTI Connext**: https://www.rti.com/products/connext-dds-professional
- **Qt Design Studio**: https://www.qt.io/product/ui-design-tools

## gen/ Directory

Generated code from commercial tools goes in `gen/`:

```
gen/
├── rhapsody/          # IBM Rhapsody generated code
├── simulink/          # Simulink/Embedded Coder generated code
├── rtidds/            # rtiddsgen type support code
└── qt/                # Qt Design Studio generated code
```

## Workflow

1. Create models in commercial tools
2. Generate code to `gen/<tool>/`
3. Add `GENERATOR_VERSION` stamp file
4. Commit generated outputs (Ring-2 rule)
5. Run `make regen-check` to verify no drift
