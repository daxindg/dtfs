#!/usr/bin/env bash

# setup.sh - Install zsh, set it as default shell, install oh-my-zsh, zsh-syntax-highlighting, zsh-autosuggestions, Python UV, use UV to install dotbot, install Neovim, and install fzf

set -e

# Constants
readonly SCRIPT_NAME="Setup Script (ZSH + Oh-My-Zsh + ZSH-Syntax-Highlighting + ZSH-Autosuggestions + UV + Dotbot + Neovim + fzf)"
readonly UV_INSTALL_URL="https://astral.sh/uv/install.sh"
readonly OH_MY_ZSH_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
readonly ZSH_HIGHLIGHTING_URL="https://github.com/zsh-users/zsh-syntax-highlighting.git"
readonly ZSH_AUTOSUGGESTIONS_URL="https://github.com/zsh-users/zsh-autosuggestions.git"

# Helper functions
command_exists() { command -v "$1" >/dev/null 2>&1; }

log() { echo "[$(date '+%H:%M:%S')] $*"; }
error() { echo "[ERROR] $*" >&2; }
success() { echo "[SUCCESS] $*"; }

# OS detection
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

# Package manager mapping
get_install_cmd() {
    local os="$1"

    case "$os" in
        ubuntu|debian) echo "sudo apt" ;;
        fedora) echo "sudo dnf" ;;
        arch|manjaro) echo "sudo pacman" ;;
        opensuse*) echo "sudo zypper" ;;
        alpine) echo "sudo apk" ;;
        macos) echo "brew" ;;
        *) return 1 ;;
    esac
}

# Install zsh
install_zsh() {
    local os="$1"
    local install_cmd

    install_cmd=$(get_install_cmd "$os") || {
        error "Unsupported OS: $os. Please install zsh manually."
        return 1
    }

    case "$os" in
        macos)
            if ! command_exists brew; then
                error "Install Homebrew first: https://brew.sh"
                return 1
            fi
            brew install zsh
            ;;
        *)
            $install_cmd update >/dev/null 2>&1 || true
            $install_cmd install -y zsh
            ;;
    esac

    success "Zsh installed"
}

# Set zsh as default shell
set_default_shell() {
    local zsh_path="$1"
    local current_shell

    current_shell=$(getent passwd "$USER" | cut -d: -f7)

    if [[ "$current_shell" == "$zsh_path" ]]; then
        log "Zsh already default shell"
        return 0
    fi

    log "Setting zsh as default shell..."
    grep -qx "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$zsh_path"
    success "Default shell changed. Please log out/in to apply."
}

# Install UV
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

# Install dotbot via UV
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

# Install oh-my-zsh
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

# Install zsh-syntax-highlighting
install_zsh_syntax_highlighting() {
    log "Installing zsh-syntax-highlighting..."

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local plugins_dir="$zsh_custom/plugins"
    local plugin_path="$plugins_dir/zsh-syntax-highlighting"

    if [ -d "$plugin_path" ]; then
        log "zsh-syntax-highlighting already installed"
        return 0
    fi

    mkdir -p "$plugins_dir"
    git clone "$ZSH_HIGHLIGHTING_URL" "$plugin_path"

    if [ -d "$plugin_path" ]; then
        success "zsh-syntax-highlighting installed"
        log "To enable it, add 'zsh-syntax-highlighting' to your plugins in ~/.zshrc"
    else
        error "zsh-syntax-highlighting installation failed"
        return 1
    fi
}

# Install zsh-autosuggestions
install_zsh_autosuggestions() {
    log "Installing zsh-autosuggestions..."

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local plugins_dir="$zsh_custom/plugins"
    local plugin_path="$plugins_dir/zsh-autosuggestions"

    if [ -d "$plugin_path" ]; then
        log "zsh-autosuggestions already installed"
        return 0
    fi

    mkdir -p "$plugins_dir"
    git clone "$ZSH_AUTOSUGGESTIONS_URL" "$plugin_path"

    if [ -d "$plugin_path" ]; then
        success "zsh-autosuggestions installed"
        log "To enable it, add 'zsh-autosuggestions' to your plugins in ~/.zshrc"
    else
        error "zsh-autosuggestions installation failed"
        return 1
    fi
}

# Install Neovim
install_neovim() {
    local os="$1"
    local install_cmd

    install_cmd=$(get_install_cmd "$os") || {
        error "Unsupported OS: $os. Please install Neovim manually."
        return 1
    }

    log "Installing Neovim..."

    case "$os" in
        ubuntu|debian)
            # Add Neovim PPA for unstable version (latest features)
            sudo add-apt-repository -y ppa:neovim-ppa/unstable 2>/dev/null || true
            $install_cmd update >/dev/null 2>&1 || true
            $install_cmd install -y neovim
            ;;
        fedora)
            $install_cmd install -y neovim
            ;;
        arch|manjaro)
            $install_cmd -S --noconfirm neovim
            ;;
        opensuse*)
            $install_cmd install -y neovim
            ;;
        alpine)
            $install_cmd add neovim
            ;;
        macos)
            if ! command_exists brew; then
                error "Install Homebrew first: https://brew.sh"
                return 1
            fi
            brew install neovim
            ;;
        *)
            error "Neovim installation not configured for OS: $os"
            return 1
            ;;
    esac

    if command_exists nvim; then
        success "Neovim installed"
        nvim --version | head -n1
    else
        error "Neovim installation failed"
        return 1
    fi
}

# Install fzf
install_fzf() {
    local fzf_dir="$HOME/.fzf"

    log "Installing fzf via git..."

    # Check if fzf is already installed via git
    if [ -d "$fzf_dir" ]; then
        log "fzf directory already exists at $fzf_dir"
        # Update existing installation
        log "Updating fzf..."
        (cd "$fzf_dir" && git pull)
    else
        # Clone fzf repository
        git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
    fi

    # Run the install script
    if [ -f "$fzf_dir/install" ]; then
        log "Running fzf install script..."
        # Install with key bindings and completion, but no update-rc
        yes | "$fzf_dir/install" --key-bindings --completion --no-update-rc
    fi

    # Add fzf to PATH if not already there
    if ! command_exists fzf; then
        # Check if fzf binary exists in the expected location
        if [ -f "$fzf_dir/bin/fzf" ]; then
            # Add to PATH for current session
            export PATH="$fzf_dir/bin:$PATH"
            # Add to shell configuration for future sessions
            echo 'export PATH="$HOME/.fzf/bin:$PATH"' >> ~/.zshrc
            echo 'export PATH="$HOME/.fzf/bin:$PATH"' >> ~/.bashrc
        fi
    fi

    # Source fzf shell integration
    local shell_rc="$HOME/.zshrc"
    if [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    fi

    # Add fzf shell integration if not already present
    if ! grep -q "fzf/shell/key-bindings" "$shell_rc" 2>/dev/null; then
        echo '[ -f ~/.fzf/shell/key-bindings.zsh ] && source ~/.fzf/shell/key-bindings.zsh' >> "$shell_rc"
        echo '[ -f ~/.fzf/shell/completion.zsh ] && source ~/.fzf/shell/completion.zsh' >> "$shell_rc"
    fi

    # Verify installation
    if command_exists fzf || [ -f "$fzf_dir/bin/fzf" ]; then
        success "fzf installed"
        if command_exists fzf; then
            fzf --version | head -n1
        else
            "$fzf_dir/bin/fzf" --version | head -n1
        fi
    else
        error "fzf installation failed"
        return 1
    fi
}

# Main execution
main() {
    local os zsh_path

    log "=== $SCRIPT_NAME ==="

    # Detect OS
    os=$(detect_os)
    log "Detected OS: $os"

    # Install/check zsh
    if command_exists zsh; then
        log "Zsh already installed"
        zsh_path=$(command -v zsh)
    else
        log "Installing zsh..."
        install_zsh "$os" || exit 1
        zsh_path=$(command -v zsh)
        log "Zsh installed at: $zsh_path"
    fi

    # Set default shell
    set_default_shell "$zsh_path"

    # Install UV if needed
    if command_exists uv; then
        log "UV already installed"
    elif install_uv; then
        :
    else
        error "Warning: UV install failed"
    fi

    # Install dotbot if UV available
    if command_exists uv; then
        install_dotbot
    else
        log "UV not available, skipping dotbot"
    fi

    # Install oh-my-zsh
    install_oh_my_zsh

    # Install zsh-syntax-highlighting
    install_zsh_syntax_highlighting

    # Install zsh-autosuggestions
    install_zsh_autosuggestions

    # Install Neovim
    if command_exists nvim; then
        log "Neovim already installed"
    else
        log "Installing Neovim..."
        install_neovim "$os" || error "Warning: Neovim install failed"
    fi

    # Install fzf
    if command_exists fzf; then
        log "fzf already installed"
    else
        log "Installing fzf..."
        install_fzf || error "Warning: fzf install failed"
    fi

    echo
    success "=== Setup complete! ==="
    log "1. Log out/in for shell changes"
    command_exists dotbot && log "2. Run 'dotbot' to configure dotfiles"
    command_exists nvim && log "3. Neovim is ready to use!"
    command_exists fzf && log "4. fzf is ready to use!"
}

main "$@"