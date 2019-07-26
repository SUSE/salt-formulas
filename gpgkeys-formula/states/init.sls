{% for product, args in pillar.get('gpgkeys', {}).items() %}
{%- if product == 'all' or product == grains['osfullname'] + ' ' + grains['osrelease'] %}
{% for key in args['keys'] %}
{%- if grains['os_family'] == 'Debian' %}
mgr_trust_deb_gpg_key_{{ key['name'] }}:
  module.run:
    - name: pkg.add_repo_key
    - path: https://{{ salt['pillar.get']('mgr_server') }}/pub/{{ key['file'] }}
{%- else %}
mgr_trust_rpm_gpg_key_{{ key['name'] }}:
  cmd.run:
    - name: rpm --import https://{{ salt['pillar.get']('mgr_server') }}/pub/{{ key['file'] }}
    - unless: rpm -q {{ key['name'] }}
    - runas: root
{%- endif %}
{% endfor %}
{%- endif %}
{% endfor %}

