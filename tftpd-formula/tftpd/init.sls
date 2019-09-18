# This file is part of tftpd-formula.
#
# tftpd-formula is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# tftpd-formula is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with tftpd-formula.  If not, see <http://www.gnu.org/licenses/>.

# This state install, configures and start tftpd service on POS branchserver

{% from "tftpd/map.jinja" import cfgmap with context %}

remove_atftp:
  pkg.removed:
    - name: {{ cfgmap.conflicting_package }}

install_tftp:
  pkg.installed:
    - name: {{ cfgmap.package }}

etc_sysconfig_tftp:
  file.managed:
    - name:   {{ cfgmap.pathname_cfg }}
    - source: salt://tftpd/files/tftp.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - backup: minion
    - require:
      - pkg: install_tftp
      

enable_and_start_tftpd:
  service.running:
    - name: {{ cfgmap.servicename }}
    - enable: True
    - watch:
        - file: etc_sysconfig_tftp
