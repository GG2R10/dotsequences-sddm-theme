#!/bin/bash
## Dotsequences SDDM Theme Installer
##
## Usage:
##   bash -c "$(curl -fsSL https://raw.githubusercontent.com/GG2R10/dotsequences-sddm-theme/master/install.sh)"
##
## Script works in Arch, Fedora, Ubuntu. Didn't try it in Void and openSUSE.

set -euo pipefail

readonly THEME_REPO="https://github.com/GG2R10/dotsequences-sddm-theme.git"
readonly THEME_NAME="dotsequences-sddm-theme"
readonly THEMES_DIR="/usr/share/sddm/themes"
readonly FONTS_DIR="/usr/share/fonts/${THEME_NAME}"
readonly PATH_TO_GIT_CLONE="$HOME/$THEME_NAME"
readonly SDDM_CONF_D="/etc/sddm.conf.d"
readonly DATE=$(date +%s)

# Logging with gum fallback
info() {
    if command -v gum &>/dev/null; then
        gum style --foreground 10 "✅ $*"
    else
        echo -e "\e[32m✅ $*\e[0m"
    fi
}

warn() {
    if command -v gum &>/dev/null; then
        gum style --foreground 11 "⚠  $*"
    else
        echo -e "\e[33m⚠  $*\e[0m"
    fi
}

error() {
    if command -v gum &>/dev/null; then
        gum style --foreground 9 "❌ $*" >&2
    else
        echo -e "\e[31m❌ $*\e[0m" >&2
    fi
}

# UI functions
confirm() {
    if command -v gum &>/dev/null; then
        gum confirm "$1"
    else
        echo -n "$1 (y/n): "; read -r r; [[ "$r" =~ ^[Yy]$ ]]
    fi
}

spin() {
    local title="$1"; shift
    if command -v gum &>/dev/null; then
        gum spin --spinner="dot" --title="$title" -- "$@"
    else
        echo "$title"; "$@"
    fi
}

# Install gum if missing
install_gum() {
    local mgr
    mgr=$(for m in pacman xbps-install dnf zypper apt; do command -v $m &>/dev/null && { echo $m; break; }; done)

    case $mgr in
        pacman) sudo pacman --needed -S gum ;;
        dnf) sudo dnf install -y gum ;;
        zypper) sudo zypper install -y gum ;;
        xbps-install) sudo xbps-install -y gum ;;
        # reference https://github.com/basecamp/omakub/issues/222
        apt)
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
            sudo apt update && sudo apt install -y gum ;;
        *) error "Cannot install gum automatically"; return 1 ;;
    esac
}

# Check and install gum
check_gum() {
    if ! command -v gum &>/dev/null; then
        warn "Gum was not found - provides a nicer install experience"
        if confirm "Install gum?"; then
            install_gum && { info "Restarting with gum..."; main; exit 0; } || warn "Continuing with fallback UI"
        fi
    fi
}

# Install dependencies
install_deps() {
    local mgr
    mgr=$(for m in pacman xbps-install dnf zypper apt; do command -v $m &>/dev/null && { echo $m; break; }; done)
    info "Package manager: ${mgr:-unknown}"

    case $mgr in
        pacman) sudo pacman --needed -S sddm qt6-svg qt6-5compat ;;
        xbps-install) sudo xbps-install -y sddm qt6-svg qt6-5compat ;;
        dnf) sudo dnf install -y sddm qt6-qtsvg qt6-qt5compat ;;
        # untested, best-effort package names
        zypper) sudo zypper install -y sddm qt6-svg-imageformats qt6-qt5compat ;;
        apt)
            sudo apt update
            sudo apt install -y sddm qt6-svg-dev qml6-module-qt5compat-graphicaleffects \
                qml6-module-qtquick-controls qml6-module-qtquick-layouts qml6-module-qtquick-effects \
                libxcb-cursor0
            ;;
        *) error "Unsupported or undetected package manager"; return 1 ;;
    esac
    info "Dependencies installed"
}

# Clone repository
clone_repo() {
    [[ -d "$PATH_TO_GIT_CLONE" ]] && mv "$PATH_TO_GIT_CLONE" "${PATH_TO_GIT_CLONE}_$DATE"
    spin "Cloning repository..." git clone -b master --depth 1 "$THEME_REPO" "$PATH_TO_GIT_CLONE"
    info "Repository cloned to $PATH_TO_GIT_CLONE"
}

# Install theme
install_theme() {
    local src="$PATH_TO_GIT_CLONE"
    local dst="$THEMES_DIR/$THEME_NAME"

    [[ ! -d "$src" ]] && { error "Clone the repository first"; return 1; }

    # Backup and copy
    [[ -d "$dst" ]] && sudo mv "$dst" "${dst}_$DATE"
    sudo mkdir -p "$dst"
    spin "Installing theme files..." sudo cp -r "$src"/. "$dst"/
    sudo rm -f "$dst/install.sh" "$dst/sync-assets.sh"
    sudo rm -rf "$dst/.git"

    # Install fonts (SDDM's greeter needs them registered system-wide,
    # not just sitting inside the theme folder)
    if [[ -d "$dst/Fonts" ]]; then
        sudo mkdir -p "$FONTS_DIR"
        spin "Installing fonts..." sudo cp -r "$dst/Fonts"/. "$FONTS_DIR"/
        spin "Refreshing font cache..." sudo fc-cache -f
    fi

    # Configure SDDM via a drop-in, instead of overwriting /etc/sddm.conf
    # wholesale (that would clobber any other settings already there).
    sudo mkdir -p "$SDDM_CONF_D"
    printf '[Theme]\nCurrent=%s\n' "$THEME_NAME" | sudo tee "$SDDM_CONF_D/$THEME_NAME.conf" >/dev/null

    info "Theme installed and set as current SDDM theme"
}

m_screen() {
    clear

    if command -v gum &>/dev/null; then
        gum style \
            --border normal --margin "1" --padding "1 2" \
            --border-foreground 212 \
            "$(gum style --foreground 212 --bold "Dotsequences SDDM Theme Installer")"
    else
        echo "===================================="
        echo "   Dotsequences SDDM Theme"
        echo "===================================="
    fi
}

show_plan() {
    local steps=(
        "Install sddm + Qt6 dependencies (SVG icons, Qt5Compat graphical effects) via sudo"
        "Clone the theme repo to $PATH_TO_GIT_CLONE"
        "Copy the theme to $THEMES_DIR/$THEME_NAME (sudo, backs up any existing install first)"
        "Install the theme's fonts to $FONTS_DIR and refresh the font cache (sudo)"
        "Write $SDDM_CONF_D/$THEME_NAME.conf to set this theme as SDDM's current theme (sudo)"
    )

    if command -v gum &>/dev/null; then
        gum style --foreground 212 --bold "This will:"
        for s in "${steps[@]}"; do
            gum style --margin "0 0 0 2" "• $s"
        done
    else
        echo "This will:"
        for s in "${steps[@]}"; do
            echo "  • $s"
        done
    fi
    echo
}

# Main flow
main() {
    m_screen

    check_gum
    show_plan

    if confirm "Continue with installation?"; then
        install_deps
        clone_repo
        install_theme
        info "Installation complete! Reboot or restart SDDM to see the changes."
    else
        warn "Installation cancelled."
    fi
}

main "$@"
