HISTFILE=~/.zsh_history

# How many commands zsh will load to memory.
export HISTSIZE=10000

# How many commands history will save on file.
export SAVEHIST=10000

# History won't save duplicates.
setopt HIST_IGNORE_ALL_DUPS

# History won't show duplicates on search.
setopt HIST_FIND_NO_DUPS

export PS1="%{$(tput setaf 121)%}%n%{$(tput setaf 121)%}@%{$(tput setaf 121)%}%m %{$(tput setaf 32)%}%~ %{$(tput sgr0)%}$ "

alias ls='ls --color=auto'
alias ll='ls -l'
alias lla='ls -la'

source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-completions/zsh-completions.plugin.zsh

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
