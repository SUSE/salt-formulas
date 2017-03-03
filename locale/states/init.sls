# This file is part of locale-formula.
#
# Foobar is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

# This state configures timezone, keyboard layout and language.

{%- set timezone = salt['pillar.get']('timezone:name', 'CET') %}
{%- set utc = salt['pillar.get']('timezone:utc', True) %}
{%- set language = salt['pillar.get']('keyboard_and_language:language', 'English (US)') %}
{%- set kb_layout = salt['pillar.get']('keyboard_and_language:keyboard_layout', 'English (US)') %}
{% from "locale/map.jinja" import confmap with context %}
{% from "locale/map.jinja" import map with context %}

mgr_timezone_setting:
  timezone.system:
    - name: {{ timezone }}
    - utc: {{ utc }}

mgr_timezone_packages:
  pkg.installed:
    - name: {{ confmap.pkgname }}

mgr_timezone_symlink:
  file.symlink:
    - name: {{ confmap.path_localtime }}
    - target: {{ confmap.path_zoneinfo }}{{ timezone }}
    - force: true
    - require:
      - pkg: {{ confmap.pkgname }}

mgr_kb_settings:
  keyboard.system:
    - name: {{ map.kb_map.get(kb_layout) }}

mgr_locale_package:
  pkg.installed:
    - name: {{ confmap.loc_pkg }}

{% if grains['os_family'] == 'Suse' %}
/etc/sysconfig/language:
  file.replace:
    - pattern: ^ROOT_USES_LANG=.*
    - repl: ROOT_USES_LANG="yes"
{% endif %}

mgr_language_settings:
  locale.system:
    - name: {{ map.lang_map.get(language) }}
    - require:
      - pkg: mgr_locale_package
