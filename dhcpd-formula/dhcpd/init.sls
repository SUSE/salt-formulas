{% from "dhcpd/map.jinja" import dhcpd with context %}

include:
  - dhcpd.config

{% if dhcpd.server == "kea" %}
kea:
{%- if grains.get('transactional') %}
  cmd.run:
    - name: systemctl enable {{ dhcpd.service }}
{%- else %}
  service.running:
    - name: {{ dhcpd.service }}
    - enable: True
{%- endif %}
    - require:
      - file: /etc/systemd/system/{{ dhcpd.service }}.service
    - require:
      - file: {{ dhcpd.config }}

{% else %}

dhcpd:
  pkg.installed:
    - name: {{ dhcpd.server }}
{% if dhcpd.enable is defined and not dhcpd.enable %}
  service.dead:
    - name: {{ dhcpd.service }}
    - enable: False
{% else %}
  service.running:
    - name: {{ dhcpd.service }}
    - enable: True
    - require:
      - pkg: {{ dhcpd.server }}
    - require:
      - file: {{ dhcpd.config }}
{% endif %}
{% endif %}
