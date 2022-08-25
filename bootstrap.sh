#!/bin/bash

DOTPATH="$HOME/dotfiles"; export DOTPATH
DOTFILES_GITHUB="https://github.com/cazuu/dotfiles.git"; export DOTFILES_GITHUB

dotfiles_logo='
      | |     | |  / _(_) |           
    __| | ___ | |_| |_ _| | ___  ___  
   / _` |/ _ \| __|  _| | |/ _ \/ __| 
  | (_| | (_) | |_| | | | |  __/\__ \ 
   \__,_|\___/ \__|_| |_|_|\___||___/ 
'

# is_exists returns true if executable $1 exists in $PATH
is_exists() {
    which "$1" >/dev/null 2>&1
    return $?
}

e_newline() {
    printf "\n"
}

e_header() {
    printf " \033[37;1m%s\033[m\n" "$*"
}

e_error() {
    printf " \033[31m%s\033[m\n" "✖ $*" 1>&2
}

e_warning() {
    printf " \033[31m%s\033[m\n" "$*"
}

e_done() {
    printf " \033[37;1m%s\033[m...\033[32mOK\033[m\n" "✔ $*"
}

e_arrow() {
    printf " \033[37;1m%s\033[m\n" "➜ $*"
}

dotfiles_download() {
    if [ -d "$DOTPATH" ]; then
        e_warning "$DOTPATH: already exists"
        return
    fi

    e_newline
    e_header "Downloading dotfiles..."

    if is_exists "git"; then
        git clone --recursive "$DOTFILES_GITHUB" "$DOTPATH"
    elif is_exists "curl" || is_exists "wget"; then
        local tarball="https://github.com/cazuu/dotfiles/archive/master.tar.gz"
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
    e_newline && e_done "Download"
}

install_command_line_tool() {
    if ! command xcode-select -p &> /dev/null; then
	    e_arrow "Install xcode-select"
	    xcode-select --install
            read -p "Finished installing xcode-select?"
    fi

    e_newline && e_done "Done command line tool"
}

install_nodenv() {
    if ! command -v nodenv &> /dev/null; then
	    e_arrow "Install nodenv"
	    git clone https://github.com/nodenv/nodenv.git ~/.nodenv
    fi
    e_newline && e_done "Done install nodenv"
}

install_nodenv_plugins() {
	if [ ! -d ~/.nodenv/plugins ]; then
                e_arrow "Install nodenv-plugins"
		mkdir -p "$(nodenv root)"/plugins
		git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
	fi
}

deploy() {
    e_newline
    e_header "Deploying dotfiles..."

    if [ ! -d $DOTPATH ]; then
        log_fail "$DOTPATH: not found"
        exit 1
    fi
    
    cd "$DOTPATH"

    echo
    chmod +x etc/deploy.sh
    etc/deploy.sh

    e_newline && e_done "Deploy"
}

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        cd "$DOTPATH"

        e_arrow 'Install Homebrew'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        git -C $(brew --repo homebrew/core) checkout master
    
        if [[ `uname -m` == 'arm64' ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
    e_newline && e_done "Done install homebrew"
}

brew_bundle() {
    cd "$DOTPATH"

    e_arrow 'brew bundle'
    brew bundle

    if [[ `uname -m` == 'x86_64' ]]; then
        sudo -- sh -c "echo '/usr/local/bin/zsh' >> /etc/shells"
        chsh -s /usr/local/bin/zsh
    fi

    e_newline && e_done "Done brew bundle"
}

activate() {
	source ~/.zshrc
}

echo "$dotfiles_logo"

echo "Dotfiles START"

dotfiles_download
install_command_line_tool
deploy
install_homebrew
brew_bundle
activate
install_nodenv
install_nodenv_plugins

echo "Dotfiles DONE"

