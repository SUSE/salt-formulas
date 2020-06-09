{% from "prometheus-exporters/map.jinja" import exporters with context %}

{% set proxy_enabled = salt['pillar.get']('proxy_enabled') %}

exporter_exporter:
{% if proxy_enabled %}
  pkg.installed:
    - name: {{ exporters.exporter_exporter_package }}
  file.managed:
    - name: {{ exporters.exporter_exporter_service_config }}
    - source: {{ 'salt://prometheus-exporters/files/exporter-exporter-config.'
        ~ salt['grains.get']('os_family') }}
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: exporter_exporter
    - watch_in:
      - service: exporter_exporter
  service.running:
    - name: {{ exporters.exporter_exporter_service }}
    - enable: True
    - require:
      - file: exporter_exporter
{% else %}
  service.dead:
    - name: {{ exporters.exporter_exporter_service }}
    - enable: False
{% endif %}

{% set node_exporter_enabled =
  salt['pillar.get']('node_exporter:enabled', True) %}
node_exporter:
{% if node_exporter_enabled %}
  pkg.installed:
    - name: {{ exporters.node_exporter_package }}
  file.managed:
    - name: {{ exporters.node_exporter_service_config }}
    - source: {{ 'salt://prometheus-exporters/files/node-exporter-config.' ~
        salt['grains.get']('os_family') }}
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

{% if node_exporter_enabled and proxy_enabled %}
node_exporter_proxy:
    file.managed:
      - name: /etc/exporter_exporter.d/node.yaml
      - source: salt://prometheus-exporters/files/exporter-proxy.yaml
      - template: jinja
      - context:
          module: node
      - user: root
      - group: root
      - mode: 644
      - require:
        - pkg: exporter_exporter
      - watch_in:
        - service: exporter_exporter
{% endif %}

{% set apache_exporter_enabled =
  salt['pillar.get']('apache_exporter:enabled', False) %}
apache_exporter:
{% if apache_exporter_enabled %}
  pkg.installed:
    - name: {{ exporters.apache_exporter_package }}
  file.managed:
    - name: {{ exporters.apache_exporter_service_config }}
    - source: {{ 'salt://prometheus-exporters/files/apache-exporter-config.' ~
        salt['grains.get']('os_family') }}
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

{% if apache_exporter_enabled and proxy_enabled %}
apache_exporter_proxy:
  file.managed:
    - name: /etc/exporter_exporter.d/apache.yaml
    - source: salt://prometheus-exporters/files/exporter-proxy.yaml
    - template: jinja
    - context:
        module: apache
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: exporter_exporter
    - watch_in:
      - service: exporter_exporter
{% endif %}

{% set postgres_exporter_enabled =
  salt['pillar.get']('postgres_exporter:enabled', False) %}
postgres_exporter:
{% if postgres_exporter_enabled %}
  pkg.installed:
    - name: {{ exporters.postgres_exporter_package }}
  file.managed:
    - name: {{ exporters.postgres_exporter_service_config }}
    - source: {{ 'salt://prometheus-exporters/files/postgres-exporter-config.'
        ~ salt['grains.get']('os_family') }}
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

{% if postgres_exporter_enabled and proxy_enabled %}
postgres_exporter_proxy:
  file.managed:
    - name: /etc/exporter_exporter.d/postgres.yaml
    - source: salt://prometheus-exporters/files/exporter-proxy.yaml
    - template: jinja
    - context:
        module: postgres
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: exporter_exporter
    - watch_in:
      - service: exporter_exporter
{% endif %}
