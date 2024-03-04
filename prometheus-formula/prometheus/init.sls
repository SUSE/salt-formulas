{% from "prometheus/map.jinja" import prometheus with context %}

{%- if prometheus %}
{%- if salt['pillar.get']('prometheus:enabled', False) %}
{%- set alertmanager_enabled = salt['pillar.get']('prometheus:alerting:alertmanager_service', False) %}
# setup Prometheus
{%- set monitor_server = salt['pillar.get']('prometheus:mgr:monitor_server', False) %}
{%- set alertmanager_service = salt['pillar.get']('prometheus:alerting:alertmanager_service', False) %}
{%- set default_rules = salt['pillar.get']('prometheus:alerting:default_rules', False) %}
{%- set uyuni_server_hostname = salt['pillar.get']('mgr_origin_server', grains['master'])%}
{%- set tls_enabled = salt['pillar.get']('prometheus:tls:enabled', False) %}
{%- set remote_write_receiver_enabled = salt['pillar.get']('prometheus:remote_write:is_receiver', False) %}
{%  set prometheus_web_config_file = '/etc/prometheus/web.yml' %}
{%  set blackbox_exporter_web_config_file = '/etc/prometheus/exporters/blackbox-web.yml' %}


{% set podman_version = salt['pkg.latest_version']('podman') %}
{% if not podman_version %}
  {% set podman_version = salt['pkg.version']('podman') %}
{% endif %}
{% set use_podman = salt['pkg.version_cmp'](podman_version, '4.4.0') >= 0 %}
{% if use_podman %}
install_podman:
  pkg.installed:
    - name: podman

include:
  - prometheus/uninstall_packages

{% else %}
install_prometheus:
  pkg.installed:
    - name: {{ prometheus.prometheus_package }}

{%- if alertmanager_enabled %}
install_alertmanager:
  pkg.installed:
    - name: {{ prometheus.alertmanager_package }}
{% endif %}
{% endif %}


{% set firewall_active = salt['service.available']('firewalld') and salt['service.status']('firewalld') %}
{% if firewall_active %}
firewall_prometheus:
  firewalld.present:
    - name: public
    - prune_services: False
    - services:
      - prometheus
{% endif %}

{% set prometheus_version = salt['pkg.latest_version'](prometheus.prometheus_package) %}
{% if not prometheus_version %}
  {% set prometheus_version = salt['pkg.version'](prometheus.prometheus_package) %}
{% endif %}
{% if salt['pkg.version_cmp'](prometheus_version, '2.31.0') >= 0 or use_podman %}
  {% set prometheus_config_template = prometheus.prometheus_config %}
{% else %}
  {% set prometheus_config_template = prometheus.prometheus_config_old %}
{% endif %}
config_file:
  file.managed:
    - name: /etc/prometheus/prometheus.yml
    - source: {{ prometheus_config_template }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
      uyuni_server_hostname: {{ uyuni_server_hostname }}

{% if tls_enabled %}
prometheus_web_config:
  file.managed:
    - name: {{ prometheus_web_config_file }}
    - source: salt://prometheus/files/web.yml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
{% endif %}

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
    - defaults:
      uyuni_server_hostname: {{ uyuni_server_hostname }}
{%- endif %}

{%- if use_podman %}
prometheus_container_running:
  file.managed:
    - names:
      - /etc/containers/systemd/prometheus.container:
        - source: salt://prometheus/files/containers/prometheus.container
      - /etc/containers/systemd/prometheus.volume:
        - source: salt://prometheus/files/containers/prometheus.volume
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
      web_config_file: {{ prometheus_web_config_file }}
      enable_receiver: {{ remote_write_receiver_enabled }}      
  module.run:
    - name: service.systemctl_reload
  service.running:
    - name: {{ prometheus.prometheus_service }}
    - enable: true
    - watch:
      - file: /etc/containers/systemd/prometheus.*
      - file: config_file
{% if tls_enabled %}
      - file: prometheus_web_config
{% endif %}
{% if default_rules %}
      - file: default_rule_files
{% endif %}

{% else %}
prometheus_running:
  file.managed:
    - name: /etc/systemd/system/prometheus.service.d/uyuni.conf
    - source: salt://prometheus/files/prometheus-service.conf
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - defaults:
        args: ''
        enable_receiver: ''
    - context:
{% if tls_enabled %}
        args: {{ ' --web.config.file=' ~ prometheus_web_config_file }}
{% endif %}
{% if remote_write_receiver_enabled %}
        enable_receiver: {{ ' --web.enable-remote-write-receiver' }}
{% endif %}
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
      - file: /etc/systemd/system/prometheus.service.d/uyuni.conf
{% if tls_enabled %}
      - file: prometheus_web_config
{% endif %}
{% if default_rules %}
      - file: default_rule_files
{% endif %}
{%- if monitor_server %}
      - file: mgr_scrape_config_file
{%- endif %}
{% endif %}

{% if alertmanager_enabled %}
alertmanager_config_file:
  file.managed:
    - name: /etc/prometheus/alertmanager.yml
    - source: salt://prometheus/files/alertmanager.yml
    - user: root
    - group: root
    - mode: 644

{%- if use_podman %}
alertmanager_container_running:
{% if alertmanager_service %}
  file.managed:
    - names:
      - /etc/containers/systemd/alertmanager.container:
        - source: salt://prometheus/files/containers/alertmanager.container
      - /etc/containers/systemd/alertmanager.volume:
        - source: salt://prometheus/files/containers/alertmanager.volume
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
      web_config_file: {{ prometheus_web_config_file }}
  module.run:
    - name: service.systemctl_reload
  service.running:
    - name: alertmanager
    - enable: true
    - watch:
      - file: /etc/containers/systemd/alertmanager.*
{% if tls_enabled %}
      - file: prometheus_web_config
{%- endif %}
{% else %}
  service.dead:
    - name: alertmanager
    - enable: False
  file.absent:
    - names:
      - /etc/containers/systemd/alertmanager.container
      - /etc/containers/systemd/alertmanager.volume
  module.run:
    - name: service.systemctl_reload
{% endif %}

{%- else %}
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
{% endif %}

{% if firewall_active %}
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
{% endif %}

{% set blackbox_exporter_enabled = salt['pillar.get']('prometheus:blackbox_exporter:enabled', False) %}
{%- if blackbox_exporter_enabled %}
blackbox_exporter_config_file:
  file.managed:
    - name: /etc/prometheus/blackbox.yml
    - source: salt://prometheus/files/blackbox.yml
    - user: root
    - group: root
    - mode: 644

{% if tls_enabled %}
blackbox_exporter_web_config:
  file.managed:
    - name: {{ blackbox_exporter_web_config_file }}
    - source: salt://prometheus/files/blackbox-web.yml
    - template: jinja
    - makedirs: True
    - user: prometheus
    - group: prometheus
    - mode: 644
    - watch_in:
      - service: blackbox_exporter
{% endif %}
{% endif %}

{%- if use_podman %}
blackbox_exporter_container:
{%- if blackbox_exporter_enabled %}
  file.managed:
    - name: /etc/containers/systemd/blackbox_exporter.container
    - source: salt://prometheus/files/containers/blackbox_exporter.container
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
      web_config_file: {{ blackbox_exporter_web_config_file }}
  module.run:
    - name: service.systemctl_reload
  service.running:
    - name: blackbox_exporter
    - enable: true
    - watch:
      - file: /etc/containers/systemd/blackbox_exporter.container
{% if tls_enabled %}
      - file: {{ blackbox_exporter_web_config_file }}
{%- endif %}
{% else %}
  service.dead:
    - name: blackbox_exporter
    - enable: False
  file.absent:
    - name: /etc/containers/systemd/blackbox_exporter.container
  module.run:
    - name: service.systemctl_reload
{% endif %}

{% else %}
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
    {% set blackbox_exporter_args = blackbox_exporter_args ~ ' --web.config.file=' ~ blackbox_exporter_web_config_file %}
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
{% endif %}

{%- else %}
# remove prometheus
include:
  - prometheus/uninstall_packages

/etc/prometheus:
  file.absent:
    - require:
      - pkg: remove_prometheus
      - pkg: remove_alertmanager

{%- endif %}
{%- endif %}
