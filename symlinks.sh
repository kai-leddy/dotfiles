#!/bin/sh
echo "Creating symlinks for all dotfiles..."

# symlink all root dotfiles to home directory
for file in .*
do
	if [ "$file" != ".gitignore" ] && [ "$file" != ".git" ]
	then
		ln -s $(pwd)/$file ~
	fi
done

echo "Finished!"
