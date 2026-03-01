# .forge/ - cosmo-bde Meta-Development

**For developing cosmo-bde ITSELF, not for template users.**

## Two Protocols

| You Are... | Use This | CI Workflow | Tests |
|------------|----------|-------------|-------|
| **Developing cosmo-bde** | `.forge/` scripts | `repo-ci.yml` | `.forge/meta-test.sh` |
| **Using the template** | `scripts/` | `template-ci.yml` | `scripts/test.sh` |

## Meta Scripts

| Script | Purpose |
|--------|---------|
| `meta-test.sh` | Test generators, verify format coverage |
| `meta-release.sh` | Prepare release, bump versions |
| `meta-docs.sh` | Regenerate docs from structure |
| `meta-audit.sh` | Audit format coverage, find gaps |

## Ground Truth

Single source of truth: **directory structure + Makefile pattern rules**.

`INTEROP_MATRIX.md` is the human-readable specification derived from this structure.
