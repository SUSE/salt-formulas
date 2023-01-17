# check for supported os version
{%- set supported_vers = ['42.3', '12.3', '12.4', '12.5', '15.0', '15.1', '15.2', '15.3', '15.4'] %}

# check if supported
{%- set supported = (grains['os_family'] == 'Suse' and grains['osrelease'] in supported_vers) %}

{%- if supported %}
{%- if salt['pillar.get']('grafana:enabled', False) %}
{%- if salt['pillar.get']('mgr_server_is_uyuni', True) %}
  {% set product_name = 'Uyuni' %}
{%- else %}
  {% set product_name = 'SUSE Manager' %}
{%- endif %}
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

{%- else %}
# disable service
grafana-server:
  service.dead:
    - enable: False
{%- endif %}
{%- endif %}
