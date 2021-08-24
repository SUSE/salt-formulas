import pytest
from mock import MagicMock, patch

from ..states import bootloader

@pytest.mark.parametrize("param, value, param_string", [("foo", "bar", "foo=bar"), ("foo", "", "foo")])
def test_kernel_param_added(param, value, param_string):
    """
    Test the bootloader.kernel_param function when adding a value
    """
    existing_params = "systemd.show_status=1 console=ttyS0,115200 console=tty0 net.ifnames=0 quiet"
    run_mock = MagicMock(return_value=existing_params)
    with patch.dict(bootloader.__salt__, {'cmd.run': run_mock}):
        replace_mock = MagicMock(return_value={'result': True, 'change': 'replaced', 'comment': ''})
        with patch.dict(bootloader.__states__, {'file.replace': replace_mock}):
            with patch.dict(bootloader.__opts__, {'test': False}):
                ret = bootloader.kernel_param(param, value)
                assert ret == {
                    'result': True,
                    'change': 'replaced',
                    'comment': '',
                    'name': param,
                }
                replace_mock.assert_called_once_with(
                    name='/etc/default/grub',
                    repl='GRUB_CMDLINE_LINUX_DEFAULT="{} {}"'.format(existing_params, param_string),
                    pattern='GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"'
                )


def test_kernel_param_updated():
    """
    Test the bootloader.kernel_param function when replacing a value
    """
    existing_params = "systemd.show_status=1 console=ttyS0,115200 console=tty0 net.ifnames=0 quiet"
    run_mock = MagicMock(return_value=existing_params)
    with patch.dict(bootloader.__salt__, {'cmd.run': run_mock}):
        replace_mock = MagicMock(return_value={'result': True, 'change': 'replaced', 'comment': ''})
        with patch.dict(bootloader.__states__, {'file.replace': replace_mock}):
            with patch.dict(bootloader.__opts__, {'test': False}):
                ret = bootloader.kernel_param('net.ifnames', '1')
                assert ret == {
                    'result': True,
                    'change': 'replaced',
                    'comment': '',
                    'name': 'net.ifnames',
                }
                replace_mock.assert_called_once_with(
                    name='/etc/default/grub',
                    repl='GRUB_CMDLINE_LINUX_DEFAULT="systemd.show_status=1 console=ttyS0,115200 console=tty0 net.ifnames=1 quiet"',
                    pattern='GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"'
                )


def test_kernel_param_removed():
    """
    Test the bootloader.kernel_param function when deleting a value
    """
    existing_params = "systemd.show_status=1 console=ttyS0,115200 console=tty0 net.ifnames=0 quiet"
    run_mock = MagicMock(return_value=existing_params)
    with patch.dict(bootloader.__salt__, {'cmd.run': run_mock}):
        replace_mock = MagicMock(return_value={'result': True, 'change': 'replaced', 'comment': ''})
        with patch.dict(bootloader.__states__, {'file.replace': replace_mock}):
            with patch.dict(bootloader.__opts__, {'test': False}):
                ret = bootloader.kernel_param('net.ifnames', None)
                assert ret == {
                    'result': True,
                    'change': 'replaced',
                    'comment': '',
                    'name': 'net.ifnames',
                }
                replace_mock.assert_called_once_with(
                    name='/etc/default/grub',
                    repl='GRUB_CMDLINE_LINUX_DEFAULT="systemd.show_status=1 console=ttyS0,115200 console=tty0 quiet"',
                    pattern='GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"'
                )


def test_kernel_param_append():
    """
    Test the bootloader.kernel_param function when adding a value
    """
    run_mock = MagicMock(return_value='')
    with patch.dict(bootloader.__salt__, {'cmd.run': run_mock}):
        append_mock = MagicMock(return_value={'result': True, 'change': 'appended', 'comment': ''})
        with patch.dict(bootloader.__states__, {'file.append': append_mock}):
            with patch.dict(bootloader.__opts__, {'test': False}):
                ret = bootloader.kernel_param("foo", "bar")
                assert ret == {
                    'result': True,
                    'change': 'appended',
                    'comment': '',
                    'name': 'foo',
                }
                append_mock.assert_called_once_with(
                    name='/etc/default/grub',
                    text='GRUB_CMDLINE_LINUX_DEFAULT="foo=bar"',
                )
