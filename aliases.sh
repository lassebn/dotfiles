# Shell aliases shared between the Mac and dev containers.
# Plain POSIX-style so it works when sourced from both bash and zsh.

# Local installs (e.g. diff-so-fancy inside containers)
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Name of the default branch: main, trunk or master, whichever exists locally.
_dotfiles_main_branch() {
  for ref in main trunk master; do
    if git show-ref -q --verify "refs/heads/$ref"; then
      echo "$ref"
      return
    fi
  done
  echo main
}

# Git — oh-my-zsh aliases already in use
alias gst='git status'
alias gl='git pull'
alias glog='git log --oneline --decorate --graph'
alias gb='git branch'
alias gcm='git checkout "$(_dotfiles_main_branch)"'
alias gf='git fetch'

# Git — commands otherwise typed out in full
alias ga='git add'
alias gd='git diff'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gcmsg='git commit -m'

# Other oh-my-zsh aliases in use
alias la='ls -lAh'
