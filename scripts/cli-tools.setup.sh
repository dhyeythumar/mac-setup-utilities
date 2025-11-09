#!/usr/bin/env bash
set -e

# Opinionated CLI tools setup script that does all the CLI tools setup on MacBook machine. And its idempotent, so it can be run multiple times without any issues.

# Check if running in interactive mode and warn about sudo requirements
echo "--------------------------------------------"
echo "🔧 CLI Tools Setup for macOS"
echo "--------------------------------------------"
echo "⚠️  This script requires administrator access."
echo "💡 You may be prompted for your password during installation."
echo ""

# Pre-authenticate sudo to avoid issues during installation
echo "🔑 Requesting administrator access..."
if ! sudo -v; then
    echo "❌ Error: Administrator access is required to run this script."
    echo "   Please run this script in an interactive terminal, not piped from curl."
    exit 1
fi

# Keep sudo alive in the background
(while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null) &
SUDO_KEEPER_PID=$!

# Cleanup function to kill the sudo keeper process
cleanup() {
    if [ ! -z "$SUDO_KEEPER_PID" ]; then
        kill "$SUDO_KEEPER_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

echo -e "\n--------------------------------------------"
echo "Setting up Oh My Zsh"
echo "--------------------------------------------"

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✅ Oh My Zsh is already installed, skipping..."
else
    echo "📦 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh My Zsh installed successfully!"
fi


echo -e "\n--------------------------------------------"
echo "Setting up Homebrew (Package Manager)"
echo "--------------------------------------------"

if command -v brew &>/dev/null; then
    echo "✅ Homebrew is already installed, skipping..."
else
    echo "📦 Homebrew not found. Installing..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        echo "✅ Homebrew installed successfully!"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "❌ Failed to install Homebrew"
        exit 1
    fi
fi

echo -e "\n📦 Updating Homebrew packages..."
if brew update; then
    echo "✅ Homebrew packages updated successfully!"
else
    echo "⚠️  Warning: Failed to update Homebrew, continuing anyway..."
fi


echo -e "\n--------------------------------------------"
echo "Setting up Git"
echo "--------------------------------------------"

if command -v git &>/dev/null; then
    echo "✅ Git is already installed"
    echo "   Current version: $(git --version)"
else
    echo "📦 Installing Git..."
    if brew install git; then
        echo "✅ Git installed successfully!"
        echo "   Version: $(git --version)"
    else
        echo "❌ Failed to install Git"
        exit 1
    fi
fi


echo -e "\n--------------------------------------------"
echo "Setting up Node.js (LTS version)"
echo "--------------------------------------------"

# Setup NVM (Node Version Manager)
if brew list nvm &>/dev/null; then
    echo "✅ nvm is already installed, skipping..."
else
    echo "📦 Installing nvm..."
    if brew install nvm; then
        echo "✅ nvm installed successfully!"
    else
        echo "❌ Failed to install nvm"
        exit 1
    fi
fi

# Setup NVM environment
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

# Add nvm to shell profile if not already present
if ! grep -q 'NVM_DIR' ~/.zshrc; then
    echo "📝 Adding NVM to ~/.zshrc file..."
    echo "" >> ~/.zshrc
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
    echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"' >> ~/.zshrc
    echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"' >> ~/.zshrc
fi

# Load nvm in current session
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    \. "/opt/homebrew/opt/nvm/nvm.sh"
    
    # Install latest Node.js LTS version
    echo "📦 Installing latest Node.js LTS version..."
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
    echo "✅ Node.js $(node -v) installed and set as default!"
else
    echo -e "\n⚠️  Warning: NVM script not found. Please restart your terminal and run 'nvm install --lts' manually."
fi


echo -e "\n--------------------------------------------"
echo "Setting up AWS CLI"
echo "--------------------------------------------"

if command -v aws &>/dev/null; then
    echo "✅ AWS CLI is already installed, skipping..."
    echo "   Current version: $(aws --version)"
else
    echo "📦 Installing AWS CLI..."
    if brew install awscli; then
        echo "✅ AWS CLI installed successfully!"
        echo "   Version: $(aws --version)"
    else
        echo "❌ Failed to install AWS CLI"
        exit 1
    fi
fi


echo -e "\n--------------------------------------------"
echo "Setting up stskeygen (AWS STS key generator)"
echo "--------------------------------------------"

if command -v stskeygen &>/dev/null; then
    echo "✅ stskeygen is already installed, skipping..."
else
    echo "📦 Installing stskeygen..."
    # Add the tap if not already added
    if ! brew tap | grep -q "cimpress-mcp/stskeygen-installers"; then
        echo "   Adding Cimpress-MCP tap..."
        if ! brew tap Cimpress-MCP/stskeygen-installers https://github.com/Cimpress-MCP/stskeygen-installers.git; then
            echo "❌ Failed to add tap"
            exit 1
        fi
    fi
    
    if brew install Cimpress-MCP/stskeygen-installers/stskeygen; then
        echo "✅ stskeygen installed successfully!"
    else
        echo "❌ Failed to install stskeygen"
        exit 1
    fi
fi


echo -e "\n--------------------------------------------"
echo "Setting up mysides (Finder sidebar manager)"
echo "--------------------------------------------"

if command -v mysides &>/dev/null; then
    echo "✅ mysides is already installed, skipping..."
else
    echo "📦 Installing mysides..."
    if brew install mysides; then
        echo "✅ mysides installed successfully!"
    else
        echo "❌ Failed to install mysides"
        exit 1
    fi
fi


echo -e "\n--------------------------------------------"
echo "Setting up dockutil (Dock manager)"
echo "--------------------------------------------"

if command -v dockutil &>/dev/null; then
    echo "✅ dockutil is already installed, skipping..."
else
    echo "📦 Installing dockutil..."
    if brew install dockutil; then
        echo "✅ dockutil installed successfully!"
    else
        echo "❌ Failed to install dockutil"
        exit 1
    fi
fi


echo ""
echo "================================================================================"
echo "CLI Tools Setup complete! Please restart your terminal to apply the changes. 🚀"
echo "================================================================================"
