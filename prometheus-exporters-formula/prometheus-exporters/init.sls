{% from "monitoring/map.jinja" import monitoring with context %}

node_exporter:
  pkg.installed:
    - name: {{ monitoring.node_exporter_package }}
  service.running:
    - name: {{ monitoring.node_exporter_service }}
    - enable: True
    - require:
      - pkg: node_exporter

