{% from "prometheus-exporters/map.jinja" import exporters with context %}

node_exporter:
  pkg.installed:
    - name: {{ exporters.node_exporter_package }}
{% if salt['pillar.get']('node_exporter:node_exporter_enabled', True) %}
  service.running:
    - name: {{ exporters.node_exporter_service }}
    - enable: True
    - require:
      - pkg: node_exporter
{% else %}
  service.dead:
    - name: {{ exporters.node_exporter_service }}
    - enable: False
{% endif %}

