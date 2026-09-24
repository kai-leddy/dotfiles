function ugz --description 'unzip .tar.gz with pigz'
	unpigz -v --stdout $argv[1] | tar -xvf -
end
