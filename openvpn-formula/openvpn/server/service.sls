{% from "openvpn/map.jinja" import server with context %}
{% from "openvpn/map.jinja" import common with context %}
{%- if server.enabled %}

include:
- openvpn.common

{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}

net.ipv4.ip_forward:
  sysctl.present:
  - value: 1

{%- endif %}

/etc/openvpn/server.conf:
  file.managed:
  - source: salt://openvpn/files/server.conf
  - template: jinja
  - mode: 600
  - require:
    - pkg: openvpn_packages
  - watch_in:
    - service: openvpn_service

/etc/openvpn/ipp.txt:
  file.managed:
  - source: salt://openvpn/files/ipp.txt
  - template: jinja
  - mode: 600
  - require:
    - pkg: openvpn_packages
  - watch_in:
    - service: openvpn_service

{%- if server.ssl.get('key') %}
/etc/openvpn/ssl/server.key:
  file.managed:
    - contents_pillar: openvpn:server:ssl:key
    - mode: 600
    - watch_in:
      - service: openvpn_service
{%- endif %}

{%- if server.ssl.get('cert') %}
/etc/openvpn/ssl/server.crt:
  file.managed:
    - contents_pillar: openvpn:server:ssl:cert
    - watch_in:
      - service: openvpn_service
{%- endif %}

{%- if server.ssl.get('ca') %}
/etc/openvpn/ssl/ca.crt:
  file.managed:
    - contents_pillar: openvpn:server:ssl:ca
    - watch_in:
      - service: openvpn_service
{%- endif %}

{%- if server.ssl.ca_group.get("location", "local") == "remote" %}
/etc/openvpn/ssl/ca.crt:
  file.managed:
    - source: {{ server.ssl.ca_group.url }}
    - skip_verify: true
    - watch_in:
      - service: openvpn_service
{%- endif %}

{%- if server.ssl.cert_group.get("location", "local") == "remote" %}
/etc/openvpn/ssl/server.crt:
  file.managed:
    - source: {{ server.ssl.cert_group.url }}
    - skip_verify: true
    - watch_in:
      - service: openvpn_service
{%- endif %}

{%- if server.ssl.key_group.get("location", "local") == "remote" %}
/etc/openvpn/ssl/server.key:
  file.managed:
    - source: {{ server.ssl.key_group.url }}
    - skip_verify: true
    - watch_in:
      - service: openvpn_service
{%- endif %}

{%- if server.ssl.crl_group.get("enabled", False) %}
{%- if server.ssl.crl_group.get("location", "local") == "remote" %}
/etc/openvpn/ssl/crl.pem:
  file.managed:
    - source: {{ server.ssl.crl_group.url }}
    - skip_verify: true
    - watch_in:
      - service: openvpn_service
{%- endif %}
{%- endif %}


openvpn_generate_dhparams:
  cmd.run:
  - name: openssl dhparam -out /etc/openvpn/ssl/dh2048.pem 2048
  - creates: /etc/openvpn/ssl/dh2048.pem
  - watch_in:
    - service: openvpn_service

{%- if server.get('auth', False) %}
openvpn_auth_packages:
  pkg.installed:
    - name: openvpn-auth-pam-plugin

openvpn_auth_pam:
  file.symlink:
    - name: /etc/pam.d/openvpn
    - target: /etc/pam.d/common-auth
    - watch_in:
      - service: openvpn_service
    - require:
      - pkg: openvpn_auth_packages
{%- endif %}

{%- if server.get('tls_auth', False) %}
openvpn_generate_ta_key:
  cmd.run:
    - name: openvpn --genkey --secret /etc/openvpn/ta.key
    - creates: /etc/openvpn/ta.key
    - watch_in:
      - service: openvpn_service
{% endif %}

openvpn_service:
  service.running:
  {%- if grains.get('init', None) == 'systemd' %}
  - name: {{ common.service }}@server
  {%- else %}
  - name: {{ common.service }}
  {%- endif %}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

{% if server.firewall.get('enabled', False) %}
firewalld.add_port:
  module.run:
    - zone: {{ server.firewall.get('zone', '') }}
    - force_masquerade: {{ server.firewall.get('masquerade', True) }}
    - port: {{ server.bind.port }}/{{ server.bind.protocol }}
firewalld.reload_rules:
  module.run:
    - require:
        - module: firewalld.add_port
{%- endif %}

{%- else %}

openvpn_service:
  service.dead:
    {%- if grains.get('init', None) == 'systemd' %}
    - name: {{ common.service }}@server
    {%- else %}
    - name: {{ common.service }}
    {%- endif %}
    - enable: false

{% if server.firewall.get('enabled', False) %}
firewalld.remove_port:
  module.run:
    - zone: {{ server.firewall.get('zone', 'public') }}
    - force_masquerade: {{ server.firewall.get('masquerade', True) }}
    - port: {{ server.bind.port }}/{{ server.bind.protocol }}
firewalld.reload_rules:
  module.run:
    - require:
        - module: firewalld.remove_port
{%- endif %}

{%- endif %}
