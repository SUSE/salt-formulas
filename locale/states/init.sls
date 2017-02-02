# This state configures timezone, keyboard layout and language.

{%- set timezone = salt['pillar.get']('timezone:name', 'CET') %}
{%- set utc = salt['pillar.get']('timezone:utc', True) %}
{%- set language = salt['pillar.get']('keyboard_and_language:language', 'English (US)') %}
{%- set kb_layout = salt['pillar.get']('keyboard_and_language:keyboard_layout', 'English (US)') %}
{% from "locale/map.jinja" import confmap with context %}
{% from "locale/map.jinja" import map with context %}

timezone_setting:
  timezone.system:
    - name: {{ timezone }}
    - utc: {{ utc }}

timezone_packages:
  pkg.installed:
    - name: {{ confmap.pkgname }}

timezone_symlink:
  file.symlink:
    - name: {{ confmap.path_localtime }}
    - target: {{ confmap.path_zoneinfo }}{{ timezone }}
    - force: true
    - require:
      - pkg: {{ confmap.pkgname }}

kb_settings:
  keyboard.system:
    - name: {{ map.kb_map.get(kb_layout) }}

locale_package:  
  pkg.installed:
    - name: {{ confmap.loc_pkg }}

{% if grains['os_family'] == 'Suse' %}
/etc/sysconfig/language:
  file.replace:
    - pattern: ^ROOT_USES_LANG=.*
    - repl: ROOT_USES_LANG="yes"
{% endif %}

language_settings:
  locale.system:
    - name: {{ map.lang_map.get(language) }}
    - require:
      - pkg: locale_package
