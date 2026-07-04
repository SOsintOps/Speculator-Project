<!-- Thanks for contributing to the Speculator Project. Please fill in the sections below. -->

## Summary

<!-- What does this PR change and why? -->

## Type of change

- [ ] Bug fix
- [ ] New tool / feature
- [ ] Documentation
- [ ] Refactor / maintenance

## Testing

- [ ] `bash -n` passes on every modified `.sh` script
- [ ] `shellcheck` reports no new errors
- [ ] `config/*.json` files are valid JSON (`jq empty`)
- [ ] Ran the installer on a clean Debian 13 "Trixie" VM (describe result below)

<!-- Describe how you tested the change. If you could not test on a VM, say so. -->

## Checklist

- [ ] No hardcoded user paths (uses `$HOME` / XDG variables, never `~`)
- [ ] All `pushd` calls have error handling
- [ ] No secrets, credentials or `.env` files committed
- [ ] `documents/CHANGELOG.md` updated (only at end of phase)
