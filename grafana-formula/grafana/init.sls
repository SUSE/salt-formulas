{%- if salt['pillar.get']('grafana:enabled', False) %}
# setup grafana
/etc/grafana/grafana.ini:
  file.managed:
    - source: salt://grafana/files/grafana.ini
    - makedirs: True

/etc/grafana/provisioning/datasources/datasources.yml:
  file.managed:
    - source: salt://grafana/files/datasources.yml
    - makedirs: True
    - template: jinja

/etc/grafana/provisioning/dashboards/dashboard-provider.yml:
  file.managed:
    - source: "salt://grafana/files/dashboard-provider.yml"
    - makedirs: True

{%- if salt['pillar.get']('grafana:dashboards:add_uyuni_dashboards', False) %}
{%- for file in ['mgr-client-systems.json','mgr-server.json', 'mgr-postgresql.json'] %}
/etc/grafana/provisioning/dashboards/{{ file }}:
  file.managed:
    - source: "salt://grafana/files/{{ file }}"
    - makedirs: True
{%- endfor %}
{%- else %}
{%- for file in ['mgr-client-systems.json','mgr-server.json', 'mgr-postgresql.json'] %}
/etc/grafana/provisioning/dashboards/{{ file }}:
  file.absent
{%- endfor %}
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