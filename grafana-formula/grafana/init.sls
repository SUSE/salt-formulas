# check for supported os version
{%- set supported_vers = ['42.3', '12.3', '12.4', '12.5', '15.0', '15.1', '15.2'] %}

{% if grains['os_family'] == 'Suse' and grains['osrelease'] in supported_vers %}
{%- set supported = True %}
{% endif %} #check if supported

{%- if supported %}
{%- if salt['pillar.get']('grafana:enabled', False) %}
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
    - source: "salt://grafana/files/mgr-server.json"
    - makedirs: True
{%- else %}
/etc/grafana/provisioning/dashboards/mgr-server.json:
  file.absent
{%- endif %}

{%- if salt['pillar.get']('grafana:dashboards:add_uyuni_clients_dashboard', False) %}
/etc/grafana/provisioning/dashboards/mgr-client-systems.json:
  file.managed:
    - source: "salt://grafana/files/mgr-client-systems.json"
    - makedirs: True
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

{%- if salt['pillar.get']('grafana:dashboards:add_k8s_dashboard', False) %}
/etc/grafana/provisioning/dashboards/caasp-cluster.json:
  file.managed:
    - source: "salt://grafana/files/caasp-cluster.json"
    - makedirs: True
{%- else %}
/etc/grafana/provisioning/dashboards/caasp-cluster.json:
  file.absent
{%- endif %}

{%- if salt['pillar.get']('grafana:dashboards:add_etcd_dashboard', False) %}
/etc/grafana/provisioning/dashboards/caasp-etcd-cluster.json:
  file.managed:
    - source: "salt://grafana/files/caasp-etcd-cluster.json"
    - makedirs: True
{%- else %}
/etc/grafana/provisioning/dashboards/caasp-etcd-cluster.json:
  file.absent
{%- endif %}

{%- if salt['pillar.get']('grafana:dashboards:add_k8s_namespaces_dashboard', False) %}
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
{%- if salt['pillar.get']('grafana:dashboards:add_ha_dashboard', False) %}
ha_dashboard:
  pkg.installed:
    - name: grafana-ha-cluster-dashboards
{%- endif %}
# * SAP HANA:
{%- if salt['pillar.get']('grafana:dashboards:add_sap_hana_dashboard', False) %}
sap_hana_dashboard:
  pkg.installed:
    - name: grafana-sap-hana-dashboards
{%- endif %}
# * SAP Netweaver:
{%- if salt['pillar.get']('grafana:dashboards:add_sap_netweaver_dashboard', False) %}
sap_netweaver_dashboard:
  pkg.installed:
    - name: grafana-sap-netweaver-dashboards
{%- endif %}

grafana-server:
  pkg.installed:
    - names:
      - grafana
  service.running:
    - enable: True
    - watch_any:
      - file: /etc/grafana/provisioning/datasources/datasources.yml
      - file: /etc/grafana/provisioning/dashboards/dashboard-provider.yml
      - file: /etc/grafana/provisioning/*/*.json
      - file: /etc/grafana/grafana.ini

{%- else %}
# disable service
grafana-server:
  service.dead:
    - enable: False
{%- endif %}
{%- endif %}
