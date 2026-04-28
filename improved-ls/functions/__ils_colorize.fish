# Read `ls -lah` output on stdin, write colorized output on stdout.
# Preserves original column alignment by inserting ANSI codes inline
# rather than reformatting columns.
#
# Color scheme:
#   permission bits  r=yellow  w=red  x=green  -=dim  s/t=bold magenta
#   file type char   d=bold blue  l=bold cyan  -=grey  other=bold magenta
#   owner            cyan if you, magenta if someone else
#   group            dim cyan
#   size             gradient by unit: B dim-green, K green, M yellow, G red, T bold red
#   date             dim
#   name             bold blue dir / bold cyan link / bold green exec / dim hidden

function __ils_colorize
    awk -v me="$USER" '
    function ansi(code, s) { return "\033[" code "m" s "\033[0m" }
    function dim(s)        { return ansi("2", s) }

    function color_perms(p,    out, c, i, t) {
        out = ""
        t = substr(p, 1, 1)
        if (t == "d")      out = ansi("1;34", t)
        else if (t == "l") out = ansi("1;36", t)
        else if (t == "-") out = ansi("37",   t)
        else               out = ansi("1;35", t)
        for (i = 2; i <= length(p); i++) {
            c = substr(p, i, 1)
            if (c == "r")                                          out = out ansi("33", c)
            else if (c == "w")                                     out = out ansi("31", c)
            else if (c == "x")                                     out = out ansi("32", c)
            else if (c == "-")                                     out = out ansi("2",  c)
            else if (c == "@" || c == "+" || c == ".")             out = out ansi("90", c)
            else                                                   out = out ansi("1;35", c)
        }
        return out
    }

    function color_owner(s) { return (s == me) ? ansi("36", s) : ansi("35", s) }
    function color_group(s) { return ansi("2;36", s) }

    function color_size(s,    unit, code) {
        unit = substr(s, length(s), 1)
        if      (unit == "T") code = "1;31"
        else if (unit == "G") code = "31"
        else if (unit == "M") code = "33"
        else if (unit == "K") code = "32"
        else if (unit == "B") code = "2;32"
        else                  code = "2"
        return ansi(code, s)
    }

    function color_date(s) { return ansi("2", s) }

    function color_name(name, perms,    t, hidden) {
        t      = substr(perms, 1, 1)
        hidden = (substr(name, 1, 1) == ".") ? 1 : 0
        if (t == "d")      return ansi(hidden ? "2;34" : "1;34", name)
        if (t == "l")      return ansi("1;36", name)
        if (t == "-" && (substr(perms,4,1) == "x" || substr(perms,7,1) == "x" || substr(perms,10,1) == "x"))
            return ansi("1;32", name)
        if (hidden)        return ansi("2", name)
        return name
    }

    /^total / { print dim($0); next }

    {
        # Pass through directory headers (e.g., "subdir:") and blank lines.
        if ($0 !~ /^[-dlbcps]/) { print; next }

        out = ""
        rem = $0

        # 1. Permission bits + optional xattr/acl flag
        if (match(rem, /^[-dlbcps][-rwxstST]{9}[@+.]?/) == 0) { print rem; next }
        perms = substr(rem, 1, RLENGTH)
        out   = color_perms(perms)
        rem   = substr(rem, RLENGTH + 1)

        # 2. Whitespace + link count (digits)
        if (match(rem, /^ +[0-9]+/)) {
            out = out substr(rem, 1, RLENGTH)
            rem = substr(rem, RLENGTH + 1)
        }

        # 3. Whitespace + owner
        if (match(rem, /^ +[^ ]+/)) {
            tok = substr(rem, 1, RLENGTH)
            match(tok, /[^ ]+$/)
            out = out substr(tok, 1, RSTART - 1) color_owner(substr(tok, RSTART))
            rem = substr(rem, length(tok) + 1)
        }

        # 4. Whitespace + group
        if (match(rem, /^ +[^ ]+/)) {
            tok = substr(rem, 1, RLENGTH)
            match(tok, /[^ ]+$/)
            out = out substr(tok, 1, RSTART - 1) color_group(substr(tok, RSTART))
            rem = substr(rem, length(tok) + 1)
        }

        # 5. Whitespace + size (digits, optional decimal, optional unit)
        if (match(rem, /^ +[0-9]+(\.[0-9]+)?[BKMGT]?/)) {
            tok = substr(rem, 1, RLENGTH)
            match(tok, /[0-9]/)
            out = out substr(tok, 1, RSTART - 1) color_size(substr(tok, RSTART))
            rem = substr(rem, length(tok) + 1)
        }

        # 6. Date: "Mon DD HH:MM" or "Mon DD  YYYY"
        if (match(rem, /^ +[A-Za-z]+ +[0-9]+ +[0-9:]+/) || match(rem, /^ +[A-Za-z]+ +[0-9]+ +[0-9]{4}/)) {
            tok = substr(rem, 1, RLENGTH)
            match(tok, /[A-Za-z]/)
            out = out substr(tok, 1, RSTART - 1) color_date(substr(tok, RSTART))
            rem = substr(rem, length(tok) + 1)
        }

        # 7. Whitespace + filename (rest of line)
        if (match(rem, /^ +/)) {
            out = out substr(rem, 1, RLENGTH)
            rem = substr(rem, RLENGTH + 1)
        }
        out = out color_name(rem, perms)

        print out
    }'
end
