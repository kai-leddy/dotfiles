# Defined in - @ line 1
function gitshow --description 'Show a git commit selected via FZF'
	git show (gitc) --color | less -R
end
