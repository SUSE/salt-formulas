{% from "dhcpd/map.jinja" import dhcpd with context %}

include:
  - dhcpd

dhcpd.conf:
  file.managed:
    - name: {{ dhcpd.config }}
    - source: salt://dhcpd/files/dhcpd.conf
    # apparmor limits dhcpd to its config dir, so copy the file there
    - check_cmd: |
        sh -c '
        export TMPDIR=$(dirname "{{ dhcpd.config }}") ;
        TMPFILE="$(mktemp)" ;
        cp "$0" "${TMPFILE}" ;
        dhcpd -t -cf "${TMPFILE}" ;
        ERROR="$?" ;
        rm -f "${TMPFILE}" ;
        exit $ERROR '
    - template: jinja
    - user: root
{% if 'BSD' in salt['grains.get']('os') %}
    - group: wheel
{% else %}
    - group: root
{% endif %}
    - mode: 644
    - watch_in:
      - service: dhcpd
    - require:
      - pkg: dhcpd

{% if dhcpd.service_config is defined %}

service_config:
  file.managed:
    - name: {{ dhcpd.service_config }}
    - source: {{ 'salt://dhcpd/files/service_config.' ~ salt['grains.get']('os_family') }}
    - makedirs: True
    - template: jinja
    - user: root
{% if 'BSD' in salt['grains.get']('os') %}
    - group: wheel
{% else %}
    - group: root
{% endif %}
    - mode: 644
    - watch_in:
      - service: dhcpd

{% endif %}
