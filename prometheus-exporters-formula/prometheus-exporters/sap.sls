{% from "prometheus-exporters/map.jinja" import exporters with context %}

{% set proxy_enabled = salt['pillar.get']('proxy_enabled') %}


{% set ha_cluster_exporter_enabled = salt['pillar.get']('ha_cluster_exporter:enabled', False) %}
ha_cluster_exporter:
{% if ha_cluster_exporter_enabled %}
# the exporter has no configuration
  pkg.installed:
    - name: {{ exporters.ha_cluster_exporter_package }}
  service.running:
    - name: {{ exporters.ha_cluster_exporter_service }}
    - enable: True
    - require:
      - pkg:  {{ exporters.ha_cluster_exporter_package }}
{% else %}
  service.dead:
    - name: {{ exporters.ha_cluster_exporter_service }}
    - enable: False
{% endif %}

{% if ha_cluster_exporter_enabled and proxy_enabled %}
ha_cluster_exporter_proxy:
  file.managed:
    - name: /etc/exporter_exporter.d/ha_cluster_exporter.yaml
    - source: salt://prometheus-exporters/files/exporter-proxy.yaml
    - template: jinja
    - context:
        module: ha_cluster
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: exporter_exporter
    - watch_in:
      - service: exporter_exporter
{% endif %}
