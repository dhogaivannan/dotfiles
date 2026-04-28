#!/usr/bin/env fish
#
# Remove symlinks installed by install.fish. Leaves any .bak backups in place.

set -l repo_dir (realpath (status dirname))
set -l fish_dir $HOME/.config/fish

for f in $repo_dir/conf.d/*.fish $repo_dir/functions/*.fish
    set -l name (basename $f)
    set -l target
    if string match -q '*/conf.d/*' $f
        set target $fish_dir/conf.d/$name
    else
        set target $fish_dir/functions/$name
    end

    if test -L $target; and test (realpath $target) = (realpath $f)
        rm $target
        echo "  removed $target"
    end
end

echo
echo "Done. Open a new shell to drop the loaded functions."
