import logging

from salt.exceptions import CommandExecutionError

__virtualname__ = 'bootloader'

LOG = logging.getLogger(__name__)

# Define not exported variables from Salt, so this can be imported as
# a normal module
try:
    __opts__
    __salt__
    __states__
except NameError:
    __opts__ = {}
    __salt__ = {}
    __states__ = {}

def __virtual__():
    return True 

def grub_set_default(name):
    ret = {
        'name': name,
        'result': False,
        'changes': {},
        'comment': [],
    }
    cmd = 'sed -nre "s/[[:blank:]]*menuentry \'([^\']+)\'.*/\\1/p;" /boot/grub2/grub.cfg'
    entries = __salt__['cmd.run'](cmd).splitlines()
    filtered_entries = [entry for entry in entries if name in entry]
    if len(filtered_entries) > 0:
        entry = filtered_entries[0]
        ret = __states__['file.append'](name='/etc/default/grub', text='GRUB_DEFAULT="{0}"'.format(entry))
        # Stop here if the append failed
        if not ret['result']:
            return ret

        # Regenerate grub config
        out = None
        if not __opts__['test']:
            try:
                out = __salt__['cmd.run']('grub2-mkconfig -o /boot/grub2/grub.cfg', raise_err=True)
            except CommandExecutionError:
                ret['comment'] = 'Failed to run grub2-mkconfig: {0}'.format(out)
                ret['result'] = False
            ret['result'] = True
        else:
            ret['result'] = None
    else:
        ret['comment'] = 'No matching grub2 entry in configuration'
    return ret

    
