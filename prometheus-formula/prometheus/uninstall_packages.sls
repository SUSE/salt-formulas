{% from "prometheus/map.jinja" import prometheus with context %}

remove_prometheus_packages:
  pkg.removed:
    - pkgs:
      - {{ prometheus.prometheus_package }}
      - {{ prometheus.alertmanager_package }}
      - {{ prometheus.blackbox_exporter_package }}
