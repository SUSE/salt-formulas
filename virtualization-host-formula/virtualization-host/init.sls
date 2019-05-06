{% from "virtualization-host/map.jinja" import packages with context %}

virthost_packages:
  pkg.installed:
    - pkgs: {{ packages }}

libvirtd_service:
  service.running:
    - name: libvirtd
    - enable: True
    - require:
      - pkg: virthost_packages
