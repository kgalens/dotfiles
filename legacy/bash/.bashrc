# Configure homebrew in the shell
eval "$(/opt/homebrew/bin/brew shellenv)"

# Git branch in prompt.
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

#export PS1="\\[\033[36m\]\u\[\033[m\]@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\[\033[32m\]\$(parse_git_branch) \[\033[00m\]\$ "
export CLICOLOR=1
export LSCOLORS=exfxcxdxbxegedabagacad
alias ls='ls -GFh'

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv init --path)"
fi

#OktaAWSCLI
if [[ -f "$HOME/.okta/bash_functions" ]]; then
    . "$HOME/.okta/bash_functions"
fi
if [[ -d "$HOME/.okta/bin" && ":$PATH:" != *":$HOME/.okta/bin:"* ]]; then
    PATH="$HOME/.okta/bin:$PATH"
fi

# Some java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

