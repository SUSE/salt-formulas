{% from "prometheus/map.jinja" import prometheus with context %}

{%- if salt['pillar.get']('prometheus:enabled', False) %}
# setup Prometheus
{%- set monitor_server = salt['pillar.get']('prometheus:mgr:monitor_server', False) %}
{%- set alertmanager_service = salt['pillar.get']('prometheus:alerting:alertmanager_service', False) %}
{%- set default_rules = salt['pillar.get']('prometheus:alerting:default_rules', False) %}
{%- set uyuni_server_hostname = salt['pillar.get']('mgr_origin_server', grains['master'])%}

install_prometheus:
  pkg.installed:
    - name: {{ prometheus.prometheus_package }}

{% if grains['install_proxy_pattern'] %}
firewall_prometheus:
  firewalld.present:
    - name: public
    - prune_services: False
    - services:
      - prometheus
{% endif %}

install_alertmanager:
  pkg.installed:
    - name: {{ prometheus.alertmanager_package }}

config_file:
  file.managed:
    - name: /etc/prometheus/prometheus.yml
    - source: salt://prometheus/files/prometheus.yml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: install_prometheus
      - pkg: install_alertmanager
    - defaults:
      uyuni_server_hostname: {{ uyuni_server_hostname }}

{% if default_rules %}
default_rule_files:
  file.managed:
    - names:
      - /etc/prometheus/rules/prometheus-rules.yml:
        - source: salt://prometheus/files/prometheus-rules.yml
      - /etc/prometheus/rules/general-rules.yml:
        - source: salt://prometheus/files/general-rules.yml
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - require:
      - pkg: install_prometheus
      - pkg: install_alertmanager
{% endif %}

{%- if monitor_server %}
mgr_scrape_config_file:
  file.managed:
    - name: /etc/prometheus/mgr-scrape-config/mgr-server.yml
    - source: salt://prometheus/files/mgr-server.yml
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - require:
      - pkg: install_prometheus
      - pkg: install_alertmanager
    - defaults:
      uyuni_server_hostname: {{ uyuni_server_hostname }}
{%- endif %}

prometheus_running:
  service.running:
    - name: {{ prometheus.prometheus_service }}
    - enable: True
    - require:
      - file: config_file
{% if default_rules %}
      - file: default_rule_files
{% endif %}
{%- if monitor_server %}
      - file: mgr_scrape_config_file
{%- endif %}
    - watch:
      - file: config_file
{% if default_rules %}
      - file: default_rule_files
{% endif %}
{%- if monitor_server %}
      - file: mgr_scrape_config_file
{%- endif %}

alertmanager_running:
{% if alertmanager_service %}
  file.managed:
    - name: /etc/systemd/system/prometheus-alertmanager.service.d/uyuni.conf
    - source: salt://prometheus/files/alertmanager-service.conf
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
  service.running:
    - name: {{ prometheus.alertmanager_service }}
    - enable: True
    - require:
      - file: config_file
    - watch:
      - file: config_file
{%- if monitor_server %}
      - file: mgr_scrape_config_file
{%- endif %}
{% else %}
  file.absent:
    - name: /etc/systemd/system/prometheus-alertmanager.service.d
  service.dead:
    - name: {{ prometheus.alertmanager_service }}
    - enable: False
{%- endif %}

{% set blackbox_exporter_enabled = salt['pillar.get']('prometheus:blackbox_exporter:enabled', False) %}
blackbox_exporter:
{% if blackbox_exporter_enabled %}
  {% set blackbox_exporter_args = salt['pillar.get']('prometheus:blackbox_exporter:args') %}
  {% set blackbox_exporter_address = salt['pillar.get']('prometheus:blackbox_exporter:address') %}
  {% if blackbox_exporter_args is none %}
    {% set blackbox_exporter_args = '--config.file /etc/prometheus/blackbox.yml' %}
  {% endif %}
  {% if blackbox_exporter_address and '--web.listen-address' not in blackbox_exporter_args %}
    {% set blackbox_exporter_args = blackbox_exporter_args ~ ' --web.listen-address=' ~ blackbox_exporter_address %}
  {% endif %}
  {% if tls_enabled %}
    {% set blackbox_exporter_args = blackbox_exporter_args ~ ' --web.config.file=' ~ prometheus_web_config_file %}
  {% endif %}
  pkg.installed:
    - name: {{ prometheus.blackbox_exporter_package }}
  file.managed:
    - name: {{ prometheus.blackbox_exporter_service_config }}
    - source: {{ 'salt://prometheus/files/blackbox_exporter-service.conf' }}
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - defaults:
        args: {{ blackbox_exporter_args }}
    - require:
      - pkg: blackbox_exporter
    - watch_in:
      - service: blackbox_exporter
  service.running:
    - name: {{ prometheus.blackbox_exporter_service }}
    - enable: True
    - require:
      - file: blackbox_exporter
{% else %}
  service.dead:
    - name: {{ prometheus.blackbox_exporter_service }}
    - enable: False
{% endif %}

{% if alertmanager_service and grains['install_proxy_pattern'] %}
alertmanager_service:
  firewalld.service:
    - name: prometheus-alertmanager
    - ports:
      - 9093/tcp

firewall_alertmanager:
  firewalld.present:
    - name: public
    - prune_services: False
    - services:
      - prometheus-alertmanager
{% endif %}

{%- else %}
# remove prometheus
remove_prometheus:
  pkg.removed:
    - name: {{ prometheus.prometheus_package }}

remove_alertmanager:
  pkg.removed:
    - name: {{ prometheus.alertmanager_package }}

/etc/prometheus:
  file.absent:
    - require:
      - pkg: remove_prometheus
      - pkg: remove_alertmanager

{%- endif %}
