# This state configures cpu mitigation kernel parameters via the grub conf.
{% from "cpu-mitigations/map.jinja" import map with context %}
{%- set selected = salt['pillar.get']('mitigations:name', 'Auto') %}

# check for supported os version
{%- set supported_vers = ['42.3', '12.3', '12.4', '12.5', '15.0', '15.1', '15.2'] %}

{% if grains['os_family'] == 'Suse' and grains['osrelease'] in supported_vers %}
{%- set supported = True %}
{% endif %} #check if supported

{% if supported %}
# Change the mitigations parameters for the kernel
remove_mitigations:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^GRUB_CMDLINE_LINUX_DEFAULT="(.*?)(?:\s*)mitigations=(?:auto,nosmt|off|auto)(.*?)"
    - repl: GRUB_CMDLINE_LINUX_DEFAULT="\1\2"
    - unless:
      - 'grep "{{ map.cpu_opt.get(selected) }}[ \"]" /etc/default/grub'

add_mitigation_option:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^GRUB_CMDLINE_LINUX_DEFAULT="([^"]*)"
{% if selected == 'Manual' %}
    - repl: GRUB_CMDLINE_LINUX_DEFAULT="\1"
{% else %}
    - repl: GRUB_CMDLINE_LINUX_DEFAULT="\1{{ map.cpu_opt.get(selected) }}"
{% endif %} #manual
    - unless:
      - 'grep "{{ map.cpu_opt.get(selected) }}[ \"]" /etc/default/grub'

rebuild_grub_conf:
   cmd.run:
    - name: grub2-mkconfig -o /boot/grub2/grub.cfg
    - onchanges:
      - file: remove_mitigations
      - file: add_mitigation_option
{% endif %} #supported
