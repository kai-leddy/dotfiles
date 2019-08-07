# Defined in - @ line 1
function emacs --description 'alias emacs emacsclient -c -a emacs'
	emacsclient -c -a emacs $argv;
end
