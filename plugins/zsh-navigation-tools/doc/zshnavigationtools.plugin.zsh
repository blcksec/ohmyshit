# The preamble comments apply when using ZNT as autoload functions
# https://github.com/psprint/zsh-navigation-tools
# License is GPLv3 and MIT
# 2ca0da66c41d1829c42915b6c298289a7ef5c2b9 refs/heads/master

n-aliases() {
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-aliases` to .zshrc
#
# This function allows to choose an alias for edition with vared
#
# Uses n-list

emulate -L zsh

setopt extendedglob
zmodload zsh/curses
zmodload zsh/parameter

local IFS="
"

unset NLIST_COLORING_PATTERN

[ -f ~/.config/znt/n-list.conf ] && builtin source ~/.config/znt/n-list.conf
[ -f ~/.config/znt/n-aliases.conf ] && builtin source ~/.config/znt/n-aliases.conf

local list
local selected

NLIST_REMEMBER_STATE=0

list=( "${(@k)aliases}" )
list=( "${(@M)list:#(#i)*$1*}" )

local NLIST_GREP_STRING="$1"

if [ "$#list" -eq 0 ]; then
    echo "No matching aliases"
    return 1
fi

list=( "${(@i)list}" )
n-list "$list[@]"

if [ "$REPLY" -gt 0 ]; then
    selected="$reply[REPLY]"
    echo "Editing \`$selected':"
    print -rs "vared aliases\\[$selected\\]"
    vared aliases\[$selected\]
fi

# vim: set filetype=zsh:
}
alias naliases=n-aliases

n-cd() {
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-cd` to .zshrc
#
# This function allows to choose a directory from pushd stack
#
# Uses n-list

emulate -L zsh

setopt extendedglob pushdignoredups

zmodload zsh/curses
local IFS="
"

# Unset before configuration is read
unset NLIST_COLORING_PATTERN

[ -f ~/.config/znt/n-list.conf ] && builtin source ~/.config/znt/n-list.conf
[ -f ~/.config/znt/n-cd.conf ] && builtin source ~/.config/znt/n-cd.conf

local list
local selected

NLIST_REMEMBER_STATE=0

list=( `dirs -p` )
list=( "${(@M)list:#(#i)*$1*}" )

local NLIST_GREP_STRING="$1"

[ "$#list" -eq 0 ] && echo "No matching directories"

if [ "$#hotlist" -ge 1 ]; then
    typeset -a NLIST_NONSELECTABLE_ELEMENTS NLIST_HOP_INDEXES
    local tmp_list_size="$#list"
    NLIST_NONSELECTABLE_ELEMENTS=( $(( tmp_list_size+1 )) $(( tmp_list_size+2 )) )
    list=( "$list[@]" "" $'\x1b[00;31m'"Hotlist"$'\x1b[00;00m': "$hotlist[@]" )
    (( tmp_list_size+=3 ))
    local middle_hop=$(( (tmp_list_size+$#list) / 2 ))
    [[ "$middle_hop" -eq $tmp_list_size || "$middle_hop" -eq $#list ]] && middle_hop=""
    [ "$tmp_list_size" -eq $#list ] && tmp_list_size=""
    NLIST_HOP_INDEXES=( 1 $tmp_list_size $middle_hop $#list )
else
    [ "$#list" -eq 0 ] && return 1
fi

n-list "${list[@]}"

if [ "$REPLY" -gt 0 ]; then
    selected="$reply[REPLY]"
    selected="${selected/#\~/$HOME}"

    (( NCD_DONT_PUSHD )) && setopt NO_AUTO_PUSHD
    cd "$selected"
    local code=$?
    (( NCD_DONT_PUSHD )) && setopt AUTO_PUSHD

    if [ "$code" -eq "0" ]; then
        # ZLE?
        if [ "${(t)CURSOR}" = "integer-local-special" ]; then
            zle -M "You have selected $selected"
        else
            echo "You have selected $selected"
        fi
    fi
else
    [ "${(t)CURSOR}" = "integer-local-special" ] && zle redisplay
fi

# vim: set filetype=zsh:
}
alias ncd=n-cd

n-env() {
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-env` to .zshrc
#
# This function allows to choose an environment variable
# for edition with vared
#
# Uses n-list

emulate -L zsh

setopt extendedglob
unsetopt equals
zmodload zsh/curses

local IFS="
"

[ -f ~/.config/znt/n-list.conf ] && builtin source ~/.config/znt/n-list.conf
[ -f ~/.config/znt/n-env.conf ] && builtin source ~/.config/znt/n-env.conf

local list
local selected

NLIST_REMEMBER_STATE=0

list=( `env` )
list=( "${(@M)list:#(#i)*$1*}" )

local NLIST_GREP_STRING="$1"

if [ "$#list" -eq 0 ]; then
    echo "No matching variables"
    return 1
fi

list=( "${(@i)list}" )
n-list "$list[@]"

if [ "$REPLY" -gt 0 ]; then
    selected="$reply[REPLY]"
    selected="${selected%%=*}"
    echo "Editing \`$selected':"
    print -rs "vared \"$selected\""
    vared "$selected"
fi

# vim: set filetype=zsh:
}
alias nenv=n-env

n-functions() {
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-functions` to .zshrc
#
# This function allows to choose a function for edition with vared
#
# Uses n-list

emulate -L zsh

setopt extendedglob
zmodload zsh/curses
zmodload zsh/parameter

local IFS="
"

unset NLIST_COLORING_PATTERN

[ -f ~/.config/znt/n-list.conf ] && builtin source ~/.config/znt/n-list.conf
[ -f ~/.config/znt/n-functions.conf ] && builtin source ~/.config/znt/n-functions.conf

local list
local selected

NLIST_REMEMBER_STATE=0

list=( "${(@k)functions}" )
list=( "${(@M)list:#(#i)*$1*}" )

local NLIST_GREP_STRING="$1"

if [ "$#list" -eq 0 ]; then
    echo "No matching functions"
    return 1
fi

list=( "${(@i)list}" )
n-list "$list[@]"

if [ "$REPLY" -gt 0 ]; then
    selected="$reply[REPLY]"
    if [ "$feditor" = "zed" ]; then
        echo "Editing \`$selected' (ESC ZZ or Ctrl-x-w to finish):"
        autoload zed
        print -rs "zed -f -- \"$selected\""
        zed -f -- "$selected"
    else
        echo "Editing \`$selected':"
        print -rs "vared functions\\[$selected\\]"
        vared functions\[$selected\]
    fi
fi

# vim: set filetype=zsh:
}
alias nfunctions=n-functions

n-help() {
autoload colors
colors

local h1="$fg_bold[magenta]"
local h2="$fg_bold[green]"
local h3="$fg_bold[blue]"
local h4="$fg_bold[yellow]"
local h5="$fg_bold[cyan]"
local rst="$reset_color"

LESS="-iRc" less <<<"
${h1}Key Bindings${rst}

${h2}H${rst}, ${h2}?${rst} (from n-history) - run n-help
${h2}Ctrl-A${rst} - rotate entered words (1+2+3 -> 3+1+2)
${h2}Ctrl-F${rst} - fix mode (approximate matching)
${h2}Ctrl-L${rst} - redraw of whole display
${h2}Ctrl-T${rst} - browse themes (next theme)
${h2}Ctrl-G${rst} - browse themes (previous theme)
${h2}Ctrl-U${rst} - half page up
${h2}Ctrl-D${rst} - half page down
${h2}Ctrl-P${rst} - previous element (also done with vim's k)
${h2}Ctrl-N${rst} - next element (also done with vim's j)
${h2}[${rst}, ${h2}]${rst} - jump directory bookmarks in n-cd and typical signals in n-kill
${h2}g, ${h2}G${rst} - beginning and end of the list
${h2}/${rst} - show incremental search
${h2}F3${rst} - show/hide incremental search
${h2}Esc${rst} - exit incremental search, clearing filter
${h2}Ctrl-W${rst} (in incremental search) - delete whole word
${h2}Ctrl-K${rst} (in incremental search) - delete whole line
${h2}Ctrl-O, ${h2}o${rst} - enter uniq mode (no duplicate lines)
${h2}Ctrl-E, ${h2}e${rst} - edit private history (when in private history view)
${h2}F1${rst} - (in n-history) - switch view
${h2}F2${rst}, ${h2}Ctrl-X${rst}, ${h2}Ctrl-/${rst} - search predefined keywords (defined in config files)

${h1}Configuration files${rst}

Location of the files is ${h3}~/.config/znt${rst}. Skeletons are copied there
when using ${h3}zsh-navigation-tools.plugin.zsh${rst} file (sourcing it or using
a plugin manager). There's a main config file ${h3}n-list.conf${rst} and files
for each tool.

To have a skeleton copied again into ${h3}~/.config/znt${rst}, delete it from
there and restart Zsh a few times (3-7 or so; there's a random check
that optimizes startup time).

${h1}Predefined search keywords${rst}

Following block of code in e.g. ${h3}~/.config/znt/n-history.conf${rst} defines
set of keywords that can be invoked (i.e. searched for) via ${h2}F2${rst}, ${h2}Ctrl-X${rst}
or ${h2}Ctrl-/${rst}:

    ${h4}# Search keywords, iterated with F2 or Ctrl-X or Ctrl-/${rst}
    ${h2}local${rst} -a keywords
    keywords=( ${h2}\"git\" \"vim\" \"mplayer\"${rst} )

${h1}Search query rotation${rst}

When searching, after pressing ${h2}Ctrl-A${rst}, words 1 2 3 will become 3 1 2, etc.
This can be used to edit some not-last word.

${h1}Fix mode${rst}

Approximate matching - pressing ${h2}f${rst} or ${h2}Ctrl-F${rst} will enter "FIX" mode, in which
1 or 2 errors are allowed in what's searched. This utilizes original Zsh
approximate matching features and is intended to be used after entering
search query, when a typo is discovered.

${h1}Color themes${rst}

Following block of code in ${h3}~/.config/znt/n-list.conf${rst} defines set of
themes that can be browsed with ${h2}Ctrl-T${rst} and ${h2}Ctrl-G${rst}:

    ${h4}# Combinations of colors to try out with Ctrl-T and Ctrl-G
    # The last number is the bold option, 0 or 1${rst}
    ${h2}local${rst} -a themes
    themes=( ${h2}\"white/black/1\" \"green/black/0\" \"green/black/1\"${rst}
             ${h2}\"white/blue/0\" \"white/blue/1\" \"magenta/black/0\"${rst}
             ${h2}\"magenta/black/1\"${rst} )

It's \"foreground/background/bold\". There's support for 256-color themes
for Zsh > 5.2, defined like e.g.: 

    themes=( ${h2}\"white/17/0\" \"10/17/1\" \"white/24/1\"${rst} )

i.e. with use of numbers, from 0 to 254.

${h1}Private history${rst}

N-history stores what's selected in its own history file. It can be
edited. Use ${h2}e${rst} or ${h2}Ctrl-E${rst} for that when in n-history. Your \$EDITOR will
start. This is a way to have handy set of bookmarks prepared in private
history's file.

Private history is instantly shared among sessions.

${h1}Zshrc integration${rst}

There are 5 standard configuration variables that can be set in zshrc:

${h4}znt_history_active_text${rst}
\"underline\" or \"reverse\" - how should be active element highlighted
${h4}znt_history_nlist_coloring_pattern${rst}
Pattern that can be used to colorize elements
${h4}znt_history_nlist_coloring_color${rst}
Color with which to colorize via the pattern
${h4}znt_history_nlist_coloring_match_multiple${rst}
Should multiple matches be colorized (${h2}\"0\"${rst} or ${h2}\"1\"${rst})
${h4}znt_history_keywords ${h2}(array)${rst}
Search keywords activated with Ctrl-X, F2, Ctrl-/, e.g. ( ${h2}\"git\"${rst} ${h2}\"vim\"${rst} )

Above variables will work for n-history tool. For other tools, change
\"_history_\" to e.g. \"_cd_\", for the n-cd tool. The same works for
all 8 tools.

Common configuration of the tools uses variables with \"_list_\" in them:

${h4}znt_list_bold${rst}
Should draw text in bold (${h2}\"0\"${rst} or ${h2}\"1\"${rst})
${h4}znt_list_colorpair${rst}
Main pair of colors to be used, e.g ${h2}\"green/black\"${rst}
${h4}znt_list_border${rst}
Should draw borders around windows (${h2}\"0\"${rst} or ${h2}\"1\"${rst})
${h4}znt_list_themes ${h2}(array)${rst}
List of themes to try out with Ctrl-T, e.g. ( ${h2}\"white/black/1\"${rst}
${h2}\"green/black/0\"${rst} )
${h4}znt_list_instant_select${rst}
Should pressing enter in search mode leave tool (${h2}\"0\"${rst} or ${h2}\"1\"${rst})

If you used ZNT before v2.1.12 then remove old configuration files
${h3}~/.config/znt/*.conf${rst} so that ZNT can update them to the latest versions
that support integration with Zshrc. If you used installer then run it
again (after the remove of configuration files), that is not needed when
using as plugin.
"
}
alias nhelp=n-help

n-history() {
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-history` to .zshrc
#
# This function allows to browse Z shell's history and use the
# entries
#
# Uses n-list

emulate -L zsh

setopt extendedglob
zmodload zsh/curses
zmodload zsh/parameter

local IFS="
"

# Variables to save list's state when switching views
# The views are: history and "most frequent history words"
local one_NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN
local one_NLIST_CURRENT_IDX
local one_NLIST_IS_SEARCH_MODE
local one_NLIST_SEARCH_BUFFER
local one_NLIST_TEXT_OFFSET
local one_NLIST_IS_UNIQ_MODE
local one_NLIST_IS_F_MODE
local one_NLIST_GREP_STRING
local one_NLIST_NONSELECTABLE_ELEMENTS
local one_NLIST_REMEMBER_STATE
local one_NLIST_ENABLED_EVENTS

local two_NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN
local two_NLIST_CURRENT_IDX
local two_NLIST_IS_SEARCH_MODE
local two_NLIST_SEARCH_BUFFER
local two_NLIST_TEXT_OFFSET
local two_NLIST_IS_UNIQ_MODE
local two_NLIST_IS_F_MODE
local two_NLIST_GREP_STRING
local two_NLIST_NONSELECTABLE_ELEMENTS
local two_NLIST_REMEMBER_STATE
local two_NLIST_ENABLED_EVENTS

local three_NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN
local three_NLIST_CURRENT_IDX
local three_NLIST_IS_SEARCH_MODE
local three_NLIST_SEARCH_BUFFER
local three_NLIST_TEXT_OFFSET
local three_NLIST_IS_UNIQ_MODE
local three_NLIST_IS_F_MODE
local three_NLIST_GREP_STRING
local three_NLIST_NONSELECTABLE_ELEMENTS
local three_NLIST_REMEMBER_STATE
local three_NLIST_ENABLED_EVENTS

# history view
integer active_view=0

# Lists are "0", "1", "2" - 1st, 2nd, 3rd
# Switching is done in cyclic manner
# i.e. 0 -> 1, 1 -> 2, 2 -> 0
_nhistory_switch_lists_states() {
    # First argument is current, newly selected list, i.e. $active_view
    # This implies that we are switching from previous view
   
    if [ "$1" = "0" ]; then
        # Switched to 1st list, save 3rd list's state
        three_NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN=$NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN
        three_NLIST_CURRENT_IDX=$NLIST_CURRENT_IDX
        three_NLIST_IS_SEARCH_MODE=$NLIST_IS_SEARCH_MODE
        three_NLIST_SEARCH_BUFFER=$NLIST_SEARCH_BUFFER
        three_NLIST_TEXT_OFFSET=$NLIST_TEXT_OFFSET
        three_NLIST_IS_UNIQ_MODE=$NLIST_IS_UNIQ_MODE
        three_NLIST_IS_F_MODE=$NLIST_IS_F_MODE
        three_NLIST_GREP_STRING=$NLIST_GREP_STRING
        three_NLIST_NONSELECTABLE_ELEMENTS=( ${NLIST_NONSELECTABLE_ELEMENTS[@]} )
        three_NLIST_REMEMBER_STATE=$NLIST_REMEMBER_STATE
        three_NLIST_ENABLED_EVENTS=( ${NLIST_ENABLED_EVENTS[@]} )

        # ..and restore 1st list's state
        NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN=$one_NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN
        NLIST_CURRENT_IDX=$one_NLIST_CURRENT_IDX
        NLIST_IS_SEARCH_MODE=$one_NLIST_IS_SEARCH_MODE
        NLIST_SEARCH_BUFFER=$one_NLIST_SEARCH_BUFFER
        NLIST_TEXT_OFFSET=$one_NLIST_TEXT_OFFSET
        NLIST_IS_UNIQ_MODE=$one_NLIST_IS_UNIQ_MODE
        NLIST_IS_F_MODE=$one_NLIST_IS_F_MODE
        NLIST_GREP_STRING=$one_NLIST_GREP_STRING
        NLIST_NONSELECTABLE_ELEMENTS=( ${one_NLIST_NONSELECTABLE_ELEMENTS[@]} )
        NLIST_REMEMBER_STATE=$one_NLIST_REMEMBER_STATE
        NLIST_ENABLED_EVENTS=( ${one_NLIST_ENABLED_EVENTS[@]} )
    elif [ "$1" = "1" ]; then
        # Switched to 2nd list, save 1st list's state
        one_NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN=$NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN
        one_NLIST_CURRENT_IDX=$NLIST_CURRENT_IDX
        one_NLIST_IS_SEARCH_MODE=$NLIST_IS_SEARCH_MODE
        one_NLIST_SEARCH_BUFFER=$NLIST_SEARCH_BUFFER
        one_NLIST_TEXT_OFFSET=$NLIST_TEXT_OFFSET
        one_NLIST_IS_UNIQ_MODE=$NLIST_IS_UNIQ_MODE
        one_NLIST_IS_F_MODE=$NLIST_IS_F_MODE
        one_NLIST_GREP_STRING=$NLIST_GREP_STRING
        one_NLIST_NONSELECTABLE_ELEMENTS=( ${NLIST_NONSELECTABLE_ELEMENTS[@]} )
        one_NLIST_REMEMBER_STATE=$NLIST_REMEMBER_STATE
        one_NLIST_ENABLED_EVENTS=( ${NLIST_ENABLED_EVENTS[@]} )

        # ..and restore 2nd list's state
        NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN=$two_NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN
        NLIST_CURRENT_IDX=$two_NLIST_CURRENT_IDX
        NLIST_IS_SEARCH_MODE=$two_NLIST_IS_SEARCH_MODE
        NLIST_SEARCH_BUFFER=$two_NLIST_SEARCH_BUFFER
        NLIST_TEXT_OFFSET=$two_NLIST_TEXT_OFFSET
        NLIST_IS_UNIQ_MODE=$two_NLIST_IS_UNIQ_MODE
        NLIST_IS_F_MODE=$two_NLIST_IS_F_MODE
        NLIST_GREP_STRING=$two_NLIST_GREP_STRING
        NLIST_NONSELECTABLE_ELEMENTS=( ${two_NLIST_NONSELECTABLE_ELEMENTS[@]} )
        NLIST_REMEMBER_STATE=$two_NLIST_REMEMBER_STATE
        NLIST_ENABLED_EVENTS=( ${two_NLIST_ENABLED_EVENTS[@]} )
    elif [ "$1" = "2" ]; then
        # Switched to 3rd list, save 2nd list's state
        two_NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN=$NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN
        two_NLIST_CURRENT_IDX=$NLIST_CURRENT_IDX
        two_NLIST_IS_SEARCH_MODE=$NLIST_IS_SEARCH_MODE
        two_NLIST_SEARCH_BUFFER=$NLIST_SEARCH_BUFFER
        two_NLIST_TEXT_OFFSET=$NLIST_TEXT_OFFSET
        two_NLIST_IS_UNIQ_MODE=$NLIST_IS_UNIQ_MODE
        two_NLIST_IS_F_MODE=$NLIST_IS_F_MODE
        two_NLIST_GREP_STRING=$NLIST_GREP_STRING
        two_NLIST_NONSELECTABLE_ELEMENTS=( ${NLIST_NONSELECTABLE_ELEMENTS[@]} )
        two_NLIST_REMEMBER_STATE=$NLIST_REMEMBER_STATE
        two_NLIST_ENABLED_EVENTS=( ${NLIST_ENABLED_EVENTS[@]} )

        # ..and restore 3rd list's state
        NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN=$three_NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN
        NLIST_CURRENT_IDX=$three_NLIST_CURRENT_IDX
        NLIST_IS_SEARCH_MODE=$three_NLIST_IS_SEARCH_MODE
        NLIST_SEARCH_BUFFER=$three_NLIST_SEARCH_BUFFER
        NLIST_TEXT_OFFSET=$three_NLIST_TEXT_OFFSET
        NLIST_IS_UNIQ_MODE=$three_NLIST_IS_UNIQ_MODE
        NLIST_IS_F_MODE=$three_NLIST_IS_F_MODE
        NLIST_GREP_STRING=$three_NLIST_GREP_STRING
        NLIST_NONSELECTABLE_ELEMENTS=( ${three_NLIST_NONSELECTABLE_ELEMENTS[@]} )
        NLIST_REMEMBER_STATE=$three_NLIST_REMEMBER_STATE
        NLIST_ENABLED_EVENTS=( ${three_NLIST_ENABLED_EVENTS[@]} )
    fi
}

local most_frequent_db="$HOME/.config/znt/mostfrequent.db"
_nhistory_generate_most_frequent() {
    local title=$'\x1b[00;31m'"Most frequent history words:"$'\x1b[00;00m\0'

    typeset -A uniq
    for k in "${historywords[@]}"; do
        uniq[$k]=$(( ${uniq[$k]:-0} + 1 ))
    done
    vk=()
    for k v in ${(kv)uniq}; do
        vk+="$v"$'\t'"$k"
    done

    print -rl -- "$title" "${(On)vk[@]}" > "$most_frequent_db"
}

# Load configuration
unset NLIST_COLORING_PATTERN
[ -f ~/.config/znt/n-list.conf ] && builtin source ~/.config/znt/n-list.conf
[ -f ~/.config/znt/n-history.conf ] && builtin source ~/.config/znt/n-history.conf

local list
local selected
local private_history_db="$HOME/.config/znt/privhist.db"

local NLIST_GREP_STRING="$1"
# 2 is: init once, then remember
local NLIST_REMEMBER_STATE=2
two_NLIST_REMEMBER_STATE=2
three_NLIST_REMEMBER_STATE=2

# Only Private history has EDIT
local -a NLIST_ENABLED_EVENTS
NLIST_ENABLED_EVENTS=( "F1" "HELP" )
two_NLIST_ENABLED_EVENTS=( "F1" "EDIT" "HELP" )
three_NLIST_ENABLED_EVENTS=( "F1" "HELP" )

# All view should attempt to replace new lines with \n
local NLIST_REPLACE_NEWLINES="1"
two_NLIST_REPLACE_NEWLINES="1"
three_NLIST_REPLACE_NEWLINES="1"

# Only second and third view has non-selectable first entry
local -a NLIST_NONSELECTABLE_ELEMENTS
NLIST_NONSELECTABLE_ELEMENTS=( )
two_NLIST_NONSELECTABLE_ELEMENTS=( 1 )
three_NLIST_NONSELECTABLE_ELEMENTS=( 1 )

while (( 1 )); do

    #
    # View 1 - history
    #
    if [ "$active_view" = "0" ]; then
        list=( "$history[@]" )
        list=( "${(@M)list:#(#i)*$NLIST_GREP_STRING*}" )

        if [ "$#list" -eq 0 ]; then
            echo "No matching history entries"
            return 1
        fi

        n-list "${list[@]}"

        # Selection or quit?
        if [[ "$REPLY" = -(#c0,1)[0-9]## && ("$REPLY" -lt 0 || "$REPLY" -gt 0) ]]; then
            break
        fi

        # View change?
        if [ "$REPLY" = "F1" ]; then
            # Target view: 2
            active_view=1
            _nhistory_switch_lists_states "1"
        elif [ "$REPLY" = "HELP" ]; then
            n-help
        fi

    #
    # View 3 - most frequent words in history
    #
    elif [ "$active_view" = "2" ]; then
        local -a dbfile
        dbfile=( $most_frequent_db(Nm+1) )

        # Compute most frequent history words
        if [[ "${#NHISTORY_WORDS}" -eq "0" || "${#dbfile}" -ne "0" ]]; then
            # Read the list if it's there
            local -a list
            list=()
            [ -s "$most_frequent_db" ] && list=( ${(f)"$(<$most_frequent_db)"} )

            # Will wait for the data?
            local message=0
            if [[ "${#list}" -eq 0 ]]; then
                message=1
                _nlist_alternate_screen 1
                zcurses init
                zcurses delwin info 2>/dev/null
                zcurses addwin info "$term_height" "$term_width" 0 0
                zcurses bg info white/black
                zcurses string info "Computing most frequent history words..."$'\n'
                zcurses string info "(This is done once per day, from now on transparently)"$'\n'
                zcurses refresh info
                sleep 3
            fi

            # Start periodic list regeneration?
            if [[ "${#list}" -eq 0 || "${#dbfile}" -ne "0" ]]; then
                # Mark the file with current time, to prevent double
                # regeneration (on quick double change of view)
                print >> "$most_frequent_db"
                (_nhistory_generate_most_frequent &) &> /dev/null
            fi

            # Ensure we got the list, wait for it if needed
            while [[ "${#list}" -eq 0 ]]; do
                zcurses string info "."
                zcurses refresh info
                LANG=C sleep 0.5
                [ -s "$most_frequent_db" ] && list=( ${(f)"$(<$most_frequent_db)"} )
            done

            NHISTORY_WORDS=( "${list[@]}" )

            if [ "$message" -eq "1" ]; then
                zcurses delwin info 2>/dev/null
                zcurses refresh
                zcurses end
                _nlist_alternate_screen 0
            fi
        else
            # Reuse most frequent history words
            local -a list
            list=( "${NHISTORY_WORDS[@]}" )
        fi

        n-list "${list[@]}"

        if [ "$REPLY" = "F1" ]; then
            # Target view: 1
            active_view=0
            _nhistory_switch_lists_states "0"
        elif [[ "$REPLY" = -(#c0,1)[0-9]## && "$REPLY" -lt 0 ]]; then
            break
        elif [[ "$REPLY" = -(#c0,1)[0-9]## && "$REPLY" -gt 0 ]]; then
            local word="${reply[REPLY]#(#s) #[0-9]##$'\t'}"
            one_NLIST_SEARCH_BUFFER="$word"
            one_NLIST_SEARCH_BUFFER="${one_NLIST_SEARCH_BUFFER## ##}"

            # Target view: 1
            active_view=0
            _nhistory_switch_lists_states "0"
        elif [ "$REPLY" = "HELP" ]; then
            n-help
        fi

    #
    # View 2 - private history
    #
    elif [ "$active_view" = "1" ]; then
        if [ -s "$private_history_db" ]; then
            local title=$'\x1b[00;32m'"Private history:"$'\x1b[00;00m\0'
            () { fc -Rap "$private_history_db" 20000 0; list=( "$title" ${history[@]} ) }
        else
            list=( "Private history - history entries selected via this tool will be put here" )
        fi

        n-list "${list[@]}"

        # Selection or quit?
        if [[ "$REPLY" = -(#c0,1)[0-9]## && ("$REPLY" -lt 0 || "$REPLY" -gt 0) ]]; then
            break
        fi

        # View change?
        if [ "$REPLY" = "F1" ]; then
            # Target view: 3
            active_view=2
            _nhistory_switch_lists_states "2"
        # Edit of the history?
        elif [ "$REPLY" = "EDIT" ]; then
            "${EDITOR:-vim}" "$private_history_db"
        elif [ "$REPLY" = "HELP" ]; then
            n-help
        fi
    fi
done

if [ "$REPLY" -gt 0 ]; then
    selected="$reply[REPLY]"

    # Append to private history
    if [[ "$active_view" = "0" ]]; then
        local newline=$'\n'
        local selected_ph="${selected//$newline/\\$newline}"
        print -r -- "$selected_ph" >> "$private_history_db"
    fi

    # TMUX?
    if [[ "$ZNT_TMUX_MODE" = "1" ]]; then
        tmux send -t "$ZNT_TMUX_ORIGIN_SESSION:$ZNT_TMUX_ORIGIN_WINDOW.$ZNT_TMUX_ORIGIN_PANE" "$selected"
        tmux kill-window
        return 0
    # ZLE?
    elif [ "${(t)CURSOR}" = "integer-local-special" ]; then
        zle .redisplay
        zle .kill-buffer
        LBUFFER+="$selected"
    else
        print -zr -- "$selected"
    fi
else
    # TMUX?
    if [[ "$ZNT_TMUX_MODE" = "1" ]]; then
        tmux kill-window
    # ZLE?
    elif [[ "${(t)CURSOR}" = "integer-local-special" ]]; then
        zle redisplay
    fi
fi

return 0

# vim: set filetype=zsh:
}
alias nhistory=n-history

n-kill() {
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-kill` to .zshrc
#
# This function allows to choose a process and a signal to send to it
#
# Uses n-list

emulate -L zsh

setopt extendedglob
zmodload zsh/curses

local IFS="
"

[ -f ~/.config/znt/n-list.conf ] && builtin source ~/.config/znt/n-list.conf
[ -f ~/.config/znt/n-kill.conf ] && builtin source ~/.config/znt/n-kill.conf

typeset -A signals
signals=(
     1       "1  - HUP"
     2       "2  - INT"
     3       "3  - QUIT"
     6       "6  - ABRT"
     9       "9  - KILL"
     14      "14 - ALRM"
     15      "15 - TERM"
     17      "17 - STOP"
     19      "19 - CONT"
)

local list
local selected
local signal
local -a signal_names
local title

NLIST_REMEMBER_STATE=0

typeset -a NLIST_NONSELECTABLE_ELEMENTS
NLIST_NONSELECTABLE_ELEMENTS=( 1 )

type ps 2>/dev/null 1>&2 || { echo >&2 "Error: \`ps' not found"; return 1 }

case "$(uname)" in
    CYGWIN*) list=( `command ps -Wa` )  ;;
    *) list=( `command ps -o pid,uid,command -A` ) ;;
esac

# Ask of PID
title=$'\x1b[00;31m'"${list[1]}"$'\x1b[00;00m\0'
shift list
list=( "$title" "${(@M)list:#(#i)*$1*}" )

local NLIST_GREP_STRING="$1"

if [ "$#list" -eq 1 ]; then
    echo "No matching processes"
    return 1
fi

n-list "$list[@]"

# Got answer? (could be Ctrl-C or 'q')
if [ "$REPLY" -gt 0 ]; then
    selected="$reply[REPLY]"
    selected="${selected## #}"
    pid="${selected%% *}"

    # Now ask of signal
    signal_names=( ${(vin)signals} )
    typeset -a NLIST_HOP_INDEXES
    NLIST_HOP_INDEXES=( 3 6 8 )
    unset NLIST_COLORING_PATTERN
    n-list $'\x1b[00;31mSelect signal:\x1b[00;00m' "$signal_names[@]"

    if [ "$REPLY" -gt 0 ]; then
        selected="$reply[REPLY]"
        signal="${(k)signals[(r)$selected]}"

        # ZLE?
        if [ "${(t)CURSOR}" = "integer-local-special" ]; then
            zle redisplay
            zle kill-whole-line
            zle -U "kill -$signal $pid"
        else
            print -zr "kill -$signal $pid"
        fi
    else
        [ "${(t)CURSOR}" = "integer-local-special" ] && zle redisplay
    fi
else
    [ "${(t)CURSOR}" = "integer-local-special" ] && zle redisplay
fi

# vim: set filetype=zsh:
}
alias nkill=n-kill

n-list() {
# $1, $2, ... - elements of the list
# $NLIST_NONSELECTABLE_ELEMENTS - array of indexes (1-based) that cannot be selected
# $REPLY is the output variable - contains index (1-based) or -1 when no selection
# $reply (array) is the second part of the output - use the index (REPLY) to get selected element
#
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-list` to .zshrc
#
# This function outputs a list of elements that can be
# navigated with keyboard. Uses curses library

emulate -LR zsh

setopt typesetsilent extendedglob noshortloops

_nlist_has_terminfo=0

zmodload zsh/curses
zmodload zsh/terminfo 2>/dev/null && _nlist_has_terminfo=1

trap "REPLY=-2; reply=(); return" TERM INT QUIT
trap "_nlist_exit" EXIT

# Drawing and input
autoload n-list-draw n-list-input

# Cleanup before any exit
_nlist_exit() {
    setopt localoptions
    setopt extendedglob

    [[ "$REPLY" = -(#c0,1)[0-9]## || "$REPLY" = F<-> || "$REPLY" = "EDIT" || "$REPLY" = "HELP" ]] || REPLY="-1"
    zcurses 2>/dev/null delwin inner
    zcurses 2>/dev/null delwin main
    zcurses 2>/dev/null refresh
    zcurses end
    _nlist_alternate_screen 0
    _nlist_cursor_visibility 1
    unset _nlist_has_terminfo
}

# Outputs a message in the bottom of the screen
_nlist_status_msg() {
    # -1 for border, -1 for 0-based indexing
    zcurses move main $(( term_height - 1 - 1 )) 2
    zcurses clear main eol
    zcurses string main "$1"
    #status_msg_strlen is localized in caller
    status_msg_strlen=$#1
}

# Prefer tput, then module terminfo
_nlist_cursor_visibility() {
    if type tput 2>/dev/null 1>&2; then
        [ "$1" = "1" ] && { tput cvvis; tput cnorm }
        [ "$1" = "0" ] && tput civis
    elif [ "$_nlist_has_terminfo" = "1" ]; then
        [ "$1" = "1" ] && { [ -n $terminfo[cvvis] ] && echo -n $terminfo[cvvis];
                           [ -n $terminfo[cnorm] ] && echo -n $terminfo[cnorm] }
        [ "$1" = "0" ] && [ -n $terminfo[civis] ] && echo -n $terminfo[civis]
    fi 
}

# Reason for this function is that on some systems
# smcup and rmcup are not knowing why left empty
_nlist_alternate_screen() {
    [ "$_nlist_has_terminfo" -ne "1" ] && return
    [[ "$1" = "1" && -n "$terminfo[smcup]" ]] && return
    [[ "$1" = "0" && -n "$terminfo[rmcup]" ]] && return

    case "$TERM" in
        *rxvt*)
            [ "$1" = "1" ] && echo -n $'\x1b7\x1b[?47h'
            [ "$1" = "0" ] && echo -n $'\x1b[2J\x1b[?47l\x1b8'
            ;;
        *)
            [ "$1" = "1" ] && echo -n $'\x1b[?1049h'
            [ "$1" = "0" ] && echo -n $'\x1b[?1049l'
            # just to remember two other that work: $'\x1b7\x1b[r\x1b[?47h', $'\x1b[?47l\x1b8'
            ;;
    esac
}

_nlist_compute_user_vars_difference() {
        if [[ "${(t)NLIST_NONSELECTABLE_ELEMENTS}" != "array" &&
                "${(t)NLIST_NONSELECTABLE_ELEMENTS}" != "array-local" ]]
        then
            last_element_difference=0
            current_difference=0
        else
            last_element_difference=$#NLIST_NONSELECTABLE_ELEMENTS
            current_difference=0
            local idx
            for idx in "${(n)NLIST_NONSELECTABLE_ELEMENTS[@]}"; do
                [ "$idx" -le "$NLIST_CURRENT_IDX" ] && current_difference+=1 || break
            done
        fi
}

# List was processed, check if variables aren't off range
_nlist_verify_vars() {
    [ "$NLIST_CURRENT_IDX" -gt "$last_element" ] && NLIST_CURRENT_IDX="$last_element"
    [[ "$NLIST_CURRENT_IDX" -eq 0 && "$last_element" -ne 0 ]] && NLIST_CURRENT_IDX=1
    (( NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN=0+((NLIST_CURRENT_IDX-1)/page_height)*page_height+1 ))
}

# Compute the variables which are shown to the user
_nlist_setup_user_vars() {
    if [ "$1" = "1" ]; then
        # Basic values when there are no non-selectables
        NLIST_USER_CURRENT_IDX="$NLIST_CURRENT_IDX"
        NLIST_USER_LAST_ELEMENT="$last_element"
    else
        _nlist_compute_user_vars_difference
        NLIST_USER_CURRENT_IDX=$(( NLIST_CURRENT_IDX - current_difference ))
        NLIST_USER_LAST_ELEMENT=$(( last_element - last_element_difference ))
    fi
}

_nlist_colorify_disp_list() {
    local col=$'\x1b[00;34m' reset=$'\x1b[0m'
    [ -n "$NLIST_COLORING_COLOR" ] && col="$NLIST_COLORING_COLOR"
    [ -n "$NLIST_COLORING_END_COLOR" ] && reset="$NLIST_COLORING_END_COLOR"

    if [ "$NLIST_COLORING_MATCH_MULTIPLE" -eq 1 ]; then
        disp_list=( "${(@)disp_list//(#mi)$~NLIST_COLORING_PATTERN/$col${MATCH}$reset}" )
    else
        disp_list=( "${(@)disp_list/(#mi)$~NLIST_COLORING_PATTERN/$col${MATCH}$reset}" )
    fi
}

#
# Main code
#

# Check if there is proper input
if [ "$#" -lt 1 ]; then
    echo "Usage: n-list element_1 ..."
    return 1
fi

REPLY="-1"
typeset -ga reply
reply=()

integer term_height="$LINES"
integer term_width="$COLUMNS"
if [[ "$term_height" -lt 1 || "$term_width" -lt 1 ]]; then
    local stty_out=$( stty size )
    term_height="${stty_out% *}"
    term_width="${stty_out#* }"
fi
integer inner_height=term_height-3
integer inner_width=term_width-3
integer page_height=inner_height
integer page_width=inner_width

typeset -a list disp_list
integer last_element=$#
local action
local final_key
integer selection
integer last_element_difference=0
integer current_difference=0
local prev_search_buffer=""
integer prev_uniq_mode=0
integer prev_start_idx=-1
local MBEGIN MEND MATCH mbegin mend match

# Iteration over predefined keywords
integer curkeyword nkeywords
local keywordisfresh="0"
if [[ "${(t)keywords}" != *array* ]]; then
    local -a keywords
    keywords=()
fi
curkeyword=0
nkeywords=${#keywords}

# Iteration over themes
integer curtheme nthemes
local themeisfresh="0"
if [[ "${(t)themes}" != *array* ]]; then
    local -a themes
    themes=()
fi
curtheme=0
nthemes=${#themes}

# Ability to remember the list between calls
if [[ -z "$NLIST_REMEMBER_STATE" || "$NLIST_REMEMBER_STATE" -eq 0 || "$NLIST_REMEMBER_STATE" -eq 2 ]]; then
    NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN=1
    NLIST_CURRENT_IDX=1
    NLIST_IS_SEARCH_MODE=0
    NLIST_SEARCH_BUFFER=""
    NLIST_TEXT_OFFSET=0
    NLIST_IS_UNIQ_MODE=0
    NLIST_IS_F_MODE=0

    # Zero - because it isn't known, unless we
    # confirm that first element is selectable
    NLIST_USER_CURRENT_IDX=0
    [[ ${NLIST_NONSELECTABLE_ELEMENTS[(r)1]} != 1 ]] && NLIST_USER_CURRENT_IDX=1
    NLIST_USER_LAST_ELEMENT=$(( last_element - $#NLIST_NONSELECTABLE_ELEMENTS ))

    # 2 is init once, then remember
    [ "$NLIST_REMEMBER_STATE" -eq 2 ] && NLIST_REMEMBER_STATE=1
fi

if [ "$NLIST_START_IN_SEARCH_MODE" -eq 1 ]; then
    NLIST_START_IN_SEARCH_MODE=0
    NLIST_IS_SEARCH_MODE=1
fi

if [ -n "$NLIST_SET_SEARCH_TO" ]; then
    NLIST_SEARCH_BUFFER="$NLIST_SET_SEARCH_TO"
    NLIST_SET_SEARCH_TO=""
fi

if [ "$NLIST_START_IN_UNIQ_MODE" -eq 1 ]; then
    NLIST_START_IN_UNIQ_MODE=0
    NLIST_IS_UNIQ_MODE=1
fi

_nlist_alternate_screen 1
zcurses init
zcurses delwin main 2>/dev/null
zcurses delwin inner 2>/dev/null
zcurses addwin main "$term_height" "$term_width" 0 0
zcurses addwin inner "$inner_height" "$inner_width" 1 2
# From n-list.conf
[ "$colorpair" = "" ] && colorpair="white/black"
[ "$border" = "0" ] || border="1"
local background="${colorpair#*/}"
local backuptheme="$colorpair/$bold"
zcurses bg main "$colorpair"
zcurses bg inner "$colorpair"
if [ "$NLIST_IS_SEARCH_MODE" -ne 1 ]; then
    _nlist_cursor_visibility 0
fi

zcurses refresh

#
# Listening for input
#

local key keypad

# Clear input buffer
zcurses timeout main 0
zcurses input main key keypad
zcurses timeout main -1
key=""
keypad=""

# This loop makes script faster on some Zsh's (e.g. 5.0.8)
repeat 1; do
    list=( "$@" )
done

last_element="$#list"

zcurses clear main redraw
zcurses clear inner redraw
while (( 1 )); do
    # Do searching (filtering with string)
    if [ -n "$NLIST_SEARCH_BUFFER" ]; then
        # Compute new list?
        if [[ "$NLIST_SEARCH_BUFFER" != "$prev_search_buffer" || "$NLIST_IS_UNIQ_MODE" -ne "$prev_uniq_mode"
                || "$NLIST_IS_F_MODE" -ne "$prev_f_mode" ]]
        then
            prev_search_buffer="$NLIST_SEARCH_BUFFER"
            prev_uniq_mode="$NLIST_IS_UNIQ_MODE"
            prev_f_mode="$NLIST_IS_F_MODE"
            # regenerating list -> regenerating disp_list
            prev_start_idx=-1

            # Take all elements, including duplicates and non-selectables
            typeset +U list
            repeat 1; do
                list=( "$@" )
            done

            # Remove non-selectable elements
            [ "$#NLIST_NONSELECTABLE_ELEMENTS" -gt 0 ] && for i in "${(nO)NLIST_NONSELECTABLE_ELEMENTS[@]}"; do
                if [[ "$i" = <-> ]]; then
                    list[$i]=()
                fi
            done

            # Remove duplicates
            [ "$NLIST_IS_UNIQ_MODE" -eq 1 ] && typeset -U list

            last_element="$#list"

            # Next do the filtering
            local search_buffer="${NLIST_SEARCH_BUFFER%% ##}"
            search_buffer="${search_buffer## ##}"
            search_buffer="${search_buffer//(#m)[][*?|#~^()><\\]/\\$MATCH}"
            local search_pattern=""
            local colsearch_pattern=""
            if [ -n "$search_buffer" ]; then
                # The repeat will make the matching work on a fresh heap
                repeat 1; do
                    if [ "$NLIST_IS_F_MODE" -eq "1" ]; then
                        search_pattern="${search_buffer// ##/*~^(#a1)*}"
                        colsearch_pattern="${search_buffer// ##/|(#a1)}"
                        list=( "${(@M)list:#(#ia1)*$~search_pattern*}" )
                    elif [ "$NLIST_IS_F_MODE" -eq "2" ]; then
                        search_pattern="${search_buffer// ##/*~^(#a2)*}"
                        colsearch_pattern="${search_buffer// ##/|(#a2)}"
                        list=( "${(@M)list:#(#ia2)*$~search_pattern*}" )
                    else
                        # Pattern will be *foo*~^*bar* (inventor: Mikael Magnusson)
                        search_pattern="${search_buffer// ##/*~^*}"
                        # Pattern will be (foo|bar)
                        colsearch_pattern="${search_buffer// ##/|}"
                        list=( "${(@M)list:#(#i)*$~search_pattern*}" )
                    fi
                done

                last_element="$#list"
            fi

            # Called after processing list
            _nlist_verify_vars
        fi

        _nlist_setup_user_vars 1

        integer end_idx=$(( NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN + page_height - 1 ))
        [ "$end_idx" -gt "$last_element" ] && end_idx=last_element

        if [ "$prev_start_idx" -ne "$NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN" ]; then
            prev_start_idx="$NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN"
            disp_list=( "${(@)list[NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN, end_idx]}" )

            if [ -n "$colsearch_pattern" ]; then
                local red=$'\x1b[00;31m' reset=$'\x1b[00;00m'
                # The repeat will make the matching work on a fresh heap
                repeat 1; do
                    if [ "$NLIST_IS_F_MODE" -eq "1" ]; then
                        disp_list=( "${(@)disp_list//(#mia1)($~colsearch_pattern)/$red${MATCH}$reset}" )
                    elif [ "$NLIST_IS_F_MODE" -eq "2" ]; then
                        disp_list=( "${(@)disp_list//(#mia2)($~colsearch_pattern)/$red${MATCH}$reset}" )
                    else
                        disp_list=( "${(@)disp_list//(#mi)($~colsearch_pattern)/$red${MATCH}$reset}" )
                    fi
                done
            fi

            # We have display list, lets replace newlines with "\n" when needed (1/2)
            [ "$NLIST_REPLACE_NEWLINES" -eq 1 ] && disp_list=( "${(@)disp_list//$'\n'/\\n}" )
        fi

        # Output colored list
        zcurses clear inner
        n-list-draw "$(( (NLIST_CURRENT_IDX-1) % page_height + 1 ))" \
            "$page_height" "$page_width" 0 0 "$NLIST_TEXT_OFFSET" inner \
            "$disp_list[@]"
    else
        # There is no search, but there was in previous loop
        # OR
        # Uniq mode was entered or left out
        # -> compute new list
        if [[ -n "$prev_search_buffer" || "$NLIST_IS_UNIQ_MODE" -ne "$prev_uniq_mode" ]]; then
            prev_search_buffer=""
            prev_uniq_mode="$NLIST_IS_UNIQ_MODE"
            # regenerating list -> regenerating disp_list
            prev_start_idx=-1

            # Take all elements, including duplicates and non-selectables
            typeset +U list
            repeat 1; do
                list=( "$@" )
            done

            # Remove non-selectable elements only when in uniq mode
            [ "$NLIST_IS_UNIQ_MODE" -eq 1 ] && [ "$#NLIST_NONSELECTABLE_ELEMENTS" -gt 0 ] &&
            for i in "${(nO)NLIST_NONSELECTABLE_ELEMENTS[@]}"; do
                if [[ "$i" = <-> ]]; then
                    list[$i]=()
                fi
            done

            # Remove duplicates when in uniq mode
            [ "$NLIST_IS_UNIQ_MODE" -eq 1 ] && typeset -U list

            last_element="$#list"
            # Called after processing list
            _nlist_verify_vars
        fi

        # "1" - shouldn't bother with non-selectables
        _nlist_setup_user_vars "$NLIST_IS_UNIQ_MODE"

        integer end_idx=$(( NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN + page_height - 1 ))
        [ "$end_idx" -gt "$last_element" ] && end_idx=last_element

        if [ "$prev_start_idx" -ne "$NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN" ]; then
            prev_start_idx="$NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN"
            disp_list=( "${(@)list[NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN, end_idx]}" )

            [ -n "$NLIST_COLORING_PATTERN" ] && _nlist_colorify_disp_list

            # We have display list, lets replace newlines with "\n" when needed (2/2)
            [ "$NLIST_REPLACE_NEWLINES" -eq 1 ] && disp_list=( "${(@)disp_list//$'\n'/\\n}" )
        fi

        # Output the list
        zcurses clear inner
        n-list-draw "$(( (NLIST_CURRENT_IDX-1) % page_height + 1 ))" \
            "$page_height" "$page_width" 0 0 "$NLIST_TEXT_OFFSET" inner \
            "$disp_list[@]"
    fi

    local status_msg_strlen
    local keywordmsg=""
    if [ "$keywordisfresh" = "1" ]; then
        keywordmsg="($curkeyword/$nkeywords) "
        keywordisfresh="0"
    fi

    local thememsg=""
    if [ "$themeisfresh" = "1" ]; then
        local theme="$backuptheme"
        [ "$curtheme" -gt 0 ] && theme="${themes[curtheme]}"
        thememsg="($curtheme/$nthemes $theme) "
        themeisfresh="0"
    fi

    local _txt2="" _txt3=""
    [ "$NLIST_IS_UNIQ_MODE" -eq 1 ] && _txt2="[-UNIQ-] "
    [ "$NLIST_IS_F_MODE" -eq 1 ] && _txt3="[-FIX-] "
    [ "$NLIST_IS_F_MODE" -eq 2 ] && _txt3="[-FIX2-] "

    if [ "$NLIST_IS_SEARCH_MODE" = "1" ]; then
        _nlist_status_msg "${_txt2}${_txt3}${keywordmsg}${thememsg}Filtering with: ${NLIST_SEARCH_BUFFER// /+}"
    elif [[ ${NLIST_NONSELECTABLE_ELEMENTS[(r)$NLIST_CURRENT_IDX]} != $NLIST_CURRENT_IDX ||
            -n "$NLIST_SEARCH_BUFFER" || "$NLIST_IS_UNIQ_MODE" -eq 1 ]]; then
        local _txt=""
        [ -n "$NLIST_GREP_STRING" ] && _txt=" [$NLIST_GREP_STRING]"
        _nlist_status_msg "${_txt2}${_txt3}${keywordmsg}${thememsg}Current #$NLIST_USER_CURRENT_IDX (of #$NLIST_USER_LAST_ELEMENT entries)$_txt"
    else
        _nlist_status_msg "${keywordmsg}${thememsg}"
    fi

    [ "$border" = "1" ] && zcurses border main

    local top_msg=" ${(C)ZSH_NAME} $ZSH_VERSION, shell level $SHLVL "
    if [[ "${NLIST_ENABLED_EVENTS[(r)F1]}" = "F1" ]]; then
        top_msg=" F1-change view,$top_msg"
    fi
    zcurses move main 0 $(( term_width / 2 - $#top_msg / 2 ))
    zcurses string main $top_msg

    zcurses refresh main inner
    zcurses move main $(( term_height - 1 - 1 )) $(( status_msg_strlen + 2 ))

    # Wait for input
    zcurses input main key keypad

    # Get the special (i.e. "keypad") key or regular key
    if [ -n "$key" ]; then
        final_key="$key"
    elif [ -n "$keypad" ]; then
        final_key="$keypad"
    else
        _nlist_status_msg "Inproper input detected"
        zcurses refresh main inner
    fi

    n-list-input "$NLIST_CURRENT_IDX" "$NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN" \
                    "$page_height" "$page_width" "$last_element" "$NLIST_TEXT_OFFSET" \
                    "$final_key" "$NLIST_IS_SEARCH_MODE" "$NLIST_SEARCH_BUFFER" \
                    "$NLIST_IS_UNIQ_MODE" "$NLIST_IS_F_MODE"

    selection="$reply[1]"
    action="$reply[2]"
    NLIST_CURRENT_IDX="$reply[3]"
    NLIST_FROM_WHAT_IDX_LIST_IS_SHOWN="$reply[4]"
    NLIST_TEXT_OFFSET="$reply[5]"
    NLIST_IS_SEARCH_MODE="$reply[6]"
    NLIST_SEARCH_BUFFER="$reply[7]"
    NLIST_IS_UNIQ_MODE="$reply[8]"
    NLIST_IS_F_MODE="$reply[9]"

    if [ -z "$action" ]; then
        continue
    elif [ "$action" = "SELECT" ]; then
        REPLY="$selection"
        reply=( "$list[@]" )
        break
    elif [ "$action" = "QUIT" ]; then
        REPLY=-1
        reply=( "$list[@]" )
        break
    elif [ "$action" = "REDRAW" ]; then
        zcurses clear main redraw
        zcurses clear inner redraw
    elif [[ "$action" = F<-> ]]; then
        REPLY="$action"
        reply=( "$list[@]" )
        break
    elif [[ "$action" = "EDIT" ]]; then
        REPLY="EDIT"
        reply=( "$list[@]" )
        break
    elif [[ "$action" = "HELP" ]]; then
        REPLY="HELP"
        reply=( "$list[@]" )
        break
    fi
done

# vim: set filetype=zsh:
}
alias nlist=n-list

n-list-draw() {
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-list-draw` to .zshrc
#
# This is an internal function not for direct use

emulate -L zsh

zmodload zsh/curses

setopt typesetsilent extendedglob

_nlist_print_with_ansi() {
    local win="$1" text="$2" out col chunk Xout
    integer text_offset="$3" max_text_len="$4" text_len=0 no_match=0 nochunk_text_len to_skip_from_chunk to_chop_off_from_chunk before_len

    # 1 - non-escaped text, 2 - first number in the escaped text, with ;
    # 3 - second number, 4 - text after whole escape text

    typeset -a c
    c=( black red green yellow blue magenta cyan white )

    while [[ -n "$text" && "$no_match" -eq 0 ]]; do
        if [[ "$text" = (#b)([^$'\x1b']#)$'\x1b'\[([0-9](#c0,2))(#B)(\;|)(#b)([0-9](#c0,2))m(*) ]]; then
            # Text for further processing
            text="$match[4]"
            # Text chunk to output now
            out="$match[1]"
            # Save color
            col="$match[2]"
            (( match[3] >= 30 && match[3] <= 37 )) && col="$match[3]"
        else
            out="$text"
            no_match=1
        fi

        if [ -n "$out" ]; then
################ Expand tabs ################
            chunk="$out"
            before_len="$text_len"
            Xout=""

            while [ -n "$chunk" ]; do
                [[ "$chunk" = (#b)([^$'\t']#)$'\t'(*) ]] && {
                    (( all_text_len=((before_len+${#match[1]})/8+1)*8 ))

                    Xout+="${(r:all_text_len-before_len:: :)match[1]}"

                    before_len+=all_text_len-before_len
                    chunk="$match[2]"
                } || {
                    Xout+="$chunk"
                    break
                }
            done
#############################################

            # Input text length without the current chunk
            nochunk_text_len=text_len
            # Input text length up to current chunk
            text_len+="$#Xout"

            # Should start displaying with this chunk?
            # I.e. stop skipping left part of the input text?
            if (( text_len > text_offset )); then
                to_skip_from_chunk=text_offset-nochunk_text_len

                # LEFT - is chunk off the left skip boundary? +1 for 1-based index in string
                (( to_skip_from_chunk > 0 )) && Xout="${Xout[to_skip_from_chunk+1,-1]}"

                # RIGHT - is text off the screen?
                if (( text_len-text_offset > max_text_len )); then
                    to_chop_off_from_chunk=0+(text_len-text_offset)-max_text_len
                    Xout="${Xout[1,-to_chop_off_from_chunk-1]}"
                fi
                
                [ -n "$Xout" ] && zcurses string "$win" "$Xout"
            fi
        fi

        if (( no_match == 0 )); then
            if (( col >= 30 && col <= 37 )); then
                zcurses attr "$win" $c[col-29]/"$background"
            elif [[ "$col" -eq 0 ]]; then
                zcurses attr "$win" "$colorpair"
            fi
        fi
    done
}

integer highlight="$1"
integer page_height="$2"
integer page_width="$3"
local y_offset="$4"
local x_offset="$5"
local text_offset="$6"
local win="$7"
shift 7
integer max_text_len=page_width-x_offset

[[ "$bold" = "0" || "$bold" = "-bold" ]] && bold="-bold" || bold="+bold"
[[ "$active_text" = "underline" || "$active_text" = "reverse" ]] || local active_text="reverse"
# Linux has ncv 18, screen* has ncv 3 - underline won't work properly
(( ${terminfo[ncv]:-0} & 2 )) && active_text="reverse"
# FreeBSD uses TERM=xterm for newcons but doesn't actually support underline
[[ "$TERM" = "xterm" && -z "$DISPLAY" ]] && active_text="reverse"

integer max_idx=page_height
integer end_idx=max_idx
[ "$end_idx" -gt "$#" ] && end_idx="$#"
integer y=y_offset

zcurses attr "$win" "$bold" "$colorpair"

integer i text_len
local text
for (( i=1; i<=end_idx; i++ )); do
    zcurses move "$win" $y "$x_offset"

    [ "$i" = "$highlight" ] && zcurses attr "$win" +"$active_text"
    _nlist_print_with_ansi "$win" "$@[i]" "$text_offset" "$max_text_len"
    zcurses clear "$win" eol
    [ "$i" = "$highlight" ] && zcurses attr "$win" -"$active_text"

    y+=1
done

if [ "$end_idx" -lt "$max_idx" ]; then
    zcurses move "$win" $y "$x_offset"
    zcurses clear "$win" eol
fi

zcurses attr "$win" white/black
# vim: set filetype=zsh:
}
alias nlist-draw=n-list-draw

n-list-input() {
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-list-input` to .zshrc
#
# This is an internal function not for direct use

emulate -L zsh

zmodload zsh/curses

setopt typesetsilent

# Compute first to show index
_nlist_compute_first_to_show_idx() {
    from_what_idx_list_is_shown=0+((current_idx-1)/page_height)*page_height+1
}

_nlist_update_from_keywords() {
    keywordisfresh="1"
    if [ "$nkeywords" -gt 0 ]; then
        curkeyword=$(( (curkeyword+1) % (nkeywords+1) ))
        if [ "$curkeyword" -eq "0" ]; then
            buffer=""
        else
            buffer="${keywords[curkeyword]}"
        fi
    fi
}

_nlist_iterate_theme() {
    themeisfresh="1"
    if [ "$1" = "1" ]; then
        curtheme=$(( (curtheme+1) % (nthemes+1) ))
    else
        curtheme=curtheme-1
        [ "$curtheme" -lt 0 ] && curtheme=nthemes
    fi

    if [ "$nthemes" -gt 0 ]; then
        local theme=${themes[curtheme]}
        [ "$curtheme" -eq "0" ] && theme="$backuptheme"

        colorpair="${theme%/*}"
        bold="${theme##*/}"
        background="${colorpair#*/}"
        zcurses bg main "$colorpair"
        zcurses bg inner "$colorpair"
    fi
}

_nlist_rotate_buffer() {
    setopt localoptions noglob

    local -a words
    words=( ${(s: :)buffer} )
    words=( ${words[-1]} ${words[1,-2]} )

    local space=""
    [ "${buffer[-1]}" = " " ] && space=" "

    buffer="${(j: :)words}$space"
}

typeset -ga reply
reply=( -1 '' )
integer current_idx="$1"
integer from_what_idx_list_is_shown="$2"
integer page_height="$3"
integer page_width="$4"
integer last_element="$5"
integer hscroll="$6"
local key="$7"
integer search="$8"
local buffer="$9"
integer uniq_mode="$10"
integer f_mode="$11"

#
# Listening for input
#

if [ "$search" = "0" ]; then

case "$key" in
    (UP|k|$'\C-P')
        # Are there any elements before the current one?
        [ "$current_idx" -gt 1 ] && current_idx=current_idx-1;
        _nlist_compute_first_to_show_idx
        ;;
    (DOWN|j|$'\C-N')
        # Are there any elements after the current one?
        [ "$current_idx" -lt "$last_element" ] && current_idx=current_idx+1;
        _nlist_compute_first_to_show_idx
        ;;
    (PPAGE|$'\b'|$'\C-?'|BACKSPACE)
        current_idx=current_idx-page_height
        [ "$current_idx" -lt 1 ] && current_idx=1;
        _nlist_compute_first_to_show_idx
        ;;
    (NPAGE|" ")
        current_idx=current_idx+page_height
        [ "$current_idx" -gt "$last_element" ] && current_idx=last_element;
        _nlist_compute_first_to_show_idx
        ;;
    ($'\C-U')
        current_idx=current_idx-page_height/2
        [ "$current_idx" -lt 1 ] && current_idx=1;
        _nlist_compute_first_to_show_idx
        ;;
    ($'\C-D')
        current_idx=current_idx+page_height/2
        [ "$current_idx" -gt "$last_element" ] && current_idx=last_element;
        _nlist_compute_first_to_show_idx
        ;;
    (HOME|g)
        current_idx=1
        _nlist_compute_first_to_show_idx
        ;;
    (END|G)
        current_idx=last_element
        _nlist_compute_first_to_show_idx
        ;;
    ($'\n'|ENTER)
        # Is that element selectable?
        # Check for this only when there is no search
        if [[ "$NLIST_SEARCH_BUFFER" != "" || "$NLIST_IS_UNIQ_MODE" -eq 1 ||
            ${NLIST_NONSELECTABLE_ELEMENTS[(r)$current_idx]} != $current_idx ]]
        then
            # Save current element in the result variable
            reply=( $current_idx "SELECT" )
        fi
        ;;
    (H|'?')
        # This event needs to be enabled
        if [[ "${NLIST_ENABLED_EVENTS[(r)HELP]}" = "HELP" ]]; then
            reply=( -1 "HELP" )
        fi
        ;;
    (F1)
        # This event needs to be enabled
        if [[ "${NLIST_ENABLED_EVENTS[(r)F1]}" = "F1" ]]; then
            reply=( -1 "$key" )
        fi
        ;;
    (F4|F5|F6|F7|F8|F9|F10|DC)
        # ignore; F2, F3 are used below
        ;;
    (q)
        reply=( -1 "QUIT" )
        ;;
    (/)
        search=1
        _nlist_cursor_visibility 1
        ;;
    ($'\t')
        reply=( $current_idx "LEAVE" )
        ;;
    ($'\C-L')
        reply=( -1 "REDRAW" )
        ;;
    (\])
        [[ "${(t)NLIST_HOP_INDEXES}" = "array" || "${(t)NLIST_HOP_INDEXES}" = "array-local" ]] &&
        [ -z "$NLIST_SEARCH_BUFFER" ] && [ "$NLIST_IS_UNIQ_MODE" -eq 0 ] &&
        for idx in "${(n)NLIST_HOP_INDEXES[@]}"; do
            if [ "$idx" -gt "$current_idx" ]; then
                current_idx=$idx
                _nlist_compute_first_to_show_idx
                break
            fi
        done
        ;;
    (\[)
        [[ "${(t)NLIST_HOP_INDEXES}" = "array" || "${(t)NLIST_HOP_INDEXES}" = "array-local" ]] &&
        [ -z "$NLIST_SEARCH_BUFFER" ] && [ "$NLIST_IS_UNIQ_MODE" -eq 0 ] &&
        for idx in "${(nO)NLIST_HOP_INDEXES[@]}"; do
            if [ "$idx" -lt "$current_idx" ]; then
                current_idx=$idx
                _nlist_compute_first_to_show_idx
                break
            fi
        done
        ;;
    ('<'|'{'|LEFT|'h')
        hscroll=hscroll-7
        [ "$hscroll" -lt 0 ] && hscroll=0
        ;;
    ('>'|'}'|RIGHT|'l')
        hscroll+=7
        ;;
    ($'\E')
        buffer=""
        ;;
    (F3)
        if [ "$search" = "1" ]; then
            search=0
            _nlist_cursor_visibility 0
        else
            search=1
            _nlist_cursor_visibility 1
        fi
        ;;
    (o|$'\C-O')
        uniq_mode=1-uniq_mode
        ;;
    (f|$'\C-F')
        (( f_mode=(f_mode+1) % 3 ))
        ;;
    ($'\x1F'|F2|$'\C-X')
        search=1
        _nlist_cursor_visibility 1
        _nlist_update_from_keywords
        ;;
    ($'\C-T')
        _nlist_iterate_theme 1
        ;;
    ($'\C-G')
        _nlist_iterate_theme 0
        ;;
    ($'\C-E'|e)
        # This event needs to be enabled
        if [[ "${NLIST_ENABLED_EVENTS[(r)EDIT]}" = "EDIT" ]]; then
            reply=( -1 "EDIT" )
        fi
        ;;
    ($'\C-A')
        _nlist_rotate_buffer
        ;;
    (*)
        ;;
esac

else

case "$key" in
    ($'\n'|ENTER)
        if [ "$NLIST_INSTANT_SELECT" = "1" ]; then
            if [[ "$NLIST_SEARCH_BUFFER" != "" || "$NLIST_IS_UNIQ_MODE" -eq 1 ||
                ${NLIST_NONSELECTABLE_ELEMENTS[(r)$current_idx]} != $current_idx ]]
            then
                reply=( $current_idx "SELECT" )
            fi
        else
            search=0
            _nlist_cursor_visibility 0
        fi
        ;;
    ($'\C-L')
        reply=( -1 "REDRAW" )
        ;;

    #
    # Slightly limited navigation
    #

    (UP|$'\C-P')
        [ "$current_idx" -gt 1 ] && current_idx=current_idx-1;
        _nlist_compute_first_to_show_idx
        ;;
    (DOWN|$'\C-N')
        [ "$current_idx" -lt "$last_element" ] && current_idx=current_idx+1;
        _nlist_compute_first_to_show_idx
        ;;
    (PPAGE)
        current_idx=current_idx-page_height
        [ "$current_idx" -lt 1 ] && current_idx=1;
        _nlist_compute_first_to_show_idx
        ;;
    (NPAGE)
        current_idx=current_idx+page_height
        [ "$current_idx" -gt "$last_element" ] && current_idx=last_element;
        _nlist_compute_first_to_show_idx
        ;;
    ($'\C-U')
        current_idx=current_idx-page_height/2
        [ "$current_idx" -lt 1 ] && current_idx=1;
        _nlist_compute_first_to_show_idx
        ;;
    ($'\C-D')
        current_idx=current_idx+page_height/2
        [ "$current_idx" -gt "$last_element" ] && current_idx=last_element;
        _nlist_compute_first_to_show_idx
        ;;
    (HOME)
        current_idx=1
        _nlist_compute_first_to_show_idx
        ;;
    (END)
        current_idx=last_element
        _nlist_compute_first_to_show_idx
        ;;
    (LEFT)
        hscroll=hscroll-7
        [ "$hscroll" -lt 0 ] && hscroll=0
        ;;
    (RIGHT)
        hscroll+=7
        ;;
    (F1)
        # This event needs to be enabled
        if [[ "${NLIST_ENABLED_EVENTS[(r)F1]}" = "F1" ]]; then
            reply=( -1 "$key" )
        fi
        ;;
    (F4|F5|F6|F7|F8|F9|F10|DC)
        # ignore; F2, F3 are used below
        ;;

    #
    # The input
    #

    ($'\b'|$'\C-?'|BACKSPACE)
        buffer="${buffer%?}"
        ;;
    ($'\C-W')
        [ "$buffer" = "${buffer% *}" ] && buffer="" || buffer="${buffer% *}"
        ;;
    ($'\C-K')
        buffer=""
        ;;
    ($'\E')
        buffer=""
        search=0
        _nlist_cursor_visibility 0
        ;;
    (F3)
        if [ "$search" = "1" ]; then
            search=0
            _nlist_cursor_visibility 0
        else
            search=1
            _nlist_cursor_visibility 1
        fi
        ;;
    ($'\C-O')
        uniq_mode=1-uniq_mode
        ;;
    ($'\C-F')
        (( f_mode=(f_mode+1) % 3 ))
        ;;
    ($'\x1F'|F2|$'\C-X')
        _nlist_update_from_keywords
        ;;
    ($'\C-T')
        _nlist_iterate_theme 1
        ;;
    ($'\C-G')
        _nlist_iterate_theme 0
        ;;
    ($'\C-E')
        # This event needs to be enabled
        if [[ "${NLIST_ENABLED_EVENTS[(r)EDIT]}" = "EDIT" ]]; then
            reply=( -1 "EDIT" )
        fi
        ;;
    ($'\C-A')
        _nlist_rotate_buffer
        ;;
    (*)
        if [[ $#key == 1 && $((#key)) -lt 31 ]]; then
            # ignore all other control keys
        else
            buffer+="$key"
        fi
        ;;
esac

fi

reply[3]="$current_idx"
reply[4]="$from_what_idx_list_is_shown"
reply[5]="$hscroll"
reply[6]="$search"
reply[7]="$buffer"
reply[8]="$uniq_mode"
reply[9]="$f_mode"

# vim: set filetype=zsh:
}
alias nlist-input=n-list-input

n-options() {
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-options` to .zshrc
#
# This function allows to browse and toggle shell's options
#
# Uses n-list

#emulate -L zsh

zmodload zsh/curses

local IFS="
"

unset NLIST_COLORING_PATTERN

[ -f ~/.config/znt/n-list.conf ] && builtin source ~/.config/znt/n-list.conf
[ -f ~/.config/znt/n-options.conf ] && builtin source ~/.config/znt/n-options.conf

# TODO restore options
unsetopt localoptions

integer kshoptionprint=0
[[ -o kshoptionprint ]] && kshoptionprint=1
setopt kshoptionprint

local list
local selected
local option
local state

# 0 - don't remember, 1 - remember, 2 - init once, then remember
NLIST_REMEMBER_STATE=2

local NLIST_GREP_STRING="${1:=}"

while (( 1 )); do
    list=( `setopt` )
    list=( "${(M)list[@]:#*${1:=}*}" )
    list=( "${list[@]:#kshoptionprint*}" )

    if [ "$#list" -eq 0 ]; then
        echo "No matching options"
        break
    fi

    local red=$'\x1b[00;31m' green=$'\x1b[00;32m' reset=$'\x1b[00;00m'
    list=( "${list[@]/ off/${red} off$reset}" )
    #list=( "${list[@]/ on/${green} on$reset}" )
    list=( "${(i)list[@]}" )

    n-list "${list[@]}"

    if [ "$REPLY" -gt 0 ]; then
        [[ -o ksharrays ]] && selected="${reply[$(( REPLY - 1 ))]}" || selected="${reply[$REPLY]}"
        option="${selected%% *}"
        state="${selected##* }"

        if [[ -o globsubst ]]; then
            unsetopt globsubst
            state="${state%$reset}"
            setopt globsubst
        else
            state="${state%$reset}"
        fi

        # Toggle the option
        if [ "$state" = "on" ]; then
            echo "Setting |$option| to off"
            unsetopt "$option"
        else
            echo "Setting |$option| to on"
            setopt "$option"
        fi
    else
        break
    fi
done

NLIST_REMEMBER_STATE=0

[[ "$kshoptionprint" -eq 0 ]] && unsetopt kshoptionprint

# vim: set filetype=zsh:
}
alias noptions=n-options

n-panelize() {
# Copy this file into /usr/share/zsh/site-functions/
# and add 'autoload n-panelize` to .zshrc
#
# This function somewhat reminds the panelize feature from Midnight Commander
# It allows browsing output of arbitrary command. Example usage:
# v-panelize ls /usr/local/bin
#
# Uses n-list

emulate -L zsh

setopt extendedglob
zmodload zsh/curses

local IFS="
"

unset NLIST_COLORING_PATTERN

[ -f ~/.config/znt/n-list.conf ] && builtin source ~/.config/znt/n-list.conf
[ -f ~/.config/znt/n-panelize.conf ] && builtin source ~/.config/znt/n-panelize.conf

local list
local selected

NLIST_REMEMBER_STATE=0

if [ -t 0 ]; then
    # Check if there is proper input
    if [ "$#" -lt 1 ]; then
        echo "Usage: n-panelize {command} [option|argument] ... or command | n-panelize"
        return 1
    fi

    # This loop makes script faster on some Zsh's (e.g. 5.0.8)
    repeat 1; do
        list=( `"$@"` )
    done

    # TODO: $? doesn't reach user
    [ "$?" -eq 127 ] && return $?
else
    # Check if can reattach to terminal
    if [[ ! -c /dev/tty && ! -t 2 ]]; then
        echo "No terminal available (no /dev/tty)"
        return 1
    fi

    # This loop makes script faster on some Zsh's (e.g. 5.0.8)
    repeat 1; do
        list=( "${(@f)"$(<&0)"}" )
    done

    if [[ ! -c /dev/tty ]]; then
        exec <&2
    else
        exec </dev/tty
    fi
fi

n-list "${list[@]}"

if [ "$REPLY" -gt 0 ]; then
    selected="$reply[REPLY]"
    print -zr "# $selected"
fi

# vim: set filetype=zsh:
}
alias npanelize=n-panelize

znt-cd-widget() {
autoload znt-usetty-wrapper n-cd
local NLIST_START_IN_SEARCH_MODE=0
local NLIST_START_IN_UNIQ_MODE=0

znt-usetty-wrapper n-cd "$@"

unset NLIST_START_IN_SEARCH_MODE
unset NLIST_START_IN_UNIQ_MODE
}

znt-history-widget() {
autoload znt-usetty-wrapper n-history
local NLIST_START_IN_SEARCH_MODE=1
local NLIST_START_IN_UNIQ_MODE=1

# Only if current $BUFFER doesn't come from history
if [ "$HISTCMD" = "$HISTNO" ]; then
    () {
        setopt localoptions extendedglob
        local -a match mbegin mend
        local MATCH; integer MBEGIN MEND

        [ -n "$BUFFER" ] && BUFFER="${BUFFER%% ##} "
    }

    local NLIST_SET_SEARCH_TO="$BUFFER"
fi

znt-usetty-wrapper n-history "$@"

unset NLIST_START_IN_SEARCH_MODE
unset NLIST_START_IN_UNIQ_MODE
unset NLIST_SET_SEARCH_TO
}

znt-kill-widget() {
autoload znt-usetty-wrapper n-kill
local NLIST_START_IN_SEARCH_MODE=0
local NLIST_START_IN_UNIQ_MODE=0

znt-usetty-wrapper n-kill "$@"

unset NLIST_START_IN_SEARCH_MODE
unset NLIST_START_IN_UNIQ_MODE
}

znt-usetty-wrapper() {
emulate -L zsh

zmodload zsh/curses

test_fd0() {
    true <&0
}

local restore=0 FD

# Reattach to terminal
if [ ! -t 0 ]; then
    # Check if can reattach to terminal in any way
    if [[ ! -c /dev/tty && ! -t 2 ]]; then
        echo "No terminal available (no /dev/tty and no terminal at stderr)"
        return 1
    fi

    if test_fd0 2>/dev/null; then
        exec {FD}<&0
        restore=2
    else
        restore=1
    fi

    if [[ ! -c /dev/tty ]]; then
        exec <&2
    else
        exec </dev/tty
    fi
fi

# Run the command
"$@"

# Restore FD state
(( restore == 1 )) && exec <&-
(( restore == 2 )) && exec <&$FD && exec {FD}<&-

# vim: set filetype=zsh:
}

zle -N znt-history-widget
bindkey '^R' znt-history-widget
setopt AUTO_PUSHD HIST_IGNORE_DUPS PUSHD_IGNORE_DUPS
