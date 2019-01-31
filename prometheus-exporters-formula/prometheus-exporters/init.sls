{% from "prometheus-exporters/map.jinja" import exporters with context %}

node_exporter:
  pkg.installed:
    - name: {{ exporters.node_exporter_package }}
  service.running:
    - name: {{ exporters.node_exporter_service }}
    - enable: True
    - require:
      - pkg: node_exporter

