.PHONY: all init link system brew brew\:update brew\:check

# Do everything.
all: init link system brew

# Install Command Line Tools and Homebrew.
init:
	.bin/init.sh

# Link dotfiles.
link:
	.bin/link.sh

# Set macOS system preferences.
system:
	.bin/system.sh

# Install applications from ~/.Brewfile (and ~/.Brewfile.local if present).
brew:
	.bin/brew.sh install

# Update Homebrew and all packages.
brew\:update:
	.bin/brew.sh update

# Show packages missing from this machine and packages not listed in any Brewfile.
brew\:check:
	.bin/brew.sh check
