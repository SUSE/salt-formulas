{% from "prometheus-exporters/map.jinja" import exporters with context %}

{% if salt['pillar.get']('node_exporter:enabled', False) %}
node_exporter_config:
  file.managed:
    - name: {{ exporters.node_exporter_service_config }}
    - source: {{ 'salt://prometheus-exporters/files/node-exporter-config' }}
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: {{ exporters.node_exporter_service }}
{% endif %}

{% if salt['pillar.get']('postgres_exporter:enabled', False) %}
postgres_exporter_config:
  file.managed:
    - name: {{ exporters.postgres_exporter_service_config }}
    - source: {{ 'salt://prometheus-exporters/files/postgres-exporter-config' }}
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: {{ exporters.postgres_exporter_service }}
{% endif %}

