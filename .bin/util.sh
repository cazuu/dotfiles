# is_exists returns true if executable $1 exists in $PATH
is_exists() {
    which "$1" >/dev/null 2>&1
    return $?
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