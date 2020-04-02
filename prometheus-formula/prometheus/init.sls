{% from "prometheus/map.jinja" import prometheus with context %}

{%- if salt['pillar.get']('prometheus:enabled', False) %}
# setup Prometheus
{%- set monitor_server = salt['pillar.get']('prometheus:mgr:monitor_server', False) %}
{%- set alertmanager_service = salt['pillar.get']('prometheus:alerting:alertmanager_service', False) %}
{%- set default_rules = salt['pillar.get']('prometheus:alerting:default_rules', False) %}

install_prometheus:
  pkg.installed:
    - name: {{ prometheus.prometheus_package }}

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

{%- if alertmanager_service %}
alertmanager_running:
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
{%- endif %}

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
