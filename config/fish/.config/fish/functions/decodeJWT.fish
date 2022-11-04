function decodeJWT --description 'Decode a full JWT and pretty-print the body'
echo $argv[1] | cut -d '.' -f2 | base64 --decode | jq '.'
end
