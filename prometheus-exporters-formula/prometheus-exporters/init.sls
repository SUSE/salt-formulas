{% from "prometheus-exporters/map.jinja" import exporters with context %}

node_exporter:
{% if salt['pillar.get']('node_exporter:enabled', True) %}
  pkg.installed:
    - name: {{ exporters.node_exporter_package }}
  file.managed:
    - name: {{ exporters.node_exporter_service_config }}
    - source: {{ 'salt://prometheus-exporters/files/node-exporter-config.' ~ salt['grains.get']('os_family') }}
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: node_exporter
    - watch_in:
      - service: node_exporter
  service.running:
    - name: {{ exporters.node_exporter_service }}
    - enable: True
    - require:
      - file: node_exporter
{% else %}
  service.dead:
    - name: {{ exporters.node_exporter_service }}
    - enable: False
{% endif %}

apache_exporter:
{% if salt['pillar.get']('apache_exporter:enabled', False) %}
  pkg.installed:
    - name: {{ exporters.apache_exporter_package }}
  file.managed:
    - name: {{ exporters.apache_exporter_service_config }}
    - source: {{ 'salt://prometheus-exporters/files/apache-exporter-config.' ~ salt['grains.get']('os_family') }}
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache_exporter
    - watch_in:
      - service: apache_exporter
  service.running:
    - name: {{ exporters.apache_exporter_service }}
    - enable: True
    - require:
      - file: apache_exporter
{% else %}
  service.dead:
    - name: {{ exporters.apache_exporter_service }}
    - enable: False
{% endif %}

postgres_exporter:
{% if salt['pillar.get']('postgres_exporter:enabled', False) %}
  pkg.installed:
    - name: {{ exporters.postgres_exporter_package }}
  file.managed:
    - name: {{ exporters.postgres_exporter_service_config }}
    - source: {{ 'salt://prometheus-exporters/files/postgres-exporter-config.' ~ salt['grains.get']('os_family') }}
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: postgres_exporter
    - watch_in:
      - service: postgres_exporter
  service.running:
    - name: {{ exporters.postgres_exporter_service }}
    - enable: True
    - require:
      - file: postgres_exporter
{% else %}
  service.dead:
    - name: {{ exporters.postgres_exporter_service }}
    - enable: False
{% endif %}
