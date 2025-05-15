#!/bin/bash

. ./.bin/util.sh

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

# Remove pre-install application in Dock
defaults write com.apple.dock persistent-apps -array

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
# SystemUIServer
#
# ====================

# Display date, day, and time in the menu bar
defaults write com.apple.menuextra.clock DateFormat -string 'EEE d MMM HH:mm'

# Display battery level in the menu bar
#defaults write com.apple.menuextra.battery ShowPercent -string "YES"


# ====================
#
# Safari
#
# ====================

# url is full path in address bar
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

for app in "Dock" \
	"Finder" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done

e_done "system.sh"