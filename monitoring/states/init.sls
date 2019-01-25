node_exporter:
  pkg.installed:
    - name: golang-github-prometheus-node_exporter
  service.running:
    - name: prometheus-node_exporter
    - enable: True
    - require:
      - pkg: node_exporter

