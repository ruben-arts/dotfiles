cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# FASD
fasd_cache="$HOME/.fasd-init-bash"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

# Trueline PS1
declare -a TRUELINE_SEGMENTS=(
	'user,black,white,bold'
        'venv,black,purple,bold'
        'git,grey,special_grey,normal'
        'working_dir,mono,cursor_grey,normal'
        'read_only,black,orange,bold'
        'bg_jobs,black,orange,bold'
        'exit_status,black,red,bold'
        #'newline,black,orange,bold'
	'newline,white,black,bold'
)

source "$cur_dir/external/trueline/trueline.sh"

export PATH=$PATH:.dotfiles/scripts