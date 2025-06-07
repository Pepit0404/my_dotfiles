HISTFILE=~/.zsh_history

# How many commands zsh will load to memory.
export HISTSIZE=10000

# How many commands history will save on file.
export SAVEHIST=10000

# History won't save duplicates.
setopt HIST_IGNORE_ALL_DUPS

# History won't show duplicates on search.
setopt HIST_FIND_NO_DUPS

source ~/.zsh/git/git-prompt.sh

#export GIT_PS1_SHOWDIRTYSTATE=1
#export GIT_PS1_SHOWUNTRACKEDFILES=1
#export GIT_PS1_SHOWUPSTREAM="auto"

setopt prompt_subst

function set_git_prompt {
    local exit_code=$?  
  #PS1="%n@%m %~$(__git_ps1 ' (%s)') \$ "
  
    PS1="%{$(tput setaf 121)%}%n%{$(tput setaf 121)%}@%{$(tput setaf 121)%}%m %{$(tput setaf 32)%}%~$(__git_ps1)%{$(tput sgr0)%} $ "
    return $exit_code
}


autoload -Uz add-zsh-hook
add-zsh-hook precmd set_git_prompt

function update_terminal_title() {
  print -Pn "\e]0;%~\a"
}
add-zsh-hook precmd update_terminal_title


alias ls='ls --color=auto'
alias ll='ls -l'
alias lla='ls -la'

source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-completions/zsh-completions.plugin.zsh

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
