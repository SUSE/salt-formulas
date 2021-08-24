import logging
import re

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
    if len(filtered_entries) == 0:
        ret['comment'] = 'No matching grub2 entry in configuration'
        return ret

    entry = filtered_entries[0]
    ret = __states__['file.append'](name='/etc/default/grub', text='GRUB_DEFAULT="{0}"'.format(entry))
    ret['name'] = name
    return ret


def kernel_param(name, value):
    """
    Ensure a Kernel command line parameter has the given value.
    If the value is `None` the parameter has to be absent.
    """
    ret = {
        'name': name,
        'result': False if not __opts__["test"] else None,
        'changes': {},
        'comment': [],
    }
    cmd = 'sed -nre \'s/GRUB_CMDLINE_LINUX_DEFAULT="([^"]*)"/\\1/p\' /etc/default/grub'
    entries = __salt__['cmd.run'](cmd).splitlines()
    if len(entries) == 0:
        ret['result'] = True
        if value is not None:
            ret = __states__['file.append'](
                    name='/etc/default/grub',
                    text='GRUB_CMDLINE_LINUX_DEFAULT="{}={}"'.format(name, value))
            ret['name'] = name
        return ret

    params = entries[0]
    param_str = name
    if value not in ("", None):
        param_str += "=" + str(value)
    matcher = re.match("^(.+ )?" + name + "(?:=([^ ]+))?( .+)?$", params)
    new_params = params
    if matcher and value is None:
        new_params = re.sub(' {2,}', ' ' ,matcher.expand('\\1\\3')).strip()
    elif matcher and value is not None:
        same_value = (matcher.group(2) is None and value == "") or matcher.group(2) == value
        if not same_value:
            new_params = matcher.expand('\\1{}\\3'.format(param_str))
    elif not matcher and value is not None:
        new_params += " " + param_str

    if new_params != params:
        ret = __states__['file.replace'](
                name='/etc/default/grub',
                repl='GRUB_CMDLINE_LINUX_DEFAULT="{}"'.format(new_params),
                pattern='GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"')
        ret['name'] = name
        return ret

    # no changes
    ret['result'] = True
    return ret
