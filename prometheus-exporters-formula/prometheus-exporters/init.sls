{% from "prometheus-exporters/map.jinja" import exporters with context %}

include:
  - prometheus-exporters.suse-manager
  - prometheus-exporters.sap
