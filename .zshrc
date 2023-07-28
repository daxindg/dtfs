if [[ `uname -r` == *WSL* ]];then
	host_ip=`cat /etc/resolv.conf | grep nameserver | awk '{print $2}'`
	export all_proxy="http://$host_ip:7890"
	export http_proxy=$all_proxy
	export https_proxy=$all_proxy
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="ys"

zstyle ':omz:update' mode disabled  # disable automatic updates

plugins=(
	git
	zsh-syntax-highlighting
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

bindkey '^ ' autosuggest-accept

which yarnpkg > /dev/null && alias yarn=yarnpkg
which nvim > /dev/null && alias vim="env nvim"
which google-chrome > /dev/null && alias chrome=google-chrome
which yarn > /dev/null && export PATH=`yarn global bin`:$PATH
which /opt/homebrew/bin/brew > /dev/null && eval `/opt/homebrew/bin/brew shellenv`

ls $HOME/.cargo/env > /dev/null && . "$HOME/.cargo/env"

# pci passthrough
rebind() {
    dev="$1"
    driver="$2"

    # Unbind
    if [ -e /sys/bus/pci/devices/$dev/driver ]; then
        echo $dev | sudo tee /sys/bus/pci/devices/$dev/driver/unbind
    fi

    # Bind
    # if [ "$driver" = "vfio-pci" ]; then
    #     vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
    #     device=$(cat /sys/bus/pci/devices/$dev/device)
    #     echo $vendor $device | sudo tee /sys/bus/pci/drivers/$driver/new_id
    # else
    #     echo $dev | sudo tee /sys/bus/pci/drivers/$driver/bind
    # fi
    echo $driver | sudo tee /sys/bus/pci/devices/$dev/driver_override
    echo $dev | sudo tee /sys/bus/pci/drivers_probe
}

nvvga=0000:01:00.0
nvaudio=0000:01:00.1

passnv() {
    rebind $nvvga vfio-pci
    rebind $nvaudio vfio-pci
}

dpassnv() {
    rebind $nvvga nvidia
    rebind $nvaudio snd_hda_intel
}
