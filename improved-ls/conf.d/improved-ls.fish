# improved-ls — rich colorized `ls` using only built-in ls + awk.
#
# This file is auto-loaded by fish on shell start (~/.config/fish/conf.d/).
# It only sets env vars; the real coloring lives in functions/.

# CLICOLOR=1 is the BSD-ls signal to emit color escapes when stdout is a TTY.
# GNU ls ignores it, but it's harmless there.
set -gx CLICOLOR 1

# LSCOLORS — BSD ls (macOS, FreeBSD). 11 fg/bg pairs in this order:
#   dir, link, socket, pipe, exec, block, char, setuid-exec,
#   setgid-exec, sticky-dir, no-sticky-dir.
# Letters: a black, b red, c green, d brown, e blue, f magenta, g cyan,
# h light grey; uppercase = bold; x = default.
set -gx LSCOLORS "ExGxFxdxCxegedabagacad"

# LS_COLORS — GNU ls (most Linux distros). Same intent as LSCOLORS above.
# Only set if not already configured by the system / dircolors.
if not set -q LS_COLORS
    set -gx LS_COLORS "di=01;34:ln=01;36:so=01;35:pi=33:ex=01;32:bd=33;01:cd=33;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:or=31;01"
end

# Decide which flag turns on color for short-format `ls`. Cached once so
# we don't shell out on every prompt.
if command ls --color=auto -d / >/dev/null 2>&1
    set -gx __ils_color_flag --color=auto
else
    set -gx __ils_color_flag -G
end
