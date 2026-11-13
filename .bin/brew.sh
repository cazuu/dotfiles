#!/bin/bash
# Usage: brew.sh [install|update|check]

# shellcheck source=.bin/util.sh
. "$(cd "$(dirname "$0")" && pwd)/util.sh"

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

MODE="${1:-install}"

e_run "brew.sh $MODE"

if ! load_brew_env; then
    e_error "Homebrew not found. Run 'make init' first."
    exit 1
fi

brewfiles=("$HOME/.Brewfile")
[ -f "$HOME/.Brewfile.local" ] && brewfiles+=("$HOME/.Brewfile.local")

fail() {
    e_error "$*"
    exit 1
}

bundle_all() {
    local f
    for f in "${brewfiles[@]}"; do
        brew bundle --file="$f" || fail "brew bundle failed: $f"
    done
}

register_zsh() {
    local zsh_path current_shell
    zsh_path="$(brew --prefix)/bin/zsh"
    [ -x "$zsh_path" ] || return 0
    if ! grep -qxF "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || fail "failed to register $zsh_path in /etc/shells"
    fi
    # $SHELL は chsh 直後のセッションでは古いままなので、ユーザーDBの値で比較する
    current_shell="$(dscl . -read "/Users/$(id -un)" UserShell | awk '{print $2}')"
    if [ "$current_shell" != "$zsh_path" ]; then
        chsh -s "$zsh_path" || fail "chsh failed"
    fi
}

case "$MODE" in
    install)
        bundle_all
        register_zsh
        ;;
    update)
        brew update || fail "brew update failed"
        # bundle を upgrade より先に実行しないと restart_service: :changed が発火しない
        bundle_all
        brew upgrade || fail "brew upgrade failed"
        ;;
    check)
        [ -f "$HOME/.Brewfile" ] || fail "$HOME/.Brewfile not found. Run 'make link' first."
        tmp="$(mktemp)"
        trap 'rm -f "$tmp"' EXIT
        cat "${brewfiles[@]}" > "$tmp"
        e_arrow "Missing or outdated on this Mac"
        brew bundle check --file="$tmp" --verbose
        check_status=$?
        e_arrow "Installed but not in any Brewfile"
        # --force なしの cleanup は確認プロンプトで y を受けると削除するので、入力を塞ぐ。
        # 余剰があるだけで非ゼロを返すため、終了コードには反映しない
        brew bundle cleanup --file="$tmp" </dev/null
        [ "$check_status" -eq 0 ] || fail "some packages are missing or outdated on this Mac"
        ;;
    *)
        e_error "Unknown mode: $MODE"
        exit 1
        ;;
esac

e_done "brew.sh $MODE"
