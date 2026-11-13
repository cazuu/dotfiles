typeset -U path PATH

#----------------------------------
# Homebrew（Apple Silicon / Intel 共通）
#----------------------------------
for _brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [[ -x $_brew_bin ]]; then
    eval "$($_brew_bin shellenv)"
    break
  fi
done
unset _brew_bin

#----------------------------------
# Antidote プラグイン管理
#----------------------------------
if [[ ! -d ${ZDOTDIR:-$HOME}/.antidote ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
fi
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh

#----------------------------------
# 基本設定
#----------------------------------
# Viキーバインド
bindkey -v

# 履歴
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt share_history hist_ignore_all_dups hist_reduce_blanks extended_history

#----------------------------------
# プラグイン設定
#----------------------------------
antidote load ${HOME}/dotfiles/.bin/.zsh_plugins.txt

autoload -Uz compinit && compinit

# Pure prompt設定
autoload -U promptinit; promptinit
prompt pure

# zsh-history-substring-search キーバインディング
bindkey '^[[A' history-substring-search-up    # 上キー
bindkey '^[[B' history-substring-search-down  # 下キー
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

#----------------------------------
# 環境変数・PATH設定
#----------------------------------
export PATH="$HOME/.local/bin:$PATH"          # ユーザーローカルバイナリ
export PATH="/usr/local/sbin:$PATH"

if [[ -n $HOMEBREW_PREFIX ]]; then
  for _formula in openssl@3 libpq mysql-client; do
    [[ -d $HOMEBREW_PREFIX/opt/$_formula/bin ]] && export PATH="$HOMEBREW_PREFIX/opt/$_formula/bin:$PATH"
  done
  unset _formula
fi

#----------------------------------
# 開発環境初期化
#----------------------------------
export MISE_AQUA_REGISTRY_SKIP_ATTESTATION=1
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

#----------------------------------
# Android SDK
#----------------------------------
[[ -d "$HOME/Library/Android/sdk" ]] && {
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$ANDROID_HOME/emulator:$PATH"
  export PATH="$ANDROID_HOME/platform-tools:$PATH"
}

#----------------------------------
# Google Cloud SDK
#----------------------------------
if [[ -f "$HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc" ]]; then
  source "$HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
  source "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"
fi

#----------------------------------
# エイリアス
#----------------------------------
alias ll='ls -al'           # 詳細なディレクトリリスト
alias dc='docker compose'   # Docker Compose
alias ssh-config-update="rm -f ~/.ssh/config;cat ~/.ssh/conf.d/config ~/.ssh/conf.d/**/ssh.conf > ~/.ssh/config"
alias clean-branch="git branch -vv | awk '/: gone]/{print \$1}' | xargs git branch -d"

#----------------------------------
# ユーティリティ関数
#----------------------------------
# enableLocalLoopbackAddress - 複数のローカルループバックアドレスを有効化
function enableLocalLoopbackAddress() {
  for ((i=2;i<256;i++))
  do
    sudo ifconfig lo0 alias 127.0.0.$i up
  done
}

# goo - Google検索をターミナルから実行
function goo() {
    # 第一引数がない場合はpbpasteの中身を検索単語とする
    [ -z "$1" ] && searchWord=`pbpaste` || searchWord=$1
    open https://www.google.co.jp/search\?q\=$searchWord
}

[[ -d "$HOME/.codeium/windsurf/bin" ]] && export PATH="$HOME/.codeium/windsurf/bin:$PATH"

[[ -d "$HOME/.antigravity/antigravity/bin" ]] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

[[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro >/dev/null 2>&1 && . "$(kiro --locate-shell-integration-path zsh)"

[[ -d "$HOME/go/bin" ]] && export PATH="$HOME/go/bin:$PATH"

# Locale settings
export LANG=ja_JP.UTF-8

#----------------------------------
# リポジトリ外の設定（任意）
#----------------------------------
[[ -f ~/.zshrc.private ]] && source ~/.zshrc.private
# 機種固有の設定や、ツールが自動追記したがる行はここに書く（リポジトリの .zshrc を汚さないため）
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
