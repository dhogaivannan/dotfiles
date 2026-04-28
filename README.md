# dotfiles

Personal dotfiles. Each top-level directory is a self-contained module —
clone the whole repo or pull pieces individually.

## Modules

| Module | Purpose |
|---|---|
| [`improved-ls/`](improved-ls/) | Rich colorized `ls` for fish shell, no extra binaries. Works on macOS + Linux. |

## Install (full clone)

```fish
git clone https://github.com/dhogaivannan/dotfiles ~/dotfiles
for installer in ~/dotfiles/*/install.fish
    $installer
end
```

## Install one module remotely (no clone)

Each module ships a `install-remote.sh` for a single-curl install — see the
module's own README. Example for `improved-ls`:

```bash
curl -fsSL https://raw.githubusercontent.com/dhogaivannan/dotfiles/main/improved-ls/install-remote.sh | bash
```
