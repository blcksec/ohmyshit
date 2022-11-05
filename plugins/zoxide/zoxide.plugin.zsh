if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
else
  echo '[oh-my-shit] zoxide not found, please install it from https://github.com/ajeetdsouza/zoxide'
fi
