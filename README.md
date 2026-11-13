# dotfiles

新しい Mac（Intel / Apple Silicon）のセットアップを自動化するための dotfiles です。

## インストール

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/cazuu/dotfiles/master/bootstrap.sh)"
```

Mac App Store のアプリも入れるので、先に App Store にサインインしておいてください。
Command Line Tools のインストールダイアログが出たら完了させてください（完了するまで待機します）。
その後 `~/dotfiles` に clone され、`make all` が実行されます。

Dock を空の状態から始めたい場合は、初回だけ `DOTFILES_RESET_DOCK=1` を付けて実行します。

```sh
cd ~/dotfiles && DOTFILES_RESET_DOCK=1 make system
```

## make ターゲット

| ターゲット | 内容 |
|---|---|
| `make all` | `init` → `link` → `system` → `brew` を順に実行 |
| `make init` | Command Line Tools と Homebrew をインストール |
| `make link` | `.zshrc` / `.zsh_plugins.txt` / `.Brewfile` をホームにリンク |
| `make system` | macOS の設定（Finder / Dock / スクリーンショット / iTerm2 の設定フォルダ） |
| `make brew` | Brewfile のアプリをインストールし、Homebrew の zsh をログインシェルにする |
| `make brew:update` | Homebrew を更新し、Brewfile を再適用してから残りのパッケージも更新 |
| `make brew:check` | この Mac に足りないものと、どの Brewfile にも無いものを表示（何も変更しない） |

## 機種ごとの設定

リポジトリには 2 台で共通の設定だけを置きます。機種固有のものは、リポジトリ外の次のファイルに書きます（いずれも任意）。

| ファイル | 用途 |
|---|---|
| `~/.Brewfile.local` | その Mac だけに入れるアプリ（`make brew` で共通の Brewfile の後に適用） |
| `~/.zshrc.local` | その Mac だけの zsh 設定、ツールが自動追記したがる行 |
| `~/.zshrc.private` | 公開したくない設定 |

共通の Brewfile にアプリを追加するときは `.bin/.Brewfile` を直接編集します。
`make brew:check` で、Brewfile に載っていないアプリを確認できます。

## 補足

- ログインシェルは Homebrew の zsh になります。Homebrew の zsh が壊れたときは `chsh -s /bin/zsh` で macOS 標準の zsh に戻せます。
- PostgreSQL（`postgresql@17`）は開発用で、サービスとして自動で起動します。別の版の PostgreSQL が 5432 番ポートで動いていると起動できないので、先に `brew services stop postgresql@14` のように止めてください。

## iTerm2

`make system` で、iTerm2 が設定を `iterm/` から読み込むようになります。
iTerm2 は設定変更時に `iterm/com.googlecode.iterm2.plist` を書き換えるので、必要な変更だけコミットしてください。
