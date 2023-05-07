#!/usr/bin/env bash
# MIT (c) Wenxuan Zhang

forgit::error() { printf "%b[Error]%b %s\n" '\e[0;31m' '\e[0m' "$@" >&2; return 1; }
forgit::warn() { printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$@" >&2; }

# determine installation path
if [[ -n "$ZSH_VERSION" ]]; then
    # shellcheck disable=2277,2296,2299
    0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
    # shellcheck disable=2277,2296,2298
    0="${${(M)0:#/*}:-$PWD/$0}"
    INSTALL_DIR="${0:h}"
elif [[ -n "$BASH_VERSION" ]]; then
    INSTALL_DIR="$(dirname -- "${BASH_SOURCE[0]}")"
else
    forgit::error "Only zsh and bash are supported"
fi
FORGIT="$INSTALL_DIR/bin/git-forgit"

# backwards compatibility:
# export all user-defined FORGIT variables to make them available in git-forgit
unexported_vars=0
# Set posix mode in bash to only get variables, see #256.
[[ -n "$BASH_VERSION" ]] && set -o posix
set | awk -F '=' '{ print $1 }' | grep FORGIT_ | while read -r var; do
    if ! export | grep -q "\(^$var=\|^export $var=\)"; then
        if [[ $unexported_vars == 0 ]]; then
            forgit::warn "Config options have to be exported in future versions of forgit."
            forgit::warn "Please update your config accordingly:"
        fi
        forgit::warn "  export $var"
        unexported_vars=$((unexported_vars + 1))
        # shellcheck disable=SC2163
        export "$var"
    fi
done
[[ -n "$BASH_VERSION" ]] && set +o posix

# register shell functions
forgit::log() {
    "$FORGIT" log "$@"
}

forgit::diff() {
    "$FORGIT" diff "$@"
}

forgit::add() {
    "$FORGIT" add "$@"
}

forgit::reset::head() {
    "$FORGIT" reset_head "$@"
}

forgit::stash::show() {
    "$FORGIT" stash_show "$@"
}

forgit::stash::push() {
    "$FORGIT" stash_push "$@"
}

forgit::clean() {
    "$FORGIT" clean "$@"
}

forgit::cherry::pick() {
    "$FORGIT" cherry_pick "$@"
}

forgit::cherry::pick::from::branch() {
    "$FORGIT" cherry_pick_from_branch "$@"
}

forgit::rebase() {
    "$FORGIT" rebase "$@"
}

forgit::fixup() {
    "$FORGIT" fixup "$@"
}

forgit::checkout::file() {
    "$FORGIT" checkout_file "$@"
}

forgit::checkout::branch() {
    "$FORGIT" checkout_branch "$@"
}

forgit::checkout::tag() {
    "$FORGIT" checkout_tag "$@"
}

forgit::checkout::commit() {
    "$FORGIT" checkout_commit "$@"
}

forgit::branch::delete() {
    "$FORGIT" branch_delete "$@"
}

forgit::revert::commit() {
    "$FORGIT" revert_commit "$@"
}

forgit::blame() {
    "$FORGIT" blame "$@"
}

forgit::ignore() {
    "$FORGIT" ignore "$@"
}

forgit::ignore::update() {
    "$FORGIT" ignore_update "$@"
}

forgit::ignore::get() {
    "$FORGIT" ignore_get "$@"
}

forgit::ignore::list() {
    "$FORGIT" ignore_list "$@"
}

forgit::ignore::clean() {
    "$FORGIT" ignore_clean "$@"
}
# Git fzf addons zsh
alias git-add='forgit::add'
alias git-reset_head='forgit::reset::head '
alias git-log='forgit::log'
alias git-diff='forgit::diff'
alias git-ignore='forgit::ignore'
alias git-checkout_file='forgit::checkout::file'
alias git-checkout_branch='forgit::checkout::branch'
alias git-checkout_commit='forgit::checkout::commit'
alias git-checkout_tag='forgit::checkout::tag'
alias git-branch_delete='forgit::branch::delete'
alias git-revert_commit='forgit::revert::commit'
alias git-clean='forgit::clean'
alias git-stash_show='forgit::stash::show'
alias git-stash_push='forgit::stash::push'
alias git-cherry_pick='forgit::cherry::pick::from::branch'
alias git-rebase='forgit::rebase'
alias git-fixup='forgit::fixup'
alias git-blame='forgit::blame'