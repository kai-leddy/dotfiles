function gi --description "produce a gitignore for a filetype"
	curl -L -s https://www.gitignore.io/api/$argv
end
