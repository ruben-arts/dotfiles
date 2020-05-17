cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Trueline PS1
declare -a TRUELINE_SEGMENTS=(
	'user,black,white,bold'
        'venv,black,purple,bold'
        'git,grey,special_grey,normal'
        'working_dir,mono,cursor_grey,normal'
        'read_only,black,orange,bold'
        'exit_status,black,red,bold'
        #'bg_jobs,black,orange,bold'
        
        #'newline,black,orange,bold'
	'newline,white,black,bold'
)

source "$cur_dir/external/trueline/trueline.sh"

export PATH=$PATH:~/.dotfiles/bin

# zoxide
eval "$(zoxide init bash)"

_zoxide_completion() {
    local cur prev words cword
    _init_completion || return
    COMPREPLY=()
    case $prev in
    -takes_file)
        _filedir
        return
        ;;
    esac
    case ${cur} in
    -*)
        COMPREPLY=($(compgen -W '
        -V --version
        -h --help
        -i --interactive
        ' -- "${cur}"; ))
        [[ COMPREPLY == *= ]] || compopt +o nospace
        ;;
    *)
        # set -x
        # COMPREPLY=($(compgen -W "$( zq  "${cur}" | awk '{ print $NF}' )" -- "${cur}") )
        COMPREPLY=($(compgen -W "$( zq  "${cur}" | awk '{ print $NF}' )
        "  ) )
        ;;

    esac
} && complete -F _zoxide_completion -o nospace z