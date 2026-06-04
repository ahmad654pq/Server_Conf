#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(eval echo "~$TARGET_USER")"

echo "🚀 Starting Ubuntu server setup for user: $TARGET_USER"

if ! command -v apt >/dev/null 2>&1; then
  echo "❌ This script is intended for Ubuntu/Debian systems using apt."
  exit 1
fi

echo "📦 Updating system and installing required packages..."
sudo apt update
sudo apt install -y \
  zsh \
  git \
  curl \
  wget \
  zoxide \
  unzip \
  build-essential \
  ca-certificates \
  fonts-powerline

snap install mise --classic

echo "✅ Basic packages installed."

echo "🐚 Installing Oh My Zsh..."
if [ ! -d "$TARGET_HOME/.oh-my-zsh" ]; then
  sudo -u "$TARGET_USER" sh -c \
    'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
else
  echo "ℹ️ Oh My Zsh already installed."
fi

ZSH_CUSTOM="$TARGET_HOME/.oh-my-zsh/custom"

echo "🎨 Installing Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  sudo -u "$TARGET_USER" git clone --depth=1 \
    https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo "ℹ️ Powerlevel10k already installed."
fi

echo "🔌 Installing useful Zsh plugins..."

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  sudo -u "$TARGET_USER" git clone --depth=1 \
    https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  sudo -u "$TARGET_USER" git clone --depth=1 \
    https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

echo "🕘 Installing McFly..."
if ! command -v mcfly >/dev/null 2>&1; then
  curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly
else
  echo "ℹ️ McFly already installed."
fi

echo "⚙️ Copying custom configs..."
cp "$REPO_DIR/configs/.zshrc" "$TARGET_HOME/.zshrc"
cp -r "$REPO_DIR/configs/.zsh/" "$TARGET_HOME/.zsh"
cp "$REPO_DIR/configs/zsh_functions.zsh" "$TARGET_HOME/.configs/zsh_functions.zsh"
cp "$REPO_DIR/configs/.p10k.zsh" "$TARGET_HOME/.p10k.zsh"

sudo chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.zshrc" "$TARGET_HOME/.p10k.zsh"

echo "🐚 Setting Zsh as default shell..."
ZSH_PATH="$(command -v zsh)"

if ! grep -q "$ZSH_PATH" /etc/shells; then
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

sudo chsh -s "$ZSH_PATH" "$TARGET_USER"

echo "✅ Setup complete."
echo ""
echo "Log out and log back in, or run:"
echo "exec zsh"
