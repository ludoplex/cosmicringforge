# gengetopt

CLI argument parser generator.

## Source
- URL: https://ftp.gnu.org/gnu/gengetopt/
- License: GPL-3.0

## To vendor:
```bash
curl -L https://ftp.gnu.org/gnu/gengetopt/gengetopt-2.23.tar.gz | tar xz
cp gengetopt-2.23/src/*.c gengetopt-2.23/src/*.h .
```

## APE Build
```bash
cosmocc -o gengetopt gengetopt.c ...
```

## Usage
```bash
./build/gengetopt -i myapp.ggo -F myapp_cli
```

## Note
gengetopt is GPL-3.0 licensed. The generated code is not GPL
(it includes a linking exception).
