# This state configures cpu mitigation kernel parameters via the grub conf.
{% from "cpu-mitigations/map.jinja" import map with context %}
{%- set selected = salt['pillar.get']('mitigations:name', 'Auto') %}

# check for support os version
{%- set os_ver = grains['osrelease'] %}
{% if '12' in os_ver and '12.2' <= os_ver %}
{%- set grub_line_start = map.grub_line.get('12') %}
{% elif '42.3' == os_ver %}
{%- set grub_line_start = map.grub_line.get('12') %}
{% elif '15' in os_ver %}
{%- set grub_line_start = map.grub_line.get('15') %}
{% else %}
{%- set grub_line_start = map.grub_line.get('default') %}
{% endif %} #os_ver

{% if grub_line_start and grains['os_family'] == 'Suse' %}
remove_mitigations:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^{{ grub_line_start }}="(.*?)(?:\s*)mitigations=(?:auto,nosmt|off|auto)(.*?)"
    - repl: {{ grub_line_start }}="\1\2"
    - onlyif:
      - 'grep mitigations= /etc/default/grub'

add_mitigation_option:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^{{ grub_line_start }}="(.*)"
{% if selected == 'Manual' %}
    - repl: {{ grub_line_start }}="\1"
{% else %}
    - repl: {{ grub_line_start }}="\1 {{ map.cpu_opt.get(selected) }}"
{% endif %} #manual

rebuild_grub_conf:
   cmd.run:
    - name: grub2-mkconfig -o /boot/grub2/grub.cfg
    - onchanges:
      - file: remove_mitigations
      - file: add_mitigation_option
{% endif %} #os_family
