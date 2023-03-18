if [[ `uname -r` == *WSL* ]];then
	host_ip=`cat /etc/resolv.conf | grep nameserver | awk '{print $2}'`
	export all_proxy="http://$host_ip:7890"
	export http_proxy=$all_proxy
	export https_proxy=$all_proxy
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="ys"

zstyle ':omz:update' mode disabled  # disable automatic updates

plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

which yarnpkg > /dev/null && alias yarn=yarnpkg
which nvim > /dev/null && alias vim=nvim
which google-chrome > /dev/null && alias chrome=google-chrome
which yarn > /dev/null && export PATH=`yarn global bin`:$PATH
ls $HOME/.cargo/env > /dev/null && . "$HOME/.cargo/env"

