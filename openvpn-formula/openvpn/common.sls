{% from "openvpn/map.jinja" import common with context %}

openvpn_packages:
  pkg.installed:
  - names: {{ common.pkgs }}

openvpn_ssl_dir:
  file.directory:
  - name: /etc/openvpn/ssl
  - require:
    - pkg: openvpn_packages



{%- if grains.os_family == "Arch" %}

{%- if pillar.openvpn.client is defined %}

{% from "openvpn/map.jinja" import client with context %}

{%- for tunnel_name, tunnel in client.tunnel.iteritems() %}

openvpn_service:
  service.running:
  - name: "{{ tunnel_name }}.service"
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  
{%- endfor %}

{%- endif %}
{%- endif %}
