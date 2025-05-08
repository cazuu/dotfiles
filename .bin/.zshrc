if [ ! -e "${HOME}/.zplug/init.zsh" ]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
fi

bindkey -v

source ${HOME}/.zplug/init.zsh

if [[ `uname -m` == 'arm64' ]]; then
    export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
else
    export PATH="/usr/local/opt/mysql-client/bin:$PATH"
fi

zplug "zsh-users/zsh-autosuggestions"
zplug "peco/peco", as:command, from:gh-r
zplug "modules/prompt", from:prezto

zstyle ':prezto:module:prompt' theme 'minimal'

if ! zplug check --verbose; then
    printf "Install? [y/N]:"
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

# alias
alias ll='ls -al'
alias dc='docker compose'
alias ssh-config-update="rm -rf ~/.ssh/config;cat ~/.ssh/conf.d/config ~/.ssh/conf.d/**/ssh.conf > ~/.ssh/config"

# Library
if [[ `uname -m` == 'arm64' ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

export PATH="$HOME/.goenv/bin:$PATH"
eval "$(goenv init -)"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PATH="$HOME/opt/homebrew/bin/openssl:$PATH"

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

# Function

alias enableLocalLoopbackAddress='_enableLocalLoopbackAddress'
function _enableLocalLoopbackAddress() {
  for ((i=2;i<256;i++))
  do
    sudo ifconfig lo0 alias 127.0.0.$i up
  done
}

alias goo='_searchByGoogle'
function _searchByGoogle() {
    # 第一引数がない場合はpbpasteの中身を検索単語とする
    [ -z "$1" ] && searchWord=`pbpaste` || searchWord=$1
    open https://www.google.co.jp/search\?q\=$searchWord
}
