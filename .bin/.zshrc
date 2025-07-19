#----------------------------------
# Antidote プラグイン管理
#----------------------------------
# Install Antidote if not present
if [[ ! -d ${ZDOTDIR:-$HOME}/.antidote ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
fi
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh

#----------------------------------
# 基本設定
#----------------------------------
# Viキーバインド
bindkey -v

#----------------------------------
# プラグイン設定
#----------------------------------
# プラグイン読み込み（ファイルパスを絶対パスで指定）
antidote load ${HOME}/dotfiles/.bin/.zsh_plugins.txt

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
# アーキテクチャ固有の設定 (Intel/Apple Silicon)
if [[ `uname -m` == 'arm64' ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
else
    export PATH="/usr/local/opt/mysql-client/bin:$PATH"
fi

# 各種開発環境のPATH設定
export PATH="$HOME/.nodenv/bin:$PATH"         # Node.js
export PATH="$HOME/.rbenv/bin:$PATH"          # Ruby
export PATH="$HOME/.goenv/bin:$PATH"          # Go
export PYENV_ROOT="$HOME/.pyenv"              # Python
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/opt/homebrew/bin/openssl:$PATH"  # OpenSSL
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"     # PostgreSQL
export PATH="$HOME/.local/bin:$PATH"          # ユーザーローカルバイナリ

#----------------------------------
# 開発環境初期化
#----------------------------------
eval "$(nodenv init -)"     # Node.js
eval "$(rbenv init -)"      # Ruby
eval "$(goenv init -)"      # Go
eval "$(pyenv init -)"      # Python

#----------------------------------
# Google Cloud SDK
#----------------------------------
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

#----------------------------------
# エイリアス
#----------------------------------
alias ll='ls -al'           # 詳細なディレクトリリスト
alias dc='docker compose'   # Docker Compose
alias ssh-config-update="rm -rf ~/.ssh/config;cat ~/.ssh/conf.d/config ~/.ssh/conf.d/**/ssh.conf > ~/.ssh/config"
alias clean-branch="git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -d"

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
