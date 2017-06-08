{% from "dhcpd/map.jinja" import dhcpd with context %}

include:
  - dhcpd.config

dhcpd:
  pkg.installed:
    - name: {{ dhcpd.server }}
  service.running:
    - name: {{ dhcpd.service }}
    - enable: True
    - require:
      - pkg: dhcpd
