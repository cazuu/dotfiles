#!/bin/bash

DOTPATH="$HOME/dotfiles"
DOTFILES_GITHUB=""

# is_exists returns true if executable $1 exists in $PATH
is_exists() {
    which "$1" >/dev/null 2>&1
    return $?
}

dotfiles_download() {
    if is_exists "git"; then
        git clone --recursive "$DOTFILES_GITHUB" "$DOTPATH"
    elif is_exists "curl" || is_exists "wget"; then
        local tarball=""
        if is_exists "curl"; then
            curl -L "$tarball"
        elif is_exists "wget"; then
            wget -O - "$tarball"
        fi | tar xvz
        if [ ! -d dotfiles-master ]; then
            echo "dotfiles-master: not found"
            exit 1
        fi
        command mv -f dotfiles-master "$DOTPATH"
    else
        echo "curl or wget required"
        exit 1
    fi
}

install_nodenv() {
    if ! command -v nodenv > /dev/null 2>&1; then
        echo "Install nodenv"
	    git clone https://github.com/nodenv/nodenv.git ~/.nodenv
    fi
}

install_nodenv_plugins() {
    mkdir -p "$(nodenv root)"/plugins
    git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
}

deploy() {
    cd "$DOTPATH"

    echo
    etc/deploy.sh
}

install_homebrew() {
    if ! command -v brew > /dev/null 2>&1; then
        cd "$DOTPATH"

        echo 'Install Homebrew'
        xcode-select --install
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}

brew_bundle() {
    cd "$DOTPATH"

    echo
    brew bundle

    sudo -- sh -c "echo '/usr/local/bin/zsh' >> /etc/shells"
    chsh -s /usr/local/bin/zsh

    cp -f /usr/local/opt/ricty/share/fonts/Ricty*.ttf ~/Library/Fonts/
    fc-cache -vf

    echo 
}

echo "Dotfiles START"

dotfiles_download
install_nodenv
deploy
install_nodenv_plugins
install_homebrew
brew_bundle

echo "Dotfiles DONE"
