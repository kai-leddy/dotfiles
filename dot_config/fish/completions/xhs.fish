complete -c xhs -l raw -d 'Pass raw request data without extra processing' -r
complete -c xhs -l pretty -d 'Controls output processing' -r -f -a "{all\t'(default) Enable both coloring and formatting',colors\t'Apply syntax highlighting to output',format\t'Pretty-print json and sort headers',none\t'Disable both coloring and formatting'}"
complete -c xhs -l format-options -d 'Set output formatting options' -r
complete -c xhs -s s -l style -d 'Output coloring style' -r -f -a "{auto\t'',solarized\t'',monokai\t'',fruity\t''}"
complete -c xhs -l response-charset -d 'Override the response encoding for terminal display purposes' -r
complete -c xhs -l response-mime -d 'Override the response mime type for coloring and formatting for the terminal' -r
complete -c xhs -s p -l print -d 'String specifying what the output should contain' -r
complete -c xhs -s P -l history-print -d 'The same as --print but applies only to intermediary requests/responses' -r
complete -c xhs -s o -l output -d 'Save output to FILE instead of stdout' -r -F
complete -c xhs -l session -d 'Create, or reuse and update a session' -r
complete -c xhs -l session-read-only -d 'Create or read a session without updating it form the request/response exchange' -r
complete -c xhs -s A -l auth-type -d 'Specify the auth mechanism' -r -f -a "{basic\t'',bearer\t'',digest\t''}"
complete -c xhs -s a -l auth -d 'Authenticate as USER with PASS (-A basic|digest) or with TOKEN (-A bearer)' -r
complete -c xhs -l bearer -d 'Authenticate with a bearer token' -r
complete -c xhs -l max-redirects -d 'Number of redirects to follow. Only respected if --follow is used' -r
complete -c xhs -l timeout -d 'Connection timeout of the request' -r
complete -c xhs -l proxy -d 'Use a proxy for a protocol. For example: --proxy https:http://proxy.host:8080' -r
complete -c xhs -l verify -d 'If "no", skip SSL verification. If a file path, use it as a CA bundle' -r
complete -c xhs -l cert -d 'Use a client side certificate for SSL' -r -F
complete -c xhs -l cert-key -d 'A private key file to use with --cert' -r -F
complete -c xhs -l ssl -d 'Force a particular TLS version' -r -f -a "{auto\t'',tls1\t'',tls1.1\t'',tls1.2\t'',tls1.3\t''}"
complete -c xhs -l default-scheme -d 'The default scheme to use if not specified in the URL' -r
complete -c xhs -l http-version -d 'HTTP version to use' -r -f -a "{1.0\t'',1.1\t'',2\t'',2-prior-knowledge\t''}"
complete -c xhs -l resolve -d 'Override DNS resolution for specific domain to a custom IP' -r
complete -c xhs -l interface -d 'Bind to a network interface or local IP address' -r
complete -c xhs -s j -l json -d '(default) Serialize data items from the command line as a JSON object'
complete -c xhs -s f -l form -d 'Serialize data items from the command line as form fields'
complete -c xhs -l multipart -d 'Like --form, but force a multipart/form-data request even without files'
complete -c xhs -s h -l headers -d 'Print only the response headers. Shortcut for --print=h'
complete -c xhs -s b -l body -d 'Print only the response body. Shortcut for --print=b'
complete -c xhs -s m -l meta -d 'Print only the response metadata. Shortcut for --print=m'
complete -c xhs -s v -l verbose -d 'Print the whole request as well as the response'
complete -c xhs -l debug -d 'Print full error stack traces and debug log messages'
complete -c xhs -l all -d 'Show any intermediary requests/responses while following redirects with --follow'
complete -c xhs -s q -l quiet -d 'Do not print to stdout or stderr'
complete -c xhs -s S -l stream -d 'Always stream the response body'
complete -c xhs -s d -l download -d 'Download the body to a file instead of printing it'
complete -c xhs -s c -l continue -d 'Resume an interrupted download. Requires --download and --output'
complete -c xhs -l ignore-netrc -d 'Do not use credentials from .netrc'
complete -c xhs -l offline -d 'Construct HTTP requests without sending them anywhere'
complete -c xhs -l check-status -d '(default) Exit with an error status code if the server replies with an error'
complete -c xhs -s F -l follow -d 'Do follow redirects'
complete -c xhs -l native-tls -d 'Use the system TLS library instead of rustls (if enabled at compile time)'
complete -c xhs -l https -d 'Make HTTPS requests if not specified in the URL'
complete -c xhs -s 4 -l ipv4 -d 'Resolve hostname to ipv4 addresses only'
complete -c xhs -s 6 -l ipv6 -d 'Resolve hostname to ipv6 addresses only'
complete -c xhs -s I -l ignore-stdin -d 'Do not attempt to read stdin'
complete -c xhs -l curl -d 'Print a translation to a curl command'
complete -c xhs -l curl-long -d 'Use the long versions of curl\'s flags'
complete -c xhs -l help -d 'Print help'
complete -c xhs -l no-json
complete -c xhs -l no-form
complete -c xhs -l no-multipart
complete -c xhs -l no-raw
complete -c xhs -l no-pretty
complete -c xhs -l no-format-options
complete -c xhs -l no-style
complete -c xhs -l no-response-charset
complete -c xhs -l no-response-mime
complete -c xhs -l no-print
complete -c xhs -l no-headers
complete -c xhs -l no-body
complete -c xhs -l no-meta
complete -c xhs -l no-verbose
complete -c xhs -l no-debug
complete -c xhs -l no-all
complete -c xhs -l no-history-print
complete -c xhs -l no-quiet
complete -c xhs -l no-stream
complete -c xhs -l no-output
complete -c xhs -l no-download
complete -c xhs -l no-continue
complete -c xhs -l no-session
complete -c xhs -l no-session-read-only
complete -c xhs -l no-auth-type
complete -c xhs -l no-auth
complete -c xhs -l no-bearer
complete -c xhs -l no-ignore-netrc
complete -c xhs -l no-offline
complete -c xhs -l no-check-status
complete -c xhs -l no-follow
complete -c xhs -l no-max-redirects
complete -c xhs -l no-timeout
complete -c xhs -l no-proxy
complete -c xhs -l no-verify
complete -c xhs -l no-cert
complete -c xhs -l no-cert-key
complete -c xhs -l no-ssl
complete -c xhs -l no-native-tls
complete -c xhs -l no-default-scheme
complete -c xhs -l no-https
complete -c xhs -l no-http-version
complete -c xhs -l no-resolve
complete -c xhs -l no-interface
complete -c xhs -l no-ipv4
complete -c xhs -l no-ipv6
complete -c xhs -l no-ignore-stdin
complete -c xhs -l no-curl
complete -c xhs -l no-curl-long
complete -c xhs -l no-help
complete -c xhs -s V -l version -d 'Print version'
