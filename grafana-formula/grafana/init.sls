# check for supported os version
{%- set supported_vers = ['42.3', '12.3', '12.4', '12.5', '15.0', '15.1', '15.2', '15.3', '15.4', '15.5', '15.6'] %}

# check if supported
{%- if (grains['os_family'] == 'Suse' and grains['osrelease'] in supported_vers) %}
  {%- if not (salt['pkg.version']('patterns-uyuni_proxy') or salt['pkg.version']('patterns-suma_proxy') or salt['pkg.version']('patterns-suma_retail') or salt['pkg.version']('patterns-uyuni_retail')) %}
    {%- set supported = True %}
  {%- else %}
    os_not_supported:
      test.fail_without_changes:
        - name: "OS not supported!"
  {%- endif %}
{%- endif %}

{%- if supported %}
{%- if salt['pillar.get']('grafana:enabled', False) %}
{%- if salt['pillar.get']('mgr_server_is_uyuni', True) %}
  {% set product_name = 'Uyuni' %}
{%- else %}
  {% set product_name = 'SUSE Manager' %}
{%- endif %}

{% set podman_version = salt['pkg.latest_version']('podman') %}
{% if not podman_version %}
  {% set podman_version = salt['pkg.version']('podman') %}
{% endif %}
{% set use_podman = salt['pkg.version_cmp'](podman_version, '4.4.0') >= 0 %}

{% if use_podman %}
install_podman_for_grafana:
  pkg.installed:
    - name: podman

uninstall_grafana_package:
  pkg.removed:
    - name: grafana
{% endif %}

# setup and enable service
/etc/grafana/grafana.ini:
  file.managed:
    - source: salt://grafana/files/grafana.ini
    - makedirs: True
    - template: jinja


/etc/grafana/provisioning/datasources/datasources.yml:
  file.managed:
    - source: salt://grafana/files/datasources.yml
    - makedirs: True
    - template: jinja

/etc/grafana/provisioning/dashboards/dashboard-provider.yml:
  file.managed:
    - source: "salt://grafana/files/dashboard-provider.yml"
    - makedirs: True

{%- if salt['pillar.get']('grafana:dashboards:add_uyuni_dashboard', False) %}
/etc/grafana/provisioning/dashboards/mgr-server.json:
  file.managed:
    - source: "salt://grafana/files/mgr-server.json.jinja"
    - makedirs: True
    - template: jinja
    - defaults:
      product_name: {{ product_name }}
{%- else %}
/etc/grafana/provisioning/dashboards/mgr-server.json:
  file.absent
{%- endif %}

{%- if salt['pillar.get']('grafana:dashboards:add_uyuni_clients_dashboard', False) %}
/etc/grafana/provisioning/dashboards/mgr-client-systems.json:
  file.managed:
    - source: "salt://grafana/files/mgr-client-systems.json.jinja"
    - makedirs: True
    - template: jinja
    - defaults:
      product_name: {{ product_name }}
{%- else %}
/etc/grafana/provisioning/dashboards/mgr-client-systems.json:
  file.absent
{%- endif %}

{%- if salt['pillar.get']('grafana:dashboards:add_postgresql_dasboard', False) %}
/etc/grafana/provisioning/dashboards/mgr-postgresql.json:
  file.managed:
    - source: "salt://grafana/files/mgr-postgresql.json"
    - makedirs: True
{%- else %}
/etc/grafana/provisioning/dashboards/mgr-postgresql.json:
  file.absent
{%- endif %}

{%- if salt['pillar.get']('grafana:dashboards:add_apache_dashboard', False) %}
/etc/grafana/provisioning/dashboards/mgr-apache.json:
  file.managed:
    - source: "salt://grafana/files/mgr-apache.json"
    - makedirs: True
{%- else %}
/etc/grafana/provisioning/dashboards/mgr-apache.json:
  file.absent
{%- endif %}

{%- if salt['pillar.get']('grafana:dashboards:kubernetes:add_k8s_dashboard', False) %}
/etc/grafana/provisioning/dashboards/caasp-cluster.json:
  file.managed:
    - source: "salt://grafana/files/caasp-cluster.json"
    - makedirs: True
{%- else %}
/etc/grafana/provisioning/dashboards/caasp-cluster.json:
  file.absent
{%- endif %}

{%- if salt['pillar.get']('grafana:dashboards:kubernetes:add_etcd_dashboard', False) %}
/etc/grafana/provisioning/dashboards/caasp-etcd-cluster.json:
  file.managed:
    - source: "salt://grafana/files/caasp-etcd-cluster.json"
    - makedirs: True
{%- else %}
/etc/grafana/provisioning/dashboards/caasp-etcd-cluster.json:
  file.absent
{%- endif %}

{%- if salt['pillar.get']('grafana:dashboards:kubernetes:add_k8s_namespaces_dashboard', False) %}
/etc/grafana/provisioning/dashboards/caasp-namespaces.json:
  file.managed:
    - source: "salt://grafana/files/caasp-namespaces.json"
    - makedirs: True
{%- else %}
/etc/grafana/provisioning/dashboards/caasp-namespaces.json:
  file.absent
{%- endif %}

# HA and SAP dashboards
# * HA:
grafana-ha-cluster-dashboards:
{%- if salt['pillar.get']('grafana:dashboards:sap:add_ha_dashboard', False) %}
  pkg.installed
{%- else %}
  pkg.removed
{%- endif %}
# * SAP HANA:
grafana-sap-hana-dashboards:
{%- if salt['pillar.get']('grafana:dashboards:sap:add_sap_hana_dashboard', False) %}
  pkg.installed
{%- else %}
  pkg.removed
{%- endif %}
# * SAP Netweaver:
grafana-sap-netweaver-dashboards:
{%- if salt['pillar.get']('grafana:dashboards:sap:add_sap_netweaver_dashboard', False) %}
  pkg.installed
{%- else %}
  pkg.removed
{%- endif %}

{% if use_podman %}
grafana-container:
  file.managed:
    - names:
      - /etc/containers/systemd/grafana.container:
        - source: salt://grafana/files/containers/grafana.container
      - /etc/containers/systemd/grafana.volume:
        - source: salt://grafana/files/containers/grafana.volume
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
  service.running:
    - name: grafana
    - enable: true
    - watch:
      - file: /etc/containers/systemd/grafana.*
      - file: /etc/grafana/provisioning/datasources/datasources.yml
      - file: /etc/grafana/provisioning/dashboards/*
      - file: /etc/grafana/grafana.ini

{% else %}
grafana-server:
  pkg.installed:
    - names:
      - grafana
  service.running:
    - enable: True
    - watch_any:
      - file: /etc/grafana/provisioning/datasources/datasources.yml
      - file: /etc/grafana/provisioning/dashboards/*
      - file: /etc/grafana/grafana.ini
{% endif %}

{%- else %}
# disable service
{% if use_podman %}
grafana-container:
  service.dead:
    - name: grafana
    - enable: false
  file.absent:
    - names:
      - /etc/containers/systemd/grafana.container
      - /etc/containers/systemd/grafana.volume
  module.run:
    - name: service.systemctl_reload

{% else %}
grafana-server:
  service.dead:
    - enable: False
{% endif %}
{%- endif %}
{%- endif %}
