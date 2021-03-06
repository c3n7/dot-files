#!/bin/bash

PWD=$(pwd)

initvim() {
    echo "======================================"
    echo "Adding vim configs soft links to home"
    echo "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"

    ln -s $PWD/.vimrc ~/.vimrc
    echo " .vimrc added"

    ln -s $PWD/.vim/after ~/.vim/after
    echo " .vim/after added"

    ln -s $PWD/.vim/coc-settings.json ~/.vim/coc-settings.json
    echo " .vim/coc-settings.json added"

    echo "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
    echo "Done"
    echo "======================================"
}

init-zsh() {
    echo "======================================"
    echo "Adding zsh configs soft links to home"
    echo "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"

    ln -s $PWD/.p10k.zsh ~/.p10k.zsh
    echo " .p10k.zsh added"

    ln -s $PWD/.zshrc ~/.zshrc
    echo " .zshrc added"

    echo "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
    echo "Done"
    echo "======================================"
}

init-ncmpcpp() {
    echo "======================================"
    echo "Adding ncmpcpp configs soft links"
    echo "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"

    ln -s $PWD/.ncmpcpp ~/.ncmpcpp
    echo " .ncmpcpp added"

    echo "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
    echo "Done"
    echo "======================================"
}

license() {
echo "dot-files Copyright (C) 2020 Timothy Karani
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it
under certain conditions.
For details visit <https://www.gnu.org/licenses/>."
}

clean-home() {
    echo "======================================"
    echo "Deleting"
    echo "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"

    echo "1. Vim Files:"
    echo "   .vimrc"
    rm -rf ~/.vimrc 
    echo "   .vim/coc-settings.json"
    rm -rf ~/.vim/coc-settings.json
    echo "   .vim/after"
    rm -rf ~/.vim/after

    echo 

    echo "2. zsh files"
    rm -rf ~/.p10k.zsh
    echo "   .p10k.zsh"
    rm -rf ~/.zshrc
    echo "   .zshrc"

    echo 

    echo "3. ncmpcpp files"
    rm -rf ~/.ncmpcpp

    echo "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
    echo "Done."
    echo "======================================"
}

if [ $# -eq 0 ]
then
    echo "ERROR: Insufficient number of arguments passed, exiting"
    exit 1

elif [ $1 = "vim" ] 
then
    initvim
    
elif [ $1 = "zsh" ] 
then
    init-zsh

elif [ $1 = "ncmpcpp" ] 
then
    init-ncmpcpp

elif [ $1 = "license" ] 
then
    license

elif [ $1 = "all" ] 
then
    initvim
    echo
    init-zsh
    echo
    init-ncmpcpp

elif [ $1 = "clean" ]
then
    read -p "Cleans configs in your home dir. Are you sure?(y/N): " CONFIRM
    if [ -z  $CONFIRM ]
    then
        echo "Not deleting."
    elif [ $CONFIRM = "y" ] || [ $CONFIRM = "Y" ]
    then
        clean-home
   else
        echo "Not deleting."
    fi

else
    echo "Unknown command, exiting."
    exit 1
fi
