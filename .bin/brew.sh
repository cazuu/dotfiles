#!/bin/bash

. ./.bin/util.sh

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

e_run 'brew.sh'

brew bundle --global

if [[ `uname -m` == 'x86_64' ]]; then
    sudo -- sh -c "echo '/usr/local/bin/zsh' >> /etc/shells"
    chsh -s /usr/local/bin/zsh
fi

e_done  'brew.sh'
