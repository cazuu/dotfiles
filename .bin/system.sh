#!/bin/bash

# shellcheck source=.bin/util.sh
. "$(cd "$(dirname "$0")" && pwd)/util.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

e_run "system.sh"

# ====================
#
# Base
#
# ====================


# Disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable CrashReporter
defaults write com.apple.CrashReporter DialogType -string "none"

# ====================
#
# Screenshots
#
# ====================

# Set screenshots location to Downloads folder
defaults write com.apple.screencapture location -string "$HOME/Downloads"

# ====================
#
# Dock
#
# ====================


# Disable animation at application launch
defaults write com.apple.dock launchanim -bool false

# 実行のたびに Dock が空になるので、初回セットアップ時だけ明示的に有効化する
if [ "${DOTFILES_RESET_DOCK:-}" = "1" ]; then
	defaults write com.apple.dock persistent-apps -array
fi

# ====================
#
# Finder
#
# ====================


# Disable animation
defaults write com.apple.finder DisableAllAnimations -bool true

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show files with all extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Display the status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Display the path bar
defaults write com.apple.finder ShowPathbar -bool true

# Disable create .DS_Store in network storage
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable create .DS_Store in USB storage
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Search scope is current directory
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# ====================
#
# iTerm2
#
# ====================

# Load preferences from this repository
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$REPO_ROOT/iterm"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

for app in "Dock" \
	"Finder" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done

e_done "system.sh"