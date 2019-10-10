{% from "prometheus-server/map.jinja" import prometheus with context %}

{%- set monitor_server = pillar.get('prometheus:mgr:monitor_server', False) %}
{%- set alertmanager_service = pillar.get('prometheus:alerting:alertmanager_service', False) %}

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
{%- if monitor_server %}
      - file: mgr_scrape_config_file
{%- endif %}
    - watch:
      - file: config_file
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