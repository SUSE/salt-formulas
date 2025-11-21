{% from "bind/map.jinja" import map with context %}

{%- set key_directory = salt['pillar.get']('bind:config:key_directory', map.key_directory) %}

bind:
  pkg.installed:
    - pkgs: {{ map.pkgs|json }}
{%- if grains.get('transactional') %}
  cmd.run:
    - name: systemctl enable {{ map.service }}
{%- else %}
  service.running:
    - name: {{ map.service }}
    - enable: True
{%- if not map.get("container", False) %}
    - reload: True
{%- endif %}
{%- endif %}
{%- if map.get("container", False) %}
    - require:
      - file: /etc/systemd/system/{{ map.service }}.service

bind_service_config:
  file.managed:
    - name: /etc/systemd/system/{{ map.service }}.service
    - source: salt://bind/files/bind-container.service.jinja
    - template: jinja
    - context:
        map: {{ map }}
    - user: root
    - mode: 644


{%- endif %}

bind_key_directory:
  file.directory:
    - name: {{ key_directory }}
    - require:
      - pkg: bind

