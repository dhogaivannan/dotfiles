#!/usr/bin/env fish
#
# Symlink this repo's conf.d/ and functions/ files into ~/.config/fish/.
# Re-running is safe: existing symlinks are overwritten, regular files are
# backed up to <name>.bak before being replaced.

set -l repo_dir (realpath (status dirname))
set -l fish_dir $HOME/.config/fish

mkdir -p $fish_dir/conf.d $fish_dir/functions

function __install_link --argument-names src dst
    if test -L $dst
        rm $dst
    else if test -e $dst
        echo "  backing up existing $dst -> $dst.bak"
        mv $dst $dst.bak
    end
    ln -s $src $dst
    echo "  linked $dst"
end

echo "Installing improved-ls from $repo_dir"

for f in $repo_dir/conf.d/*.fish
    __install_link $f $fish_dir/conf.d/(basename $f)
end

for f in $repo_dir/functions/*.fish
    __install_link $f $fish_dir/functions/(basename $f)
end

functions -e __install_link

# Warn about a common conflict: an inline `alias ls=...` in config.fish
# defines a function during shell startup, which prevents fish from
# autoloading our functions/ls.fish.
if test -f $fish_dir/config.fish
    if grep -qE '^[[:space:]]*alias[[:space:]]+ls[[:space:]]*=' $fish_dir/config.fish
        echo
        echo "WARNING: $fish_dir/config.fish defines `alias ls=...`."
        echo "         Remove or comment that line so this profile's ls wrapper takes effect."
    end
end

echo
echo "Done. Open a new shell, or run:"
echo "    source $fish_dir/conf.d/improved-ls.fish"
