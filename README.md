# dotfiles

Small on purpose: apps, a handful of aliases, and diff-so-fancy that doesn't break dev containers.

## New Mac

1. Install [Homebrew](https://brew.sh), clone this repo to `~/Source/dotfiles`, then:
   ```sh
   brew bundle --file=~/Source/dotfiles/Brewfile
   ```
2. Install [oh-my-zsh](https://ohmyz.sh) — used for the prompt, history, completion and
   directory shortcuts only, no plugins.
3. Replace `~/.zshrc` with:
   ```zsh
   export ZSH="$HOME/.oh-my-zsh"
   ZSH_THEME="robbyrussell"
   plugins=()
   zstyle ':omz:update' mode disabled   # update manually: omz update
   source $ZSH/oh-my-zsh.sh

   source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
   source <(fzf --zsh)
   eval "$(mise activate zsh)"

   # Shared aliases — after oh-my-zsh so these win
   source ~/Source/dotfiles/aliases.sh
   ```
   Machine-specific exports and tokens go below, never in this repo.
4. Run:
   ```sh
   ~/Source/dotfiles/install.sh
   ```
   This sources `aliases.sh` from `~/.bashrc` (and `~/.zshrc` if missing), writes
   `~/.gitconfig.local` with the diff-so-fancy pager, and adds an include of it to
   `~/.gitconfig`.
5. Node and other runtimes via mise:
   ```sh
   mise use -g node@lts
   mise settings add idiomatic_version_file_enable_tools node   # respect .nvmrc
   ```
   Per project: `mise use java@temurin-17`, `mise use ruby@3.3`, …
6. Caps Lock → Esc: System Settings → Keyboard → Keyboard Shortcuts… → Modifier Keys.
7. Ghostty (`~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`):
   ```
   shell-integration-features = ssh-terminfo,ssh-env
   copy-on-select = clipboard
   ```

## Aliases

| Alias | Command |
|---|---|
| `gst` | `git status` |
| `gl` | `git pull` |
| `gf` | `git fetch` |
| `gb` | `git branch` |
| `glog` | `git log --oneline --decorate --graph` |
| `gcm` | `git checkout` main / trunk / master |
| `ga` | `git add` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` |
| `gp` | `git push` |
| `gcmsg` | `git commit -m` |
| `la` | `ls -lAh` |

## Dev containers

VS Code settings:
```json
"dotfiles.repository": "lassebn/dotfiles",
"dotfiles.installCommand": "install.sh"
```
(`devcontainer` CLI: `--dotfiles-repository https://github.com/lassebn/dotfiles`.)

Each container then gets the aliases. diff-so-fancy is cloned into `~/.local` when
the image has `perl` and `less`; otherwise git keeps its default pager — no errors.

## Why the gitconfig split

VS Code copies `~/.gitconfig` into containers. The pager setting lives in
`~/.gitconfig.local` instead, which is written per machine by `install.sh` and only
when diff-so-fancy actually works there. Git silently ignores a missing include.

## Keep secrets out

This repo is public. Tokens stay in the machine's own `~/.zshrc` or in 1Password.
