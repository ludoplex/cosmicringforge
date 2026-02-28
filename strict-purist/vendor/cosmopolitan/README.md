# Cosmopolitan libc

Repository: https://github.com/jart/cosmopolitan
License: ISC

## Installation

Cosmopolitan provides `cosmocc` - a compiler that creates Actually Portable Executables (APE).

### Quick Install (cosmocc toolchain)

```sh
mkdir -p cosmocc
cd cosmocc
curl -sL https://cosmo.zip/pub/cosmocc/cosmocc.zip -o cosmocc.zip
unzip cosmocc.zip
export PATH="$PWD/bin:$PATH"
```

### Usage

```sh
# Compile with cosmocc instead of cc
cosmocc -o hello hello.c

# The resulting binary runs on:
# - Linux (x86_64, aarch64)
# - macOS (x86_64, arm64)
# - Windows (x86_64)
# - FreeBSD, OpenBSD, NetBSD
```

### APE Loader (Linux)

On Linux, install the APE loader for smoother execution:

```sh
sudo sh -c "echo ':APE:M::MZqFpD::/usr/bin/ape:' > /proc/sys/fs/binfmt_misc/register"
```

Or use the assimilate tool to convert APE to native ELF.
