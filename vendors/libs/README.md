# Vendored Dependencies

These are single-file libraries vendored for Ring 0 self-sufficiency.
No external package manager required - just C + sh + make.

## Contents

| Library | Version | Purpose | License |
|---------|---------|---------|---------|
| yyjson | 0.10.0 | JSON serialization for `*_json.c` | MIT |
| sqlite3 | 3.45.0 | SQL persistence for `*_sql.c` | Public Domain |

## Usage

Generated code uses standard includes:
```c
#include <yyjson.h>   // JSON serialization
#include <sqlite3.h>  // SQL persistence
```

Build with: `cc -Ivendor ...`

## Updates

```sh
# yyjson
curl -sLO https://raw.githubusercontent.com/ibireme/yyjson/master/src/yyjson.h
curl -sLO https://raw.githubusercontent.com/ibireme/yyjson/master/src/yyjson.c

# sqlite3 (amalgamation)
curl -sL "https://www.sqlite.org/2024/sqlite-amalgamation-3450000.zip" -o sqlite.zip
unzip -q sqlite.zip && mv sqlite-amalgamation-*/sqlite3.{h,c} . && rm -rf sqlite-amalgamation-* sqlite.zip
```

## Cosmopolitan Compatibility

Both libraries compile cleanly with cosmocc for APE portability.
