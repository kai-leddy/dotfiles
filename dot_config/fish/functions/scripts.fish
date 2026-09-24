function scripts --wraps=jq\ \'.scripts\'\ package.json --description alias\ scripts\ jq\ \'.scripts\'\ package.json
  jq '.scripts' package.json $argv
        
end
