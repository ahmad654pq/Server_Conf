open() {
  xdg-open "$(fd -H -t f | fzf)"
}

y() {
    local lastdir
    lastdir=$(tr -d '%\r' < ~/.local/share/yazi/lastdir | xargs)
    yazi --cwd-file ~/.local/share/yazi/lastdir "$lastdir"
}

size_total() {
  local ignore_file="" dirs=() human=true
  while (( $# )); do
    case "$1" in -i) shift; ignore_file="$1" ;;
                 -d) shift; dirs+=("$1") ;;
                 -h) human=true ;;
                 -b) human=false ;;
                 *)  dirs+=("$1") ;; esac; shift
  done
  [[ ${#dirs[@]} -eq 0 ]] && dirs=(.)
  local find_prune=()
  if [[ -f "$ignore_file" ]]; then
    while IFS= read -r pat || [[ -n $pat ]]; do
      [[ -z "$pat" || "$pat" =~ ^# ]] && continue
      [[ "$pat" == */ ]] && find_prune+=(-type d -name "${pat%/}" -prune -o) ||
                           find_prune+=(-type f -name "$pat" -prune -o)
    done < "$ignore_file"
  fi
  local du_flags=( -c ); $human && du_flags+=( -h ); ! $human && du_flags+=( -b )
  find "${dirs[@]}" "${find_prune[@]}" -type f -print0 |
    xargs -0 du "${du_flags[@]}" | tail -1 | cut -f1
}

tp() {
  cd "$(fd -H -t d -E .git -E go -E .cache \
    -E .vscode -E .cargo -E .npm -E node_modules \
    -E __pycache__ -E .pytest_cache -E .venv \
    -E .config/vivaldi -E .local/state \
    -E .pi -E .nv -E .claude \
    -E venv -E '*.pyc' -E .codex | fzf)";
}


# tp() {
#   local dir
#
#   dir="$(
#     {
#       # All normal non-hidden directories
#       fd -t d
#
#       # Only these hidden locations are allowed
#       fd -H -t d . ".config/waybar"
#       fd -H -t d . ".config/cliamp"
#       fd -H -t d . ".config/kitty"
#       fd -H -t d . ".config/nvim"
#       fd -H -t d . ".config/rofi"
#       fd -H -t d . ".config/mako"
#       fd -H -t d . ".config/hypr"
#       fd -H -t d . ".config/walker"
#       fd -H -t d . ".config/yazi"
#       fd -H -t d . ".local/share"
#       fd -H -t d . ".local/bin"
#     } | sort -u | fzf
#   )"
#
#   [[ -n "$dir" ]] && cd "$dir"
# }


getdpath() {
  fd -H -t d -E .git -E go -E .vscode -E .cargo -E .npm -E node_modules -E __pycache__ -E .pytest_cache -E .venv -E venv -E '*.pyc' | fzf | xargs realpath | tr -d '\n' | wl-copy
}
getfpath() {
    fd -H -t f | fzf | xargs realpath | tr -d '\n' | wl-copy
}

