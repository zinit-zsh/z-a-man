# According to the Zsh Plugin Standard:
# http://zdharma.org/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html

0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

typeset -g ZMAN_REPO_DIR="${0:h}"
typeset -g ZMAN_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/z-a-zman"

# A simple wrapper around `zman' script to avoid altering PATH
zman() {
    "$ZMAN_REPO_DIR/zman" "$ZMAN_REPO_DIR" \
        "${ZPLGM[PLUGINS_DIR]}" \
        "${ZPLGM[SNIPPETS_DIR]}" "$@";
}

autoload -Uz :zp-zman-handler

# Prints one of two possible messages during installation
# adding colors to them and preceding with z-a-man preable
zman-inst() {
    if [[ "$1" = g ]]; then
        print -P -- "\n%F{38}zman annex: \%F{154}Installing %F{220}$2%F{154} gem locally in the z-a-man directory...%f"
    else
        print -P -- "\n%F{38}zman annex: \%F{154}$2%f"
    fi
}

# Check if ronn dependencies are installed
local zman_dep
local -a farray
for zman_dep in hpricot rdiscount mustache asciidoctor; do
    farray=( $ZMAN_REPO_DIR/gems/$zman_dep-*(N[1]) )
    [[ ! -d ${farray[1]} ]] && \
        { zman-inst g "$zman_dep"; command gem install --no-user-install -i "$ZMAN_REPO_DIR" "$zman_dep"; }
done

if [[ ! -f $ZMAN_REPO_DIR/bin/zsd ]]; then
    zman-inst o "Installing zshelldoc..."
    make -C $ZMAN_REPO_DIR/zshelldoc install PREFIX="$ZMAN_REPO_DIR" >/dev/null
fi

unset -f zman-inst

# An empty stub to fill the help handler fields
:za-man-help-null-handler() { :; }

# Register atclone hook
@zplg-register-annex "z-a-man" hook:atclone \
    :zp-zman-handler \
    :za-man-help-null-handler \
    "zman''" # register a new ice-mod: zman''

# Register atpull hook
@zplg-register-annex "z-a-man" hook:atpull \
    :zp-zman-handler \
    :za-man-help-null-handler

zstyle ':completion:*:zman:argument-rest:plugins' list-colors '=(#b)(*)/(*)==1;35=1;33'
zstyle ':completion:*:zman:argument-rest:plugins' matcher 'r:|=** l:|=*'
