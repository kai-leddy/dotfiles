# Defined in - @ line 1
function githash --description 'Use FZF to select a git commit hash'
	git log --color=always --format="%C(auto)%h %<(15,trunc)%an %s %C(black)%C(bold)%cr %C(auto)%d" | fzf | awk '{print $1}'
end
