
  \n\n*Run this pick command in the branch where your commits exist, then SWITCH to your target branch and run the run cherry-pick command you copied.

  \n\nFor exemplification: \n\n > pick STW-142845

  "

  return;

  fi



  echo "\n" && git --no-pager log --reverse --grep "$1" --pretty=format:'commit: %C(yellow)%h%n%n%Creset%C(cyan) %s%n %Cresetby %an <%ae>%n on %ad%n Get help %Creset%C(green)Rakesh<rak3sh.shrestha@gmail.com> %Creset%n' && echo "\nNow, SWITCH to your target branch and copy/paste this command but verify it once with the above commits : \n" && echo "git cherry-pick -n " | tr -d '\n' | tee && git log --reverse --grep=$1 --pretty=format:'%h' | tr '\n' ' ' | tee && echo '\r'

}

# Only changing the escape key to `jk` in insert mode, we still
# keep using the default keybindings `^[` in other modes
ZVM_VI_INSERT_BINDKEY=jj


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use default


# Load Angular CLI autocompletion.
#source <(ng completion script)


# Herd injected PHP binary.
export PATH="/Users/rakeshshrestha/Library/Application Support/Herd/bin/":$PATH


# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/rakeshshrestha/Library/Application Support/Herd/config/php/82/"


# Herd injected PHP 7.4 configuration.
export HERD_PHP_74_INI_SCAN_DIR="/Users/rakeshshrestha/Library/Application Support/Herd/config/php/74/"

eval "$(zoxide init zsh)"