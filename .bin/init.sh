#!/bin/bash

. ./.bin/util.sh

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

e_run "init.sh"

# Install xcode
e_arrow "Install xcode-select"
if ! command xcode-select -p &> /dev/null; then
    xcode-select --install > /dev/null
fi
e_arrow "Done command line tool"

# Install brew
e_arrow 'Install Homebrew'
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null
    git -C $(brew --repo homebrew/core) checkout master
    
    if [[ `uname -m` == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi  
fi
e_arrow "Done install homebrew"

e_done "init.sh"
