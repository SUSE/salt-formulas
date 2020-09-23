{% from "prometheus-exporters/map.jinja" import exporters with context %}

{% set proxy_enabled = salt['pillar.get']('proxy_enabled') %}
{% set proxy_supported = 'exporter_exporter_package' in exporters and exporters.exporter_exporter_package %}

{% if proxy_supported %}
exporter_exporter:
  {% if proxy_enabled %}
  pkg.installed:
    - name: {{ exporters.exporter_exporter_package }}
  file.managed:
    - name: {{ exporters.exporter_exporter_service_config }}
    - source: {{ 'salt://prometheus-exporters/files/exporter-exporter-config.' ~ salt['grains.get']('os_family') }}
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
{% endif %}

{% set node_exporter_enabled = salt['pillar.get']('node_exporter:enabled', True) %}
node_exporter:
{% if node_exporter_enabled %}
  {% set node_exporter_args = salt['pillar.get']('node_exporter:args', '') %}
  {% set node_exporter_address = salt['pillar.get']('node_exporter:address') %}
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
    - defaults:
        args: {{ node_exporter_args }}
  {% if node_exporter_address and '-web.listen-address' not in node_exporter_args %}
    - context:
        args: {{ node_exporter_args ~ ' --web.listen-address=' ~ node_exporter_address }}
  {% endif %}
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

{% if node_exporter_enabled and proxy_enabled and proxy_supported %}
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

{% set apache_exporter_enabled = salt['pillar.get']('apache_exporter:enabled', False) %}
apache_exporter:
{% if apache_exporter_enabled %}
  {% set apache_exporter_args = salt['pillar.get']('apache_exporter:args', '') %}
  {% set apache_exporter_address = salt['pillar.get']('apache_exporter:address') %}
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
    - defaults:
        args: {{ apache_exporter_args }}
  {% if apache_exporter_address and '-telemetry.address' not in apache_exporter_args %}
    - context:
        args: {{ apache_exporter_args ~ ' --telemetry.address=' ~ apache_exporter_address }}
  {% endif %}
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

{% if apache_exporter_enabled and proxy_enabled and proxy_supported %}
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

{% set postgres_exporter_enabled = salt['pillar.get']('postgres_exporter:enabled', False) %}
postgres_exporter:
{% if postgres_exporter_enabled %}
  {% set postgres_exporter_args = salt['pillar.get']('postgres_exporter:args', '') %}
  {% set postgres_exporter_address = salt['pillar.get']('postgres_exporter:address') %}
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
    - defaults:
        args: {{ postgres_exporter_args }}
  {% if postgres_exporter_address and '-web.listen-address' not in postgres_exporter_args %}
    - context:
        args: {{ postgres_exporter_args ~' --web.listen-address=' ~ postgres_exporter_address }}
  {% endif %}
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

{% if postgres_exporter_enabled and proxy_enabled and proxy_supported %}
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
