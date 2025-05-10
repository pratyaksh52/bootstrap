#!/usr/bin/env zsh

CWD=$PWD
cd $HOME/bootstrap/dotfiles

stow -t "$HOME" --restow .

cd $CWD
