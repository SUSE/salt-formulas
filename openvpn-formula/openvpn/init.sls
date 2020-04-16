
include:
{% if pillar.openvpn.server is defined %}
- openvpn.server
{% endif %}
{% if pillar.openvpn.client is defined %}
- openvpn.client
{% endif %}
