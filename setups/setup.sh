#!/usr/bin/env bash

# setup.sh - Install zsh, set it as default shell, install oh-my-zsh, zsh-syntax-highlighting, zsh-autosuggestions, Python UV, use UV to install dotbot, install/update Neovim to latest version, and install fzf

set -e

# Constants
readonly SCRIPT_NAME="Setup Script (ZSH + Oh-My-Zsh + ZSH-Syntax-Highlighting + ZSH-Autosuggestions + UV + Dotbot + Neovim[latest] + fzf)"
readonly UV_INSTALL_URL="https://astral.sh/uv/install.sh"
readonly OH_MY_ZSH_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
readonly ZSH_HIGHLIGHTING_URL="https://github.com/zsh-users/zsh-syntax-highlighting.git"
readonly ZSH_AUTOSUGGESTIONS_URL="https://github.com/zsh-users/zsh-autosuggestions.git"

# Helper functions
command_exists() { command -v "$1" >/dev/null 2>&1; }
log() { echo "[$(date '+%H:%M:%S')] $*"; }
error() { echo "[ERROR] $*" >&2; }
success() { echo "[SUCCESS] $*"; }

# OS detection and package management
detect_os() {
    case "$OSTYPE" in
        linux-gnu*)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                echo "$ID"
            else
                echo "linux"
            fi
            ;;
        darwin*) echo "macos" ;;
        *) echo "unknown" ;;
    esac
}

get_install_cmd() {
    case "$1" in
        ubuntu|debian) echo "sudo apt" ;;
        fedora) echo "sudo dnf" ;;
        arch|manjaro) echo "sudo pacman" ;;
        opensuse*) echo "sudo zypper" ;;
        alpine) echo "sudo apk" ;;
        macos) echo "brew" ;;
        *) return 1 ;;
    esac
}

# Package installation with OS-specific handling
install_package() {
    local package="$1"
    local os="$2"
    local install_cmd

    install_cmd=$(get_install_cmd "$os") || {
        error "Unsupported OS: $os. Please install $package manually."
        return 1
    }

    case "$os" in
        macos)
            if ! command_exists brew; then
                error "Install Homebrew first: https://brew.sh"
                return 1
            fi
            brew install "$package"
            ;;
        *)
            log "start install cmd = $install_cmd"
            $install_cmd update >/dev/null 2>&1 || true
            $install_cmd install -y "$package"
            ;;
    esac
}

# Shell operations
set_default_shell() {
    local zsh_path="$1"
    local current_shell
    local os="$2"

    # Get current shell based on OS
    if [[ "$os" == "macos" ]]; then
        current_shell=$(dscl . -read "$HOME" UserShell | awk '{print $2}')
    else
        current_shell=$(getent passwd "$USER" | cut -d: -f7)
    fi

    if [[ "$current_shell" == "$zsh_path" ]]; then
        log "Zsh already default shell"
        return 0
    fi

    log "Setting zsh as default shell..."

    # Add zsh to /etc/shells if not present (Linux only, macOS handles this automatically)
    if [[ "$os" != "macos" ]]; then
        grep -qx "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    chsh -s "$zsh_path"
    success "Default shell changed. Please log out/in to apply."
}

# UV and dotbot installation
install_uv() {
    log "Installing UV..."
    curl -LsSf "$UV_INSTALL_URL" | sh
    export PATH="$HOME/.cargo/bin:$PATH"

    if command_exists uv; then
        success "UV installed"
    else
        error "UV install failed"
        return 1
    fi
}

install_dotbot() {
    log "Installing dotbot via UV..."
    export PATH="$HOME/.cargo/bin:$PATH"

    if ! command_exists uv; then
        error "UV not found"
        return 1
    fi

    if uv tool install dotbot; then
        success "Dotbot installed"
        command_exists dotbot && dotbot --version
    else
        error "Dotbot install failed"
        return 1
    fi
}

# Zsh plugin installation
install_zsh_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local plugins_dir="$zsh_custom/plugins"
    local plugin_path="$plugins_dir/$plugin_name"

    if [ -d "$plugin_path" ]; then
        log "$plugin_name already installed"
        return 0
    fi

    log "Installing $plugin_name..."
    mkdir -p "$plugins_dir"
    git clone "$plugin_url" "$plugin_path"

    if [ -d "$plugin_path" ]; then
        success "$plugin_name installed"
        log "To enable it, add '$plugin_name' to your plugins in ~/.zshrc"
    else
        error "$plugin_name installation failed"
        return 1
    fi
}

install_oh_my_zsh() {
    log "Installing oh-my-zsh..."

    if [ -d "$HOME/.oh-my-zsh" ]; then
        log "oh-my-zsh already installed"
        return 0
    fi

    sh -c "$(curl -fsSL "$OH_MY_ZSH_URL")" "" --unattended

    if [ -d "$HOME/.oh-my-zsh" ]; then
        success "oh-my-zsh installed"
    else
        error "oh-my-zsh installation failed"
        return 1
    fi
}

# Neovim version management
get_neovim_version() {
    local version_type="$1"
    local os="$2"
    local install_cmd

    install_cmd=$(get_install_cmd "$os") || return 1

    case "$os" in
        ubuntu|debian)
            $install_cmd update >/dev/null 2>&1 || true
            if [ "$version_type" = "latest" ]; then
                $install_cmd list --upgradable 2>/dev/null | grep "^neovim/" | awk '{print $2}' | head -n1
            else
                nvim --version 2>/dev/null | head -n1 | sed -E 's/NVIM v([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
            fi
            ;;
        fedora)
            if [ "$version_type" = "latest" ]; then
                $install_cmd list neovim 2>/dev/null | grep -A1 "^Available Packages" | tail -n1 | awk '{print $2}'
            else
                nvim --version 2>/dev/null | head -n1 | sed -E 's/NVIM v([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
            fi
            ;;
        arch|manjaro)
            if [ "$version_type" = "latest" ]; then
                $install_cmd -Si neovim 2>/dev/null | grep "Version" | awk '{print $3}' | cut -d'-' -f1
            else
                nvim --version 2>/dev/null | head -n1 | sed -E 's/NVIM v([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
            fi
            ;;
        macos)
            if [ "$version_type" = "latest" ]; then
                brew info neovim 2>/dev/null | grep "stable" | awk '{print $3}' | tr -d '()'
            else
                nvim --version 2>/dev/null | head -n1 | sed -E 's/NVIM v([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
            fi
            ;;
    esac
}

install_neovim() {
    local os="$1"

    log "Installing Neovim..."

    case "$os" in
        ubuntu|debian)
            sudo add-apt-repository -y ppa:neovim-ppa/unstable 2>/dev/null || true
            ;;
    esac

    install_package "neovim" "$os" || return 1

    if command_exists nvim; then
        success "Neovim installed"
        nvim --version | head -n1
    else
        error "Neovim installation failed"
        return 1
    fi
}

update_neovim_if_needed() {
    local os="$1"

    if ! command_exists nvim; then
        log "Neovim not installed, skipping update check"
        return 0
    fi

    log "Checking Neovim version..."

    local current_version=$(get_neovim_version current "$os")
    local latest_version=$(get_neovim_version latest "$os")

    if [ -z "$current_version" ] || [ -z "$latest_version" ]; then
        error "Could not determine Neovim versions"
        return 1
    fi

    # Clean version numbers
    current_version=$(echo "$current_version" | sed -E 's/^[0-9]+://' | sed -E 's/[-~].*$//' | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
    latest_version=$(echo "$latest_version" | sed -E 's/^[0-9]+://' | sed -E 's/[-~].*$//' | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')

    log "Current Neovim version: v$current_version"
    log "Latest Neovim version: v$latest_version"

    if [ "$current_version" = "$latest_version" ]; then
        success "Neovim is already up to date!"
        return 0
    fi

    log "Updating Neovim from v$current_version to v$latest_version..."

    case "$os" in
        ubuntu|debian|fedora|opensuse*|alpine)
            install_package "neovim" "$os" || return 1
            ;;
        arch|manjaro)
            sudo pacman -Syu --noconfirm neovim
            ;;
        macos)
            brew upgrade neovim
            ;;
    esac

    local new_version=$(get_neovim_version current "$os")
    if [ "$new_version" = "$latest_version" ]; then
        success "Neovim updated successfully to v$new_version!"
        nvim --version | head -n1
    else
        error "Neovim update may have failed. Current version: v$new_version"
        return 1
    fi
}

# fzf installation
install_fzf() {
    local fzf_dir="$HOME/.fzf"

    log "Installing fzf via git..."

    if [ -d "$fzf_dir" ]; then
        log "fzf directory already exists at $fzf_dir"
        log "Updating fzf..."
        (cd "$fzf_dir" && git pull)
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
    fi

    if [ -f "$fzf_dir/install" ]; then
        log "Running fzf install script..."
        yes | "$fzf_dir/install" --key-bindings --completion --no-update-rc
    fi

    if ! command_exists fzf && [ -f "$fzf_dir/bin/fzf" ]; then
        export PATH="$fzf_dir/bin:$PATH"
        echo 'export PATH="$HOME/.fzf/bin:$PATH"' >> ~/.zshrc
        echo 'export PATH="$HOME/.fzf/bin:$PATH"' >> ~/.bashrc
    fi

    local shell_rc="$HOME/.zshrc"
    [ -n "$BASH_VERSION" ] && shell_rc="$HOME/.bashrc"

    if ! grep -q "fzf/shell/key-bindings" "$shell_rc" 2>/dev/null; then
        echo '[ -f ~/.fzf/shell/key-bindings.zsh ] && source ~/.fzf/shell/key-bindings.zsh' >> "$shell_rc"
        echo '[ -f ~/.fzf/shell/completion.zsh ] && source ~/.fzf/shell/completion.zsh' >> "$shell_rc"
    fi

    if command_exists fzf || [ -f "$fzf_dir/bin/fzf" ]; then
        success "fzf installed"
        command_exists fzf && fzf --version | head -n1 || "$fzf_dir/bin/fzf" --version | head -n1
    else
        error "fzf installation failed"
        return 1
    fi
}

# Main execution
main() {
    log "=== $SCRIPT_NAME ==="

    local os=$(detect_os)
    log "Detected OS: $os"

    # Install/check zsh
    if command_exists zsh; then
        log "Zsh already installed"
    else
        log "Installing zsh..."
        install_package "zsh" "$os" || exit 1
        log "Zsh installed at: $(command -v zsh)"
    fi

    set_default_shell "$(command -v zsh)" "$os"

    # Install UV if needed
    if ! command_exists uv && ! install_uv; then
        error "Warning: UV install failed"
    fi

    # Install dotbot if UV available
    if command_exists uv; then
        install_dotbot
    else
        log "UV not available, skipping dotbot"
    fi

    # Install oh-my-zsh and plugins
    install_oh_my_zsh
    install_zsh_plugin "zsh-syntax-highlighting" "$ZSH_HIGHLIGHTING_URL"
    install_zsh_plugin "zsh-autosuggestions" "$ZSH_AUTOSUGGESTIONS_URL"

    # Install/update Neovim
    if command_exists nvim; then
        log "Neovim already installed"
        update_neovim_if_needed "$os" || error "Warning: Neovim update check failed"
    else
        log "Installing Neovim..."
        install_neovim "$os" || error "Warning: Neovim install failed"
        if command_exists nvim; then
            update_neovim_if_needed "$os" || error "Warning: Neovim update check failed"
        fi
    fi

    # Install fzf
    if ! command_exists fzf; then
        log "Installing fzf..."
        install_fzf || error "Warning: fzf install failed"
    else
        log "fzf already installed"
    fi

    echo
    success "=== Setup complete! ==="
    log "1. Log out/in for shell changes"
    command_exists dotbot && log "2. Run 'dotbot' to configure dotfiles"
    command_exists nvim && log "3. Neovim is ready to use!"
    command_exists fzf && log "4. fzf is ready to use!"
}

main "$@"
