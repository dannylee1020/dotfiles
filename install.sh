#!/usr/bin/env bash


set -e -ou pipefail

PACKAGES=(
    git
    docker
    pyenv
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
    xcode tools for homebrew
    xcode-select --install

    # install homebrew before installing everything else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # add homebrew to the path
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/dannylee1020/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    echo "Done installing Homebrew"
}

function install_packages () {
    echo "Installing Homebrew packages..."
    brew update && brew install "${PACKAGES[@]}"
    echo "Done installing homebrew packages"
}

function install_applications () {
    echo "Installing Homebrew apps..."

#    brew tap homebrew/cask-drivers \
#        && brew update \
#        && brew install --cask "${CASKS[@]}"

    brew update && brew install --cask "${CASKS[@]}"
    echo "Done installing Homebrew apps"

    echo "Installing VS Code Extensions..."
    for ext in ${VSCODE_EXTENSIONS[@]}; do
        code --force --install-extension "$ext"
    done
    echo "Done installing VS Code extensions"
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
    echo 'source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
    echo "Done installing Powerlevel10k"

}

function setup_python () {
    echo "Installing python"
    pyenv install -v 3.10
    echo "Done installing python"

    echo "Setting up poetry ..."
    curl -sSL https://install.python-poetry.org | sed 's/symlinks=False/symlinks=True/' | python3 -
    echo "Done setting up poetry"
}

function setup_dotfiles () {
    # need zshrc, p10k.zsh
    git clone https://github.com/dannylee1020/dotfiles.git "$HOME/.dotfiles"
    for i in "$HOME/.dotfiles/"__*; do
        filename=$(basename $i)
        source="${HOME}/.dotfiles/$filename"
        target="${HOME}/${filename/__/.}"

        if [ -e "${target}" ] && [ ! -h "${target}" ]; then
            mkdir "${HOME}/.save"
            backup="${HOME}/.save/${filename}"
            echo "Creating backup ${target} to ${backup}"
            mv "${target}" "${backup}"
        fi

        # create symlink between source and target
        ln -sf "$source" "$target"

        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            echo "A symlink exists between $source and $target."
        else
            echo "No symlink found between $source and $target."
        fi

    done

    # vscode config
    ln -s "${HOME}/.dotfiles/vscode_settings.json" "${HOME}/Library/Application Support/Code/User/settings.json"
    ln -s "${HOME}/.dotfiles/vscode_keybindings.json" "${HOME}/Library/Application Support/Code/User/keybindings.json"

    echo "VS Code symlink created"
}

function main () {
    install_prereqs
    install_packages
    install_applications

    setup_shell
    setup_dotfiles
    setup_python
}

main
