#!/bin/sh
for file in .??*
do
	[ "$file" = ".git" ] && [ "$file" = ".gitignore" ] continue

	ln -s ~/dotfiles/$file ~/$file
done
