#!/usr/bin/env zsh

CWD=$PWD
SCRIPT_PATH=$(readlink -f $0)

cd $SCRIPT_PATH
stow -t "$HOME" --restow .
cd $CWD
