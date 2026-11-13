#!/bin/bash

# shellcheck source=.bin/util.sh
. "$(cd "$(dirname "$0")" && pwd)/util.sh"

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

e_run "init.sh"

e_arrow "Install Command Line Tools"
ensure_clt
e_arrow "Done Command Line Tools"

e_arrow 'Install Homebrew'
if ! load_brew_env; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if ! load_brew_env; then
        e_error "Homebrew not found after install"
        exit 1
    fi
fi
e_arrow "Done install Homebrew"

e_done "init.sh"
