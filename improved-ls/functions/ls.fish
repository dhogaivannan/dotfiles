# Wrapper around the system `ls`:
#   - long-format invocations (-l, -lah, --long, ...) get piped through
#     the colorizer so permission bits, owner, group, size and date all
#     pick up distinct colors.
#   - short-format invocations fall back to plain `ls` with the
#     platform-appropriate color flag (BSD `-G` on macOS, GNU
#     `--color=auto` on Linux), set once in conf.d/.
#   - non-TTY stdout (pipes, command substitution) always gets plain
#     output so downstream tools don't choke on ANSI codes.

function ls --wraps='command ls' --description 'colorized ls'
    set -l long 0
    for a in $argv
        switch $a
            case '--long'
                set long 1
                break
            case '--'
                break
            case '-*l*'
                # bundled short flags like -l, -lah, -hl
                set long 1
                break
        end
    end

    if test $long -eq 1; and isatty stdout
        command ls $argv | __ils_colorize
    else
        command ls $__ils_color_flag $argv
    end
end
