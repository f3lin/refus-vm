#!/bin/bash

# Function to print steps
echo_step() {
    echo -e "\n\033[1;34m$1\033[0m"
}

# Function to print success messages
echo_success() {
    echo -e "\033[1;32m$1\033[0m"
}

# Function to print error messages
echo_error() {
    echo -e "\033[1;31m$1\033[0m"
}

# Variable centralization
BIN_DIR="$HOME/.local/bin/"
DIR="$HOME/terminal-themes"
THEME_URL="https://raw.githubusercontent.com/f3lin/my-terminal/main/themes/dev-remote.omp.yaml"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Lilex.zip"

# Initial setup and validation for required tools
required_tools=(curl wget unzip)
for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo_step "Installation de $tool..."
        sudo apt-get install -y "$tool"
    fi
done

# Step 1: Install Oh My Posh
if ! command -v oh-my-posh &> /dev/null; then
    echo_step "Installation de Oh My Posh..."
    mkdir -p "$BIN_DIR"
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$BIN_DIR"
    if [ $? -eq 0 ]; then
        echo_success "Oh My Posh installé."
    else
        echo_error "Échec de l'installation de Oh My Posh."
        exit 1
    fi
else
    echo_success "Oh My Posh déjà installé."
fi

# Step 2: Download the theme
if [ ! -f "$DIR/dev-remote.omp.yaml" ]; then
    mkdir -p "$DIR"
    echo_step "Téléchargement du thème..."
    wget -O "$DIR/dev-remote.omp.yaml" "$THEME_URL"
    if [ $? -eq 0 ] && [ -s "$DIR/dev-remote.omp.yaml" ]; then
        echo_success "Thème téléchargé."
    else
        echo_error "Échec du téléchargement du thème ou fichier vide."
        exit 1
    fi
else
    echo_success "Thème déjà téléchargé."
fi

# Step 3: Update the profile
if ! grep -q 'oh-my-posh' ~/.bashrc; then
    echo_step "Mise à jour du profil..."
    echo 'export PATH="$PATH:'"$BIN_DIR"'"' >> ~/.bashrc
    echo 'eval "$(oh-my-posh init bash --config '"$DIR"'/dev-remote.omp.yaml)"' >> ~/.bashrc
    echo_success "Profil mis à jour."
else
    echo_success "Profil déjà mis à jour."
fi

# Step 6: Install Nerd Fonts
if [ ! -d ~/.fonts ]; then
    echo_step "Installation de la police Nerd Fonts..."
    wget -O Lilex.zip "$NERD_FONT_URL"
    if [ $? -eq 0 ] && [ -s Lilex.zip ]; then
        unzip Lilex.zip -d ~/.fonts
        fc-cache -fv
        rm Lilex.zip
        echo_success "Police Nerd Fonts installée."
    else
        echo_error "Échec du téléchargement de la police Nerd Fonts."
        exit 1
    fi
else
    echo_success "Police Nerd Fonts déjà installée."
fi

# Step 7: Clean up unnecessary packages and temporary files
echo_step "Nettoyage des paquets inutiles..."
sudo apt-get autoremove -y
sudo apt-get clean

# Print completion message
echo_success "Installation des bibliothèques et outils de base terminée !"

# actualisation du terminal
exec bash
