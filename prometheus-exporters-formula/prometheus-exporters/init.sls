{% from "prometheus-exporters/map.jinja" import exporters with context %}

{% set proxy_enabled = salt['pillar.get']('proxy_enabled') %}
{% set proxy_supported = 'exporter_exporter_package' in exporters and exporters.exporter_exporter_package %}
{% set tls_enabled = salt['pillar.get']('tls:enabled', False) %}
{% set web_config_file = '/etc/prometheus/exporters/web.yml' %}

{% if tls_enabled %}
web_config:
  file.managed:
    - name: {{ web_config_file }}
    - source: salt://prometheus-exporters/files/web.yml
    - template: jinja
    - makedirs: True
    - user: prometheus
    - group: prometheus
    - mode: 644
    - watch_in:
      - service: node_exporter
{% endif %}

{% if proxy_supported and proxy_enabled and grains['os_family'] == 'Debian' %}
exporter_exporter_conf_dir:
  file.directory:
    - name: /etc/exporter_exporter.d
    - user: root
    - group: root
    - mode: 755
{% endif %}

{% if proxy_supported %}
exporter_exporter:
  {% if proxy_enabled %}
  pkg.installed:
    - name: {{ exporters.exporter_exporter_package }}
  file.managed:
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: exporter_exporter
    - watch_in:
      - service: exporter_exporter
    - names:
      - {{ exporters.exporter_exporter_service_config }}:
        - source: {{ 'salt://prometheus-exporters/files/exporter-exporter-config.' ~ salt['grains.get']('os_family') }}
  {% if grains['os_family'] == 'Debian' %}
      - /etc/exporter_exporter.yaml:
        - source: salt://prometheus-exporters/files/exporter-exporter.yaml
  {% endif %}
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

{% set node_exporter_enabled = salt['pillar.get']('exporters:node_exporter:enabled', True) %}
node_exporter:
{% if node_exporter_enabled %}
  {% set node_exporter_args = salt['pillar.get']('exporters:node_exporter:args') %}
  {% set node_exporter_address = salt['pillar.get']('exporters:node_exporter:address') %}
  {% if node_exporter_args is none %}
    {% set node_exporter_args = '' %}
  {% endif %}
  {% if node_exporter_address and '-web.listen-address' not in node_exporter_args %}
    {% set node_exporter_args = node_exporter_args ~ ' --web.listen-address=' ~ node_exporter_address %}
  {% endif %}
  {% if tls_enabled %}
    {% set node_exporter_version = salt['pkg.version'](exporters.node_exporter_package) %}
    {% if not node_exporter_version %}
      {% set node_exporter_version = salt['pkg.latest_version'](exporters.node_exporter_package) %}
    {% endif %}
    {% if salt['pkg.version_cmp'](node_exporter_version, '1.5.0') >= 0 %}
        {% set node_exporter_args = node_exporter_args ~ ' --web.config.file=' ~ web_config_file %}
    {% else %}
        {% set node_exporter_args = node_exporter_args ~ ' --web.config=' ~ web_config_file %}
    {% endif %}
  {% endif %}
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
      - name: /etc/exporter_exporter.d/node_exporter.yaml
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

{% set apache_exporter_enabled = salt['pillar.get']('exporters:apache_exporter:enabled', False) %}
apache_exporter:
{% if apache_exporter_enabled %}
  {% set apache_exporter_version = salt['pkg.latest_version'](exporters.apache_exporter_package) %}
  {% if not apache_exporter_version %}
    {% set apache_exporter_version = salt['pkg.version'](exporters.apache_exporter_package) %}
  {% endif %}
  {% set apache_exporter_args = salt['pillar.get']('exporters:apache_exporter:args') %}
  {% if apache_exporter_args is none %}
    {% set apache_exporter_args = '' %}
  {% endif %}
  {% set apache_exporter_address = salt['pillar.get']('exporters:apache_exporter:address') %}
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
  {% if salt['pkg.version_cmp'](apache_exporter_version, '1.0.0') >= 0 %}
    {% if apache_exporter_address and '--web.listen-address' not in apache_exporter_args %}
    - context:
        args: {{ apache_exporter_args ~ ' --web.listen-address=' ~ apache_exporter_address }}
    {% endif %}
  {% else %}
    {% if apache_exporter_address and '-telemetry.address' not in apache_exporter_args %}
    - context:
        args: {{ apache_exporter_args ~ ' --telemetry.address=' ~ apache_exporter_address }}
    {% endif %}
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
    - name: /etc/exporter_exporter.d/apache_exporter.yaml
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

{% set postgres_exporter_enabled = salt['pillar.get']('exporters:postgres_exporter:enabled', False) %}
postgres_exporter:
{% if postgres_exporter_enabled %}
  {% set postgres_exporter_args = salt['pillar.get']('exporters:postgres_exporter:args') %}
  {% if postgres_exporter_args is none %}
    {% set postgres_exporter_args = '' %}
  {% endif %}
  {% set postgres_exporter_address = salt['pillar.get']('exporters:postgres_exporter:address') %}
  pkg.installed:
    - name: {{ exporters.postgres_exporter_package }}
  file.managed:
    - names:
      - {{ exporters.postgres_exporter_service_config }}:
        - source: {{ 'salt://prometheus-exporters/files/postgres-exporter-config.' ~ salt['grains.get']('os_family') }}
      - {{ exporters.postgres_exporter_password_file }}:
        - source: salt://prometheus-exporters/files/postgres-exporter-password
        - user: prometheus
        - mode: 600
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - defaults:
        args: {{ postgres_exporter_args }}
  {%- if exporters.postgres_exporter_password_file %}
        password_file: {{ exporters.postgres_exporter_password_file }}
  {%- endif %}
  {% if postgres_exporter_address and '-web.listen-address' not in postgres_exporter_args %}
    - context:
        args: {{ postgres_exporter_args ~' --web.listen-address=' ~ postgres_exporter_address }}
  {% endif %}
    - require:
      - pkg: postgres_exporter
    - watch_in:
      - service: postgres_exporter
  module.run:
    - name: service.systemctl_reload
    - onchanges_any:
      - file: {{ exporters.postgres_exporter_service_config }}
      - file: {{ exporters.postgres_exporter_password_file }}
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
    - name: /etc/exporter_exporter.d/postgres_exporter.yaml
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
