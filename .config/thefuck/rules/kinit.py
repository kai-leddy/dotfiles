def match(command):
    return ('authentication failed' in command.output.lower())

def get_new_command(command):
    return 'kinit --password-file="/Users/KCL2/.config/kcl2/krb5p" kcl2 ;and {}'.format(command.script)

enabled_by_default = True
requires_output = True