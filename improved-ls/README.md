# improved-ls

Rich colorized `ls` for the fish shell, with **no extra binaries** — just the
system `ls` plus an inline awk colorizer. Works on macOS (BSD ls) and Linux
(GNU coreutils) — `conf.d/` detects which color flag to use at shell start.

Long listings (`ls -lah`, `ll`, `la`) get distinct colors per column:

| Column      | Coloring                                                         |
|-------------|------------------------------------------------------------------|
| Type char   | bold blue (dir), bold cyan (link), grey (file), magenta (other)  |
| Permissions | `r` yellow, `w` red, `x` green, `-` dim, `s/t` bold magenta      |
| Owner       | cyan if it's you, magenta if someone else                        |
| Group       | dim cyan                                                         |
| Size        | gradient by unit (B → K → M → G → T)                             |
| Date        | dim grey                                                         |
| Name        | bold blue dir, bold cyan link, bold green executable, dim hidden |

Short listings (`ls`) fall back to the system `ls`'s built-in coloring.

## Install

```fish
# from inside this dotfiles repo
~/dotfiles/improved-ls/install.fish
```

The installer symlinks `conf.d/*.fish` and `functions/*.fish` into
`~/.config/fish/`. Re-run anytime to refresh links.

If your `config.fish` already defines `alias ls=...`, the installer prints a
warning — that alias must be removed for the wrapper to take effect.

## Uninstall

```fish
~/dotfiles/improved-ls/uninstall.fish
```

Removes only the symlinks pointing back at this repo; backups (`.bak` files)
made during install are left in place.

## Layout

```
conf.d/
  improved-ls.fish          # CLICOLOR + LSCOLORS env (auto-loaded)
functions/
  ls.fish                   # wrapper: pipes -l invocations through colorizer
  ll.fish                   # ls -lahF
  la.fish                   # ls -lAhF (includes dotfiles)
  __ils_colorize.fish       # awk-based column colorizer
install.fish
uninstall.fish
```

## Tweaking colors

Edit `functions/__ils_colorize.fish`. Each column has its own
`color_*` function returning an ANSI-wrapped string. Standard SGR codes:

- `30-37` foreground, `90-97` bright foreground
- `1` bold, `2` dim, `4` underline
- `1;31` = bold red, `2;36` = dim cyan, etc.

For the file-type colors used by short `ls` (when the wrapper isn't piping
through the colorizer), edit `LSCOLORS` (BSD) or `LS_COLORS` (GNU) in
`conf.d/improved-ls.fish`. `man ls` documents the 11-pair LSCOLORS format;
`dircolors -p` dumps a starter LS_COLORS string.

## Caveats

- Filenames containing newlines aren't supported (neither is `ls -lah`'s
  default output, which escapes them, but the colorizer doesn't try to
  preserve that escaping).
- The colorizer parses default `ls -lah` output of BSD ls (macOS) and GNU
  coreutils ls (Linux). Custom `--time-style` formats or non-default
  locales may not parse cleanly — adjust the date regex in
  `functions/__ils_colorize.fish` if needed.
