function flushdns --description 'Flush the DNS cache on MacOS'
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
end
