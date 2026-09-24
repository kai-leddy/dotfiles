function gz --description 'create .tar.gz with pigz'
	tar -cvf - $argv[2..-1] | pigz -v - > $argv[1]
end
