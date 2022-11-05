# Handle completions insecurities (i.e., completion-dependent directories with
# insecure ownership or permissions) by:
#
# * Human-readably notifying the user of these insecurities.
function handle_completion_insecurities() {
  # List of the absolute paths of all unique insecure directories, split on
  # newline from compaudit()'s output resembling:
  #
  #     There are insecure directories:
  #     /usr/share/zsh/site-functions
  #     /usr/share/zsh/5.0.6/functions
  #     /usr/share/zsh
  #     /usr/share/zsh/5.0.6
  #
  # Since the ignorable first line is printed to stderr and thus not captured,
  # stderr is squelched to prevent this output from leaking to the user. 
  local -aU insecure_dirs
  insecure_dirs=( ${(f@):-"$(compaudit 2>/dev/null)"} )

  # If no such directories exist, get us out of here.
  [[ -z "${insecure_dirs}" ]] && return

  # List ownership and permissions of all insecure directories.
  print "[oh-my-shit] Insecure completion-dependent directories detected:"
  ls -ld "${(@)insecure_dirs}"

  cat <<EOD

[oh-my-shit] For safety, we will not load completions from these directories until
[oh-my-shit] you fix their permissions and ownership and restart zsh.
[oh-my-shit] See the above list for directories with group or other writability.

[oh-my-shit] To fix your permissions you can do so by disabling
[oh-my-shit] the write permission of "group" and "others" and making sure that the
[oh-my-shit] owner of these directories is either root or your current user.
[oh-my-shit] The following command may help:
[oh-my-shit]     compaudit | xargs chmod g-w,o-w

[oh-my-shit] If the above didn't help or you want to skip the verification of
[oh-my-shit] insecure directories you can set the variable ZSH_DISABLE_COMPFIX to
[oh-my-shit] "true" before oh-my-shit is sourced in your zshrc file.

EOD
}
