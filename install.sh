#!/bin/sh
for file in .??*
do
	if [ "$file" != ".git" ] && [ "$file" != ".gitignore" ]; then
		ln -s ~/dotfiles/$file ~/$file
	fi
done
