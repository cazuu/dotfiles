# Do everything.
all: init link system brew

# Set initial preference.
init:
	.bin/init.sh

# Link dotfiles.
link:
	.bin/link.sh

# Set macOS system preferences.
system:
	.bin/system.sh

# Install macOS applications.
brew:
	.bin/brew.sh

brew-update:
	brew update
	brew upgrade --cask
	brew bundle --global
