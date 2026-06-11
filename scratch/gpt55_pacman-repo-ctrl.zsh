#!/usr/bin/env zsh

setopt ERR_RETURN PIPE_FAIL NO_UNSET

readonly PACMAN_CONF="/etc/pacman.conf"

autoload -Uz zargs 2>/dev/null || true

# repo_add_status - formatted status output
# @msg: text to display
# @type: ok|warn|err|info
repo_add_status() {
    local msg="$1"
    local type="${2:-info}"

    local reset bold green yellow red blue

    reset="$(tput sgr0 2>/dev/null)"
    bold="$(tput bold 2>/dev/null)"
    green="$(tput setaf 2 2>/dev/null)"
    yellow="$(tput setaf 3 2>/dev/null)"
    red="$(tput setaf 1 2>/dev/null)"
    blue="$(tput setaf 4 2>/dev/null)"

    case "$type" in
        ok)   print -- "${bold}${green}[OK]${reset} $msg" ;;
        warn) print -- "${bold}${yellow}[WARN]${reset} $msg" ;;
        err)  print -- "${bold}${red}[ERR]${reset} $msg" ;;
        *)    print -- "${bold}${blue}[INFO]${reset} $msg" ;;
    esac
}

# repo_require_root - enforce root execution
repo_require_root() {
    (( EUID == 0 )) || {
        repo_add_status "root privileges required" err
        return 1
    }
}

# repo_backup_conf - create timestamped backup
# returns: backup path on stdout
repo_backup_conf() {
    local ts backup

    ts="$(date '+%Y%m%d_%H%M%S')"
    backup="/tmp/pacman.conf.${ts}.bak"

    cp -a -- "$PACMAN_CONF" "$backup" || return 1

    print -r -- "$backup"
}

# repo_escape_regex - escape regex chars
# @str: input string
repo_escape_regex() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\[/\\[}"
    str="${str//\]/\\]}"
    str="${str//\./\\.}"
    str="${str//\*/\\*}"
    str="${str//\^/\\^}"
    str="${str//\$/\\$}"
    str="${str//\+/\\+}"
    str="${str//\?/\\?}"
    str="${str//\(/\\(}"
    str="${str//\)/\\)}"
    print -r -- "$str"
}

# repo_extract_name - extract repo name from block
# @block: repository stanza
repo_extract_name() {
    local block="$1"

    awk '
        /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
            gsub(/^[[:space:]]*\[/,"")
            gsub(/\][[:space:]]*$/,"")
            print
            exit
        }
    ' <<< "$block"
}

# repo_extract_header_line - obtain literal repo header
repo_extract_header_line() {
    local block="$1"

    awk '
        /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
            print
            exit
        }
    ' <<< "$block"
}

# repo_locate - detect repo state in pacman.conf
# stdout: active|commented|missing
repo_locate() {
    local repo="$1"
    local esc

    esc="$(repo_escape_regex "$repo")"

    if grep -Eq "^[[:space:]]*\[${esc}\][[:space:]]*$" "$PACMAN_CONF"; then
        print active
        return 0
    fi

    if grep -Eq "^[[:space:]]*#[[:space:]]*\[${esc}\][[:space:]]*$" "$PACMAN_CONF"; then
        print commented
        return 0
    fi

    print missing
}

# repo_find_block_range
# @repo: repository name
# stdout: start:end
repo_find_block_range() {
    local repo="$1"

    awk -v repo="$repo" '
        BEGIN {
            start=0
            end=0
        }

        /^[[:space:]]*#/ {
            next
        }

        /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
            section=$0
            gsub(/^[[:space:]]*\[/,"",section)
            gsub(/\][[:space:]]*$/,"",section)

            if (section == repo) {
                start=NR
                next
            }

            if (start && !end) {
                end=NR-1
                print start ":" end
                exit
            }
        }

        END {
            if (start && !end)
                print start ":" NR
        }
    ' "$PACMAN_CONF"
}

# repo_uncomment_existing - enable existing repo section
repo_uncomment_existing() {
    local repo="$1"
    local esc

    esc="$(repo_escape_regex "$repo")"

    perl -0pi -e "
        s{
            ^([ \t]*)\#[ \t]*(\\[$esc\\][ \t]*)
        }{\$1\$2}gmx
    " "$PACMAN_CONF" || return 1
}

# repo_compare_block - compare existing block with desired
# returns:
# 0 same
# 1 differs
repo_compare_block() {
    local repo="$1"
    local desired="$2"

    local range start end current
    range="$(repo_find_block_range "$repo")" || return 1

    [[ -n "$range" ]] || return 1

    start="${range%%:*}"
    end="${range##*:}"

    current="$(sed -n "${start},${end}p" "$PACMAN_CONF")"

    local norm_current norm_desired

    norm_current="$(
        print -r -- "$current" \
        | sed -E '
            s/[[:space:]]+$//
            /^[[:space:]]*#/d
            /^[[:space:]]*$/d
        '
    )"

    norm_desired="$(
        print -r -- "$desired" \
        | sed -E '
            s/[[:space:]]+$//
            /^[[:space:]]*#/d
            /^[[:space:]]*$/d
        '
    )"

    [[ "$norm_current" == "$norm_desired" ]]
}

# repo_append_block - append repo stanza
repo_append_block() {
    local block="$1"

    {
        print
        print -r -- "$block"
        print
    } >> "$PACMAN_CONF"
}

# repo_db_refresh - update package database
repo_db_refresh() {
    pacman -Sy --noconfirm >/dev/null 2>&1
}

# repo_restore_backup
repo_restore_backup() {
    local backup="$1"

    [[ -f "$backup" ]] || return 1

    cp -af -- "$backup" "$PACMAN_CONF"
}

# repo_add_block
# @block: full repository stanza
repo_add_block() {
    local block="$1"

    local repo
    local state
    local backup

    repo="$(repo_extract_name "$block")"

    [[ -n "$repo" ]] || {
        repo_add_status "unable to determine repository name" err
        return 1
    }

    repo_require_root || return 1

    backup="$(repo_backup_conf)" || {
        repo_add_status "failed creating pacman.conf backup" err
        return 1
    }

    state="$(repo_locate "$repo")"

    case "$state" in
        active)
            if repo_compare_block "$repo" "$block"; then
                repo_add_status "repository '$repo' already present" ok
                return 0
            fi

            repo_add_status \
                "repository '$repo' exists but differs from provided definition" warn
            return 2
        ;;

        commented)
            repo_add_status \
                "repository '$repo' found commented; enabling existing section" warn

            repo_uncomment_existing "$repo" || {
                repo_restore_backup "$backup"
                repo_add_status "failed enabling repository '$repo'" err
                return 1
            }
        ;;

        missing)
            repo_append_block "$block" || {
                repo_restore_backup "$backup"
                repo_add_status "failed writing repository '$repo'" err
                return 1
            }
        ;;
    esac

    if repo_db_refresh; then
        repo_add_status "repository '$repo' added successfully" ok
        return 0
    fi

    repo_restore_backup "$backup" || \
        repo_add_status "automatic restore failed; backup: $backup" err

    repo_add_status \
        "pacman database refresh failed; configuration reverted" err

    return 1
}

# repo_add_many
# @args: one or more repo stanzas
repo_add_many() {
    local stanza

    for stanza in "$@"; do
        repo_add_block "$stanza" || return $?
    done
}

# Example:
#
# repo_add_block '
# [herecura]
# Server = https://repo.herecura.eu/$repo/$arch
# '
#
# repo_add_many \
# "$repo1" \
# "$repo2"