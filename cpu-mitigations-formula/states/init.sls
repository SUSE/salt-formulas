# This state configures cpu mitigation kernel parameters via the grub conf.
{% from "cpu-mitigations/map.jinja" import map with context %}
{%- set selected = salt['pillar.get']('mitigations:name', 'Auto') %}

# check for supported os version
{%- set supported_vers = ['42.3', '12.3', '12.4', '12.5', '15.0', '15.1', '15.2'] %}

{%- set supported = (grains['os_family'] == 'Suse' and grains['osrelease'] in supported_vers) %}

{% if supported %}
# Change the mitigations parameters for the kernel
remove_mitigations:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^GRUB_CMDLINE_LINUX_DEFAULT="(.*?)(?:\s*)mitigations=(?:auto,nosmt|off|auto)(.*?)"
    - repl: GRUB_CMDLINE_LINUX_DEFAULT="\1\2"
    - unless:
      - 'grep "{{ map.cpu_opt.get(selected).get('kernel') }}[ \"]" /etc/default/grub'

add_mitigation_option:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^GRUB_CMDLINE_LINUX_DEFAULT="([^"]*)"
{% if selected == 'Manual' %}
    - repl: GRUB_CMDLINE_LINUX_DEFAULT="\1"
{% else %}
    - repl: GRUB_CMDLINE_LINUX_DEFAULT="\1{{ map.cpu_opt.get(selected).get('kernel') }}"
{% endif %} #manual
    - unless:
      - 'grep "{{ map.cpu_opt.get(selected).get('kernel') }}[ \"]" /etc/default/grub'

# Change the mitigations for the Xen hypervisor if present
{% set xen_bool_false = "\(no\|off\|false\|0\|disable\)" %}
{% set xen_specctrl = map.cpu_opt.get(selected).get('xen').get('spec-ctrl', True) %}
remove_xen_specctrl:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^GRUB_CMDLINE_XEN="(.*?)(?:\s*) (?:no)?spec-ctrl(?:=(?:no|off|false|0|disable))(.*?)"
    - repl: GRUB_CMDLINE_XEN="\1\2"
    - onlyif:
      - 'test "True" == "{{ xen_specctrl }}" && grep "GRUB_CMDLINE_XEN=.*nospec-ctrl\|spec-ctrl={{ xen_bool_false }}" /etc/default/grub && test -e /boot/xen.gz'

{% set xen_smt = map.cpu_opt.get(selected).get('xen').get('smt', True) %}
remove_xen_smt:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^GRUB_CMDLINE_XEN="(.*?)(?:\s*) (?:no)?smt(?:=(?:no|off|false|0|disable))(.*?)"
    - repl: GRUB_CMDLINE_XEN="\1\2"
    - onlyif:
      - 'test "True" == "{{ xen_smt }}" && grep "GRUB_CMDLINE_XEN=.*nosmt\|smt={{ xen_bool_false }}" /etc/default/grub && test -e /boot/xen.gz'

add_xen_specctrl_option:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^GRUB_CMDLINE_XEN="([^"]*)"
    - repl: GRUB_CMDLINE_XEN="\1 spec-ctrl=no"
    - onlyif:
      - 'test "False" == "{{ xen_specctrl }}" -a -e /boot/xen.gz'
    - unless:
      - 'grep "GRUB_CMDLINE_XEN=.*nospec-ctrl\|spec-ctrl={{ xen_bool_false }}" /etc/default/grub'

add_xen_smt_option:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^GRUB_CMDLINE_XEN="([^"]*)"
    - repl: GRUB_CMDLINE_XEN="\1 smt=no"
    - onlyif:
      - 'test "False" == "{{ xen_smt }}" -a -e /boot/xen.gz'
    - unless:
      - 'grep "GRUB_CMDLINE_XEN=.*nosmt\|smt={{ xen_bool_false }}" /etc/default/grub'

rebuild_grub_conf:
   cmd.run:
    - name: grub2-mkconfig -o /boot/grub2/grub.cfg
    - onchanges:
      - file: remove_mitigations
      - file: add_mitigation_option
      - file: remove_xen_smt
      - file: remove_xen_specctrl
      - file: add_xen_specctrl_option
      - file: add_xen_smt_option
{% endif %} #supported
