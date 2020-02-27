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

export PATH=$PATH:~/.dotfiles/scripts

# FASD
{ if [ "$ZSH_VERSION" ] && compctl; then # zsh
    eval "$(fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \
      zsh-wcomp zsh-wcomp-install)"
  elif [ "$BASH_VERSION" ] && complete; then # bash
    eval "$(fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install)"
  else # posix shell
    eval "$(fasd --init posix-alias posix-hook)"
  fi
} >> "/dev/null" 2>&1