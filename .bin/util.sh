# shellcheck shell=bash

# is_exists returns true if executable $1 exists in $PATH
is_exists() {
    command -v "$1" >/dev/null 2>&1
}

e_newline() {
    printf "\n"
}

e_header() {
    e_newline
    printf " \033[37;1m%s\033[m\n" "$*"
}

e_run() {
    printf " \033[37;1m%s\033[m...\033[32mRUN\033[m\n" "● $*"
}

e_error() {
    printf " \033[31m%s\033[m\n" "✖ $*" 1>&2
}

e_warning() {
    printf " \033[31m%s\033[m\n" "$*"
}

e_done() {
    printf " \033[37;1m%s\033[m...\033[32mOK\033[m\n" "✔ $*"
    e_newline
}

e_arrow() {
    printf " \033[37;1m%s\033[m\n" "➜ $*"
}

# make はターゲットごとに別シェルで動くため、brew を使うスクリプトは各自でこれを呼ぶ
load_brew_env() {
    local brew_bin
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_bin" ]; then
            eval "$("$brew_bin" shellenv)"
            return 0
        fi
    done
    return 1
}

# Command Line Tools のインストールは GUI ダイアログで非同期に進むため、完了まで待つ
ensure_clt() {
    if xcode-select -p >/dev/null 2>&1; then
        return 0
    fi
    xcode-select --install >/dev/null 2>&1
    e_arrow "Command Line Tools のインストールダイアログを完了してください（待機中）"
    until xcode-select -p >/dev/null 2>&1; do
        sleep 5
    done
}
