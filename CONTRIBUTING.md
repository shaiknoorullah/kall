# Contributing to kall

Thank you for your interest in contributing to kall! This guide covers the conventions and processes you need to follow.

## Commit Conventions

All commits must follow the format:

```
type(area/name): description
```

**Types:**
- `feat` -- new feature
- `fix` -- bug fix
- `docs` -- documentation only
- `refactor` -- code restructuring without behavior change
- `test` -- adding or updating tests
- `chore` -- maintenance (CI, deps, configs)

**Areas:** `module`, `backend`, `plugin`, `lib`, `theme`, `installer`, `ci`, `schema`, `docs`

**Examples:**
```
feat(module/clipboard): add clipboard history support
fix(backend/rofi): handle missing config gracefully
test(lib/platform): add wayland clipboard tests
chore(ci/pipeline): update shellcheck version
```

## How to Add a Module

1. **Create the module directory:**

   ```
   modules/your-module/
   ```

2. **Add a `module.yml` descriptor:**

   ```yaml
   name: your-module
   version: "1.0.0"
   description: Brief description of what the module does
   platforms:
     - linux
     - macos
   dependencies: []
   ```

3. **Create the module script** (`modules/your-module/your-module.sh`):

   - Source the kall libraries you need via `lib/`
   - Use platform abstraction functions from `lib/platform.sh` instead of calling tools directly
   - Never call platform-specific tools (xclip, wl-copy, pbcopy, etc.) directly -- use the lib wrappers

4. **Add tests** (`tests/test_your-module.bats`):

   Every module must have a corresponding BATS test file. The CI will fail if a module directory exists without a matching test file.

5. **Run the full test suite:**

   ```bash
   ./tests/run_tests.sh
   ```

## How to Add a Backend

1. Create the backend adapter in `backends/your-backend.sh`
2. Implement the required interface functions that the menu abstraction expects
3. Add tests covering the backend's behavior
4. Document any external tool dependencies

## Platform Abstraction Rules

Modules must **never** call platform-specific tools directly. The following tools are forbidden in module code:

- Clipboard: `xclip`, `wl-copy`, `wl-paste`, `pbcopy`, `pbpaste`
- Screenshot: `grim`, `maim`, `screencapture`
- Window management: `hyprctl`, `i3-msg`, `swaymsg`, `xdotool`, `xrandr`
- Lock: `i3lock`

Instead, use the corresponding functions from `lib/platform.sh`.

## Testing Requirements

- All modules must have a BATS test file at `tests/test_<module-name>.bats`
- All tests must pass on Linux (X11 and Wayland) and macOS
- Run `shellcheck` on all shell scripts before submitting
- Run `shfmt -d -i 2 -ci` to verify formatting

```bash
# Run tests
./tests/run_tests.sh

# Run shellcheck
find . -name '*.sh' -not -path '*/test_helper/*' | xargs shellcheck

# Check formatting
find . -name '*.sh' -not -path '*/test_helper/*' | xargs shfmt -d -i 2 -ci
```

## Pull Request Process

1. Fork the repository and create a feature branch
2. Make your changes following the conventions above
3. Ensure all tests pass and linting is clean
4. Open a PR using the provided template
5. Fill in the summary, type, area, and checklist
6. Wait for CI to pass and a maintainer review

## Code Style

- Shell scripts use 2-space indentation
- Use `shfmt -i 2 -ci` formatting
- Follow shellcheck recommendations
- Use `local` for function-scoped variables
- Quote all variable expansions unless splitting is intentional

## Getting Help

- Open a [Discussion](https://github.com/shaiknoorullah/kall/discussions) for questions
- Check existing issues before filing a new one
- Use the issue templates provided
