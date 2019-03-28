{% from "prometheus-exporters/map.jinja" import exporters with context %}

include:
  - prometheus-exporters.config

node_exporter:
  pkg.installed:
    - name: {{ exporters.node_exporter_package }}
{% if salt['pillar.get']('node_exporter:enabled', True) %}
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

postgres_exporter:
  pkg.installed:
    - name: {{ exporters.postgres_exporter_package }}
{% if salt['pillar.get']('postgres_exporter:enabled', False) %}
  service.running:
    - name: {{ exporters.postgres_exporter_service }}
    - enable: True
    - require:
      - pkg: postgres_exporter
{% else %}
  service.dead:
    - name: {{ exporters.postgres_exporter_service }}
    - enable: False
{% endif %}

