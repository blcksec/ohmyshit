# Michele Bologna's theme
# https://www.michelebologna.net
#
# This a theme for oh-my-shit. Features a colored prompt with:
# * username@host: [jobs] [git] workdir %
# * hostname color is based on hostname characters. When using as root, the
# prompt shows only the hostname in red color.
# * [jobs], if applicable, counts the number of suspended jobs tty
# * [git], if applicable, represents the status of your git repo (more on that
# later)
# * '%' prompt will be green if last command return value is 0, yellow otherwise.
#
# git prompt is inspired by official git contrib prompt:
# https://github.com/git/git/tree/master/contrib/completion/git-prompt.sh
# and it adds:
# * the current branch
# * '%' if there are untracked files
# * '$' if there are stashed changes
# * '*' if there are modified files
# * '+' if there are added files
# * '<' if local repo is behind remote repo
# * '>' if local repo is ahead remote repo
# * '=' if local repo is equal to remote repo (in sync)
# * '<>' if local repo is diverged

local green="%{$fg_bold[green]%}"
local red="%{$fg_bold[red]%}"
local cyan="%{$fg_bold[cyan]%}"
local yellow="%{$fg_bold[yellow]%}"
local blue="%{$fg_bold[blue]%}"
local magenta="%{$fg_bold[magenta]%}"
local white="%{$fg_bold[white]%}"
local reset="%{$reset_color%}"

local -a color_array
color_array=($green $red $cyan $yellow $blue $magenta $white)

local username_color=$white
local hostname_color=$color_array[$[((#HOST))%7+1]] # choose hostname color based on first character
local current_dir_color=$blue

local username="%n"
local hostname="%m"
local current_dir="%~"

local username_output="%(!..${username_color}${username}${reset}@)"
local hostname_output="${hostname_color}${hostname}${reset}"
local current_dir_output="${current_dir_color}${current_dir}${reset}"
local jobs_bg="${red}fg: %j$reset"
local last_command_output="%(?.%(!.$red.$green).$yellow)"

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_UNTRACKED="$blue%%"
ZSH_THEME_GIT_PROMPT_MODIFIED="$red*"
ZSH_THEME_GIT_PROMPT_ADDED="$green+"
ZSH_THEME_GIT_PROMPT_STASHED="$blue$"
ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE="$green="
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE=">"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="<"
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE="$red<>"

function michelebologna_git_prompt {
  local out=$(git_prompt_info)$(git_prompt_status)$(git_remote_status)
  [[ -n $out ]] || return
  printf " %s(%s%s%s)%s" \
    "%{$fg_bold[white]%}" \
    "%{$fg_bold[green]%}" \
    "$out" \
    "%{$fg_bold[white]%}" \
    "%{$reset_color%}"
}

PROMPT="$username_output$hostname_output:$current_dir_output%1(j. [$jobs_bg].)"
PROMPT+='$(michelebologna_git_prompt)'
PROMPT+=" $last_command_output%#$reset "
RPROMPT=''
