#!/usr/bin/env bash

# ls-wrapper
# Copyright (C) 2015 D630, GNU GPLv3
# <https://github.com/D630/ls-wrapper.sh>

# -- DEBUGGING.

#printf '%s (%s)\n' "$BASH_VERSION" "${BASH_VERSINFO[5]}" && exit 0
#set -o xtrace
#exec 2>> ~/ls-wrapper.sh.log
#set -o verbose
#set -o noexec
#set -o errexit
#set -o nounset
#set -o pipefail
#trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG

#declare vars_base=$(set -o posix ; set)
#fgrep -v -e "$vars_base" < <(set -o posix ; set) | \
#egrep -v -e "^BASH_REMATCH=" \
#         -e "^OPTIND=" \
#         -e "^REPLY=" \
#         -e "^BASH_LINENO=" \
#         -e "^BASH_SOURCE=" \
#         -e "^FUNCNAME=" | \
#less

# -- FUNCTIONS.

__ls_do ()
{
    unset -v \
        f \
        flags \
        ls_checksum \
        ls_checksum_command \
        ls_color \
        ls_command \
        ls_dir_name \
        ls_file_inode \
        ls_file_name \
        ls_flag_1 \
        ls_flag_A \
        ls_flag_C \
        ls_flag_F \
        ls_flag_H \
        ls_flag_L \
        ls_flag_R \
        ls_flag_S \
        ls_flag_a \
        ls_flag_c \
        ls_flag_d \
        ls_flag_f \
        ls_flag_g \
        ls_flag_i \
        ls_flag_k \
        ls_flag_l \
        ls_flag_m \
        ls_flag_n \
        ls_flag_o \
        ls_flag_p \
        ls_flag_q \
        ls_flag_r \
        ls_flag_s \
        ls_flag_t \
        ls_flag_u \
        ls_flag_x \
        ls_hook_post \
        ls_hook_post_tee \
        ls_hook_post_pipe \
        ls_hook_prae \
        ls_mkdir_command \
        ls_print_command \
        ls_remove ;

    (($# > 0)) && {
        if [[ $# -gt 2 ]]; then
            { IFS=" " printf '%s\n' "Too many arguments: '${*}'" 1>&2 ; return ; };
        else
            typeset f ls_file_name;
            for f in "$@"; do
                [[ "$f" == \-* || (-d "$f" && -n "${ls_file_name:=$f}") ]] || {
                    { printf '%s\n' "Cannot access '${f}': No such directory" 1>&2 ; return 1 ; }
                };
            done;
        fi;

        unset -v OPTIND opt;
        typeset OPTIND=1 opt;
        while getopts ":ACFHLRSacdfgiklmnopqrstux1" opt; do
            case "$opt" in
                A)
                    ls_flag_A=1
                ;;
                C)
                    ls_flag_C=1
                ;;
                F)
                    ls_flag_F=1
                ;;
                H)
                    ls_flag_H=1
                ;;
                L)
                    ls_flag_L=1
                ;;
                R)
                    ls_flag_R=1
                ;;
                S)
                    ls_flag_S=1
                ;;
                a)
                    ls_flag_a=1
                ;;
                c)
                    ls_flag_c=1
                ;;
                d)
                    ls_flag_d=1
                ;;
                f)
                    ls_flag_f=1
                ;;
                g)
                    ls_flag_g=1
                ;;
                i)
                    ls_flag_i=1
                ;;
                k)
                    ls_flag_k=1
                ;;
                l)
                    ls_flag_l=1
                ;;
                m)
                    ls_flag_m=1
                ;;
                n)
                    ls_flag_n=1
                ;;
                o)
                    ls_flag_o=1
                ;;
                p)
                    ls_flag_p=1
                ;;
                q)
                    ls_flag_q=1
                ;;
                r)
                    ls_flag_r=1
                ;;
                s)
                    ls_flag_s=1
                ;;
                t)
                    ls_flag_t=1
                ;;
                u)
                    ls_flag_u=1
                ;;
                x)
                    ls_flag_x=1
                ;;
                1)
                    ls_flag_1=1
                ;;
                \?)
                    { printf '%s\n' "Unknown flag: '-${OPTARG}'" 1>&2 ; return 1 ; }
                ;;
            esac;
        done;
    }

    typeset \
        ls_file_name="${LS_FILE_NAME:-${ls_file_name:-${PWD:-.}}}" \
        ls_dir_name="${LS_DIR_NAME:-${TMPDIR:-/tmp}/ls}";

    typeset ls_file_inode="${LS_FILE_INODE:-$(__ls_get_inode : "$ls_file_name")}";

    typeset -i \
        ls_color="${LS_COLOR:-0}" \
        ls_flag_A="${LS_FLAG_A:-${ls_flag_A}}" \
        ls_flag_C="${LS_FLAG_C:-${ls_flag_C}}" \
        ls_flag_F="${LS_FLAG_F:-${ls_flag_F}}" \
        ls_flag_H="${LS_FLAG_H:-${ls_flag_H}}" \
        ls_flag_L="${LS_FLAG_L:-${ls_flag_L}}" \
        ls_flag_R="${LS_FLAG_R:-${ls_flag_R}}" \
        ls_flag_S="${LS_FLAG_S:-${ls_flag_S}}" \
        ls_flag_a="${LS_FLAG_a:-${ls_flag_a}}" \
        ls_flag_c="${LS_FLAG_c:-${ls_flag_c}}" \
        ls_flag_d="${LS_FLAG_d:-${ls_flag_d}}" \
        ls_flag_f="${LS_FLAG_f:-${ls_flag_f}}" \
        ls_flag_g="${LS_FLAG_g:-${ls_flag_g}}" \
        ls_flag_i="${LS_FLAG_i:-${ls_flag_i}}" \
        ls_flag_k="${LS_FLAG_k:-${ls_flag_k}}" \
        ls_flag_l="${LS_FLAG_l:-${ls_flag_l}}" \
        ls_flag_m="${LS_FLAG_m:-${ls_flag_m}}" \
        ls_flag_n="${LS_FLAG_n:-${ls_flag_n}}" \
        ls_flag_o="${LS_FLAG_o:-${ls_flag_o}}" \
        ls_flag_p="${LS_FLAG_p:-${ls_flag_p}}" \
        ls_flag_q="${LS_FLAG_q:-${ls_flag_q}}" \
        ls_flag_r="${LS_FLAG_r:-${ls_flag_r}}" \
        ls_flag_s="${LS_FLAG_s:-${ls_flag_s}}" \
        ls_flag_t="${LS_FLAG_t:-${ls_flag_t}}" \
        ls_flag_u="${LS_FLAG_u:-${ls_flag_u}}" \
        ls_flag_x="${LS_FLAG_x:-${ls_flag_x}}" \
        ls_flag_1="${LS_FLAG_1:-${ls_flag_1}}" \
        ls_hook_post_tee="${LS_HOOK_POST_TEE:-0}" \
        ls_remove="${LS_REMOVE:-0}";

    typeset \
        ls_checksum_command="${LS_CHECKSUM_COMMAND:-md5sum}" \
        ls_hook_post="$LS_HOOK_POST" \
        ls_hook_post_pipe="$LS_HOOK_POST_PIPE" \
        ls_hook_prae="$LS_HOOK_PRAE" \
        ls_mkdir_command="${LS_MKDIR_COMMAND:-mkdir -p}" \
        ls_print_command="${LS_PRINT_COMMAND:-cat}" ;

    typeset ls_checksum="${LS_CHECKSUM:-$(__ls_get_checksum :)}";

    for f in ${!ls_flag_*} ${!ls_remove*}; do
        if ((${!f} == 1)); then
            eval typeset +i "${f}=\${f##*_}";
        else
            unset -v "$f"
        fi;
    done;

    flags="${ls_flag_A}${ls_flag_C}${ls_flag_F}${ls_flag_H}${ls_flag_L}${ls_flag_R}${ls_flag_S}${ls_flag_a}${ls_flag_c}${ls_flag_d}${ls_flag_f}${ls_flag_g}${ls_flag_i}${ls_flag_k}${ls_flag_l}${ls_flag_m}${ls_flag_n}${ls_flag_o}${ls_flag_p}${ls_flag_q}${ls_flag_r}${ls_flag_s}${ls_flag_t}${ls_flag_u}${ls_flag_x}${ls_flag_1}";

    if [[ -n "$flags" ]]; then
        flags="${flags/#/-}";
    else
        unset -v flags;
    fi;

    if [[ -f "${ls_dir_name}/${ls_file_inode}/${ls_checksum}" ]]; then
        if [[ -n "$ls_remove" ]]; then
            rm "${ls_dir_name}/${ls_file_inode}/${ls_checksum}";
        elif [[ -n "$ls_hook_post_pipe" ]]; then
            __ls_file_print | ${ls_hook_post_pipe};
        elif [[ -n "$ls_hook_post_tee" ]]; then
            __ls_file_print;
        elif [[ -n "$ls_hook_post" ]]; then
            ${ls_hook_post};
        fi;
    else
        __ls_mkdir;
        __ls_set_aliases;
        if ((ls_color == 0)); then
            typeset ls_command="__ls";
        else
            typeset ls_command="__ls_color";
        fi;
        if [[ -n "$ls_hook_prae" && -n "$ls_hook_post" ]]; then
            __ls_perform "$ls_command" |
            ${ls_hook_prae} > "${ls_dir_name}/${ls_file_inode}/${ls_checksum}";
            ${ls_hook_post};
        elif [[ -n "$ls_hook_prae" && -n "$ls_hook_post_pipe" ]]; then
            __ls_perform "$ls_command" |
            ${ls_hook_prae} |
            tee "${ls_dir_name}/${ls_file_inode}/${ls_checksum}" |
            ${ls_hook_post_pipe};
        elif [[ -n "$ls_hook_prae" && -n "$ls_hook_post_tee" ]]; then
            __ls_perform "$ls_command" |
            ${ls_hook_prae} |
            tee "${ls_dir_name}/${ls_file_inode}/${ls_checksum}";
        elif [[ -n "$ls_hook_prae" ]]; then
            __ls_perform "$ls_command" |
            ${ls_hook_prae} > "${ls_dir_name}/${ls_file_inode}/${ls_checksum}";
        elif [[ -n "$ls_hook_post" ]]; then
            __ls_perform "$ls_command" > "${ls_dir_name}/${ls_file_inode}/${ls_checksum}";
            ${ls_hook_post};
        elif [[ -n "$ls_hook_post_pipe" ]]; then
            __ls_perform "$ls_command" |
            tee "${ls_dir_name}/${ls_file_inode}/${ls_checksum}" |
            ${ls_hook_post_pipe};
        elif [[ -n "$ls_hook_post_tee" ]]; then
            __ls_perform "$ls_command" |
            tee "${ls_dir_name}/${ls_file_inode}/${ls_checksum}";
        else
            __ls_perform "$ls_command" > "${ls_dir_name}/${ls_file_inode}/${ls_checksum}";
        fi;
    fi
}

__ls_file_print ()
{
    ${ls_print_command} "${ls_dir_name}/${ls_file_inode}/${ls_checksum}"
}

__ls_find_inode ()
if [[ "$1" == ":" ]]; then
    find -H "${2}/." ! -name . -prune -inum "$3" -exec basename '{}' \; 2> /dev/null;
else
    eval "${1}=\$(find -H "${2}/." ! -name . -prune -inum "$3" -exec basename '{}' \; 2> /dev/null)";
    __ls_upvar "$1" "${!1}";
fi

__ls_get_checksum ()
if [[ "$1" == ":" ]]; then
    typeset +i s="$(${ls_checksum_command} <<-SUM
${COLUMNS}
${LANG}
${LC_ALL}
${LC_COLLATE}
${LC_CTYPE}
${LC_MESSAGES}
${LC_TIME}
${NLSPATH}
${TZ}
${ls_color}
${ls_file_inode}
${ls_flag_A}
${ls_flag_C}
${ls_flag_F}
${ls_flag_H}
${ls_flag_L}
${ls_flag_R}
${ls_flag_S}
${ls_flag_a}
${ls_flag_c}
${ls_flag_d}
${ls_flag_f}
${ls_flag_g}
${ls_flag_i}
${ls_flag_k}
${ls_flag_l}
${ls_flag_m}
${ls_flag_n}
${ls_flag_o}
${ls_flag_p}
${ls_flag_q}
${ls_flag_r}
${ls_flag_s}
${ls_flag_t}
${ls_flag_u}
${ls_flag_x}
${ls_flag_1}
SUM
)";
    printf '%s\n' "${s%% *}";
else
    eval "${1}=\$(${ls_checksum_command} <<-SUM
${COLUMNS}
${LANG}
${LC_ALL}
${LC_COLLATE}
${LC_CTYPE}
${LC_MESSAGES}
${LC_TIME}
${NLSPATH}
${TZ}
${ls_color}
${ls_file_inode}
${ls_flag_A}
${ls_flag_C}
${ls_flag_F}
${ls_flag_H}
${ls_flag_L}
${ls_flag_R}
${ls_flag_S}
${ls_flag_a}
${ls_flag_c}
${ls_flag_d}
${ls_flag_f}
${ls_flag_g}
${ls_flag_i}
${ls_flag_k}
${ls_flag_l}
${ls_flag_m}
${ls_flag_n}
${ls_flag_o}
${ls_flag_p}
${ls_flag_q}
${ls_flag_r}
${ls_flag_s}
${ls_flag_t}
${ls_flag_u}
${ls_flag_x}
${ls_flag_1}
SUM
)";
    __ls_upvar "$1" "${!1%% *}";
fi

__ls_get_inode ()
if [[ "$1" == ":" ]]; then
    typeset +i i="$(ls -1id "$2")";
    printf '%s\n' "${i%% *}";
else
    eval "${1}=\$(ls -1id "$2")";
    __ls_upvar "$1" "${!1%% *}";
fi

__ls_mkdir ()
{
    ${ls_mkdir_command} "${ls_dir_name}/${ls_file_inode}"
}

__ls_perform ()
{
    eval ${1} ${flags} "$ls_file_name"
}

__ls_remove_color ()
{
    sed "s,\x1B\[[0-9;]*[a-zA-Z],,g;s/^ *//"
}

__ls_set_aliases ()
if ! typeset -f ls ls_color > /dev/null 2>&1; then
    case "$(uname -s)" in
        Darwin | DragonFly | FreeBSD)
            function __ls ()
            {
                IFS=" " ls -G ${*}
            };
            function __ls_color ()
            {
                IFS=" " CLICOLOR_FORCE=1 ls -G ${*}
            }
        ;;
        OpenBSD)
            if -v colorls > /dev/null; then
                function __ls ()
                {
                    IFS=" " colorls -G ${*}
                };
                function __ls_color ()
                {
                    IFS=" " CLICOLOR_FORCE=1 colorls -G ${*}
                };
            else
                if -v gls > /dev/null; then
                    function __ls ()
                    {
                        IFS=" " gls --color=auto ${*}
                    };
                    function __ls_color ()
                    {
                        IFS=" " gls --color=always ${*}
                    };
                else
                    function __ls ()
                    {
                        IFS=" " ls ${*}
                    };
                    function __ls_color ()
                    {
                        IFS=" " ls ${*}
                    };
                fi;
            fi
        ;;
        *)
            function __ls ()
            {
                IFS=" " command ls --color=auto ${*}
            };
            function __ls_color ()
            {
                IFS=" " command ls --color=always ${*}
            }
        ;;
    esac;

    [[ -n "$2" ]] && {
        eval "${1}=\$(typeset -f "$2")";
        __ls_upvar "$1" "${!1}";
    };
fi

__ls_upvar ()
if unset -v "$1"; then
    if (($# == 2)); then
        eval "${1}=\${2}";
    else
        eval "${1}"'=("${@:2}")';
    fi;
fi
