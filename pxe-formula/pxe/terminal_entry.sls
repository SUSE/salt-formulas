# generate pxe configuration for one terminal


{% from "pxe/map.jinja" import cfgmap with context %}

{% for nic, mac in pillar['terminal_hwaddr_interfaces'].items() if nic != 'lo' %}


{{ cfgmap.path_cfg + '/01-' + mac.lower().replace(':', '-') }}:
  file.managed:
    - source: salt://pxe/files/pxecfg.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja

{{ cfgmap.path_cfg + '/01:' + mac.lower() }}.grub2.cfg:
  file.managed:
    - source: salt://pxe/files/pxecfg.grub2.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja

pxe_entries:{{ mac.lower().replace(':', '-') }}:
  grains.present:
    - value: {{ salt['pillar.get']('boot_image', 'default') }}
    - force: True

{% endfor %}
