#!/usr/bin/env bash

set -e -ou pipefail

PACKAGES=(
    git
    docker
    pyenv
    curl
    zsh
)

CASKS=(
    visual-studio-code
    obsidian
    yt-music
    brave-browser
    rectangle
    iterm2
    fliqlo
    numi
)

VSCODE_EXTENSIONS=(
    4ops.terraform
    aaron-bond.better-comments
    azemoh.one-monokai
    Cardinal90.multi-cursor-case-preserve
    dericcain.feather
    eamodio.gitlens
    ecmel.vscode-html-css
    esbenp.prettier-vscode
    GitHub.github-vscode-theme
    golang.go
    mechatroner.rainbow-csv
    ms-azuretools.vscode-docker
    ms-python.black-formatter
    ms-python.isort
    ms-python.python
    ms-python.vscode-pylance
    nickdemayo.vscode-json-editor
    perragnaredin.september-steel
    radiolevity.search-lights
    rangav.vscode-thunder-client
    rokoroku.vscode-theme-darcula
    samuelcolvin.jinjahtml
    tamasfe.even-better-toml
    techer.open-in-browser
    thisotherthing.vscode-todo-list
    wraith13.zoombar-vscode
    yzhang.markdown-all-in-one
    zhuangtongfa.material-theme
    zxh404.vscode-proto3
)

function install_prereqs () {
    echo "Installing prereqs..."
    # xcode tools for homebrew
    xcode-select --install

    # install homebrew before installing everything else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Done installing Homebrew"
}

function install_packages () {
    echo "Installing Homebrew packages..."
    brew update && brew install "${PACKAGES[@]}"
    echo "Done installing homebrew packages"

    echo "Installing VS Code Extensions..."
    for ext in ${VSCODE_EXTENSIONS[@]}; do
        code --force --install-extension "$ext"
    done
    echo "Done installing VS Code extensions"
}

function install_applications () {
    echo "Installing Homebrew apps..."
    brew tap homebrew/cask-drivers \
        && brew update \
        && brew install --cask "${CASKS[@]}"
    echo "Done installing Homebrew apps"
}

function setup_shell () {
    echo "Installing OhMyZsh ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "Done installing OhMyZsh"

    echo "Installing zsh-autouggestions ..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo "Done installing zsh-autosuggestions"

    echo "Installing zsh-syntax-highlighting ..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo "Done installing zsh-syntax-highlighting"

    echo "Installing Powerlevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc
    echo "Done installing Powerlevel10k"

}

function setup_python () {
    echo "Setting up poetry ..."
    curl -sSL https://install.python-poetry.org | python3 -
    echo "Done setting up poetry"
}

function setup_dotfiles () {
    # need zshrc, p10k.zsh
    git clone https://github.com/dannylee1020/dotfiles.git "$HOME/.dotfiles"
    for i in "$HOME/.dotfiles/_*"; do
        source="${HOME}/.dotfiles/$i"
        target="${HOME}/${i/_/.}"

        if [ -e "${target}" ] && [ ! -h "${target}" ]; then
            mkdir "${HOME}/.save"
            backup="${HOME}/.save/${i}"
            echo "Creating backup ${target} to ${backup}"
            mv "${target}" "${backup}"
        fi

        # create symlink between source and target
        ln -s "$source" "$target"
    done

    # vscode config
    ln -s "$HOME/.dotfiles/vscode_settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    ln -s "$HOME/.ditfiles/vscode_keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"

}

function main () {
    install_prereqs
    install_packages
    install_applications

    setup_shell
    setup_python
    setup_dotfiles
}

main