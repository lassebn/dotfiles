#!/bin/sh
# Sets up shell aliases and (when possible) diff-so-fancy.
# Runs on the Mac and automatically in dev containers via the
# dotfiles.repository setting. Best effort: never fails the container setup.

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_LINE=". \"$DOTFILES_DIR/aliases.sh\""

log() { echo "[dotfiles] $*"; }

# --- Shell aliases ---------------------------------------------------------
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  case "$rc" in
    *zshrc) command -v zsh >/dev/null 2>&1 || continue ;;
  esac
  if ! grep -qF "dotfiles/aliases.sh" "$rc" 2>/dev/null; then
    printf '\n# dotfiles\n%s\n' "$SOURCE_LINE" >> "$rc"
    log "added aliases to $rc"
  fi
done

# --- diff-so-fancy -----------------------------------------------------------
# On the Mac it comes from Homebrew. Elsewhere, install it from GitHub into
# ~/.local (needs only git + perl, no root and no package manager).
DSF_DIR="$HOME/.local/share/diff-so-fancy"
if ! command -v diff-so-fancy >/dev/null 2>&1; then
  if command -v perl >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
    if [ ! -d "$DSF_DIR" ]; then
      git clone -q --depth 1 https://github.com/so-fancy/diff-so-fancy.git "$DSF_DIR" 2>/dev/null \
        || log "could not clone diff-so-fancy"
    fi
    if [ -x "$DSF_DIR/diff-so-fancy" ]; then
      mkdir -p "$HOME/.local/bin"
      ln -sf "$DSF_DIR/diff-so-fancy" "$HOME/.local/bin/diff-so-fancy"
    fi
  else
    log "perl or git missing, skipping diff-so-fancy"
  fi
fi

# Only point git at diff-so-fancy if it actually runs here. Otherwise leave
# ~/.gitconfig.local absent and git uses its default pager.
DSF_BIN="$(command -v diff-so-fancy 2>/dev/null || true)"
[ -z "$DSF_BIN" ] && [ -x "$HOME/.local/bin/diff-so-fancy" ] && DSF_BIN="$HOME/.local/bin/diff-so-fancy"
if [ -n "$DSF_BIN" ] && command -v less >/dev/null 2>&1 \
  && printf '' | "$DSF_BIN" >/dev/null 2>&1; then
  cat > "$HOME/.gitconfig.local" <<EOF
# Written by dotfiles/install.sh — machine-specific, not synced.
[core]
	pager = "$DSF_BIN" | less --tabs=4 -RFX
[interactive]
	diffFilter = "$DSF_BIN" --patch
EOF
  log "diff-so-fancy enabled ($DSF_BIN)"
else
  rm -f "$HOME/.gitconfig.local"
  log "diff-so-fancy not available, using git's default pager"
fi

# ~/.gitconfig includes the local file; a missing include is silently ignored.
if command -v git >/dev/null 2>&1 \
  && ! git config --global --get-all include.path 2>/dev/null | grep -qx '~/.gitconfig.local'; then
  git config --global --add include.path '~/.gitconfig.local'
  log "added include of ~/.gitconfig.local to ~/.gitconfig"
fi

# --- Global git ignore -------------------------------------------------------
# Personal mise config stays out of every repo.
IGNORE_FILE="$(git config --global core.excludesfile 2>/dev/null || true)"
[ -z "$IGNORE_FILE" ] && IGNORE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/git/ignore"
case "$IGNORE_FILE" in "~/"*) IGNORE_FILE="$HOME/${IGNORE_FILE#\~/}" ;; esac
mkdir -p "$(dirname "$IGNORE_FILE")"
if ! grep -qxF 'mise.local.toml' "$IGNORE_FILE" 2>/dev/null; then
  echo 'mise.local.toml' >> "$IGNORE_FILE"
  log "added mise.local.toml to $IGNORE_FILE"
fi

exit 0
