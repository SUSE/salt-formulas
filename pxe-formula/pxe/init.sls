# This file is part of pxe-formula.
#
# pxe-formula is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# pxe-formula is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with pxe-formula.  If not, see <http://www.gnu.org/licenses/>.

# This state install and configures pxe boot on POS branchserver

{% from "pxe/map.jinja" import cfgmap with context %}


install_pxe:
  pkg.installed:
    - pkgs: {{ cfgmap.packages | json }}

install_efi:
  pkg.installed:
    - pkgs: {{ cfgmap.packages_efi | json }}


srv_tftpboot_default:
  file.managed:
    - name:   {{ cfgmap.pathname_defcfg }}
    - source: salt://pxe/files/pxecfg.template
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - require:
      - pkg: install_pxe

srv_tftpboot_default_efi:
  file.managed:
    - name:   {{ cfgmap.pathname_defcfg_efi }}
    - source: salt://pxe/files/pxecfg.grub2.template
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - require:
      - pkg: install_pxe

srv_tftpboot_base_efi:
  file.managed:
    - name:   {{ cfgmap.pathname_basecfg_efi }}
    - source: salt://pxe/files/pxecfg.grub2.base
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - require:
      - pkg: install_pxe

pxe_copy:
  file.copy:
    - name:   {{ cfgmap.boot_pxelinux }}
    - source: {{ cfgmap.path_pxelinux }}
    - require:
      - file: srv_tftpboot_default

pxe_copy_grub_efi:
  file.copy:
    - name:   {{ cfgmap.boot_grub_efi }}
    - source: {{ cfgmap.path_grub_efi }}
    - require:
      - file: srv_tftpboot_default_efi

pxe_copy_shim_efi:
  file.copy:
    - name:   {{ cfgmap.boot_shim_efi }}
    - source: {{ cfgmap.path_shim_efi }}
    - require:
      - file: srv_tftpboot_default_efi

pxe_copy_efi_dir:
  file.copy:
    - name:   {{ cfgmap.boot_efi_dir }}
    - source: {{ cfgmap.path_efi_dir }}
    - require:
      - file: srv_tftpboot_default_efi

{%- if salt['pillar.get']('pxe:enable_arm64', False) %}

install_arm64_efi:
  pkg.installed:
    - pkgs: {{ cfgmap.packages_arm64_efi | json }}

pxe_copy_grub_arm64_efi:
  file.copy:
    - name:   {{ cfgmap.boot_grub_arm64_efi }}
    - source: {{ cfgmap.path_grub_arm64_efi }}
    - require:
      - file: srv_tftpboot_default_efi

pxe_copy_arm64_efi_dir:
  file.copy:
    - name:   {{ cfgmap.boot_arm64_efi_dir }}
    - source: {{ cfgmap.path_arm64_efi_dir }}
    - require:
      - file: srv_tftpboot_default_efi

srv_tftpboot_default_arm64_efi:
  file.managed:
    - name:   {{ cfgmap.pathname_defcfg_arm64_efi }}
    - source: salt://pxe/files/pxecfg.grub2.template
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      kernel: {{ salt['pillar.get']('pxe:kernel_name_arm64', "linux_arm64") }}
      initrd: {{ salt['pillar.get']('pxe:initrd_name_arm64', "initrd_arm64") }}
    - require:
      - pkg: install_pxe

{%- endif %}

