Prometheus formula
==================

This formula installs and configures _Prometheus_, _Alertmanager_ and _Blackbox
exporter_ for _Uyuni_ and _SUSE Manager_.

Currently only _openSUSE_ and _SUSE Linux Enterprise Server_ are supported. Users can
however adapt the formula by setting following pillar values according to package and
service names for their distribution:

```yaml
prometheus:
  lookup:
    prometheus_package: golang-github-prometheus-prometheus
    alertmanager_package: golang-github-prometheus-alertmanager
    blackbox_exporter_package: prometheus-blackbox_exporter
    prometheus_service: prometheus
    alertmanager_service: prometheus-alertmanager
    blackbox_exporter_service: prometheus-blackbox_exporter
    blackbox_exporter_service_config: /etc/systemd/system/prometheus-blackbox_exporter.service.d/uyuni.conf
    prometheus_config: salt://prometheus/files/prometheus.yml
```
