if [ ! -e "${HOME}/.zplug/init.zsh" ]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
fi

bindkey -e

source ${HOME}/.zplug/init.zsh

export PATH="/usr/local/opt/mysql-client/bin:$PATH"

zplug "zsh-users/zsh-autosuggestions"
zplug "peco/peco", as:command, from:gh-r

if ! zplug check --verbose; then
    printf "Install? [y/N]:"
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
