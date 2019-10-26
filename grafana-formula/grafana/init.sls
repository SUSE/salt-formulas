{%- if salt['pillar.get']('grafana:enabled', False) %}
# setup grafana
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

grafana-server:
  pkg.installed:
    - names:
      - grafana
  service.running:
    - enable: True
    - restart: True
    - requires:
      - file: /etc/grafana/provisioning/datasources/datasources.yml
      - file: /etc/grafana/provisioning/dashboards/dashboard-provider.yml
      - file: /etc/grafana/grafana.ini

{%- else %}
# remove grafana
grafana-server:
  pkg.removed:
    - names:
      - grafana

/etc/grafana:
  file.absent    

{%- endif %}