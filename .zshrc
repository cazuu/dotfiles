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

# alias
alias ll='ls -al'
alias ssh-config-update="rm -rf ~/.ssh/config;cat ~/.ssh/conf.d/config ~/.ssh/conf.d/**/ssh.conf > ~/.ssh/config"

export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
