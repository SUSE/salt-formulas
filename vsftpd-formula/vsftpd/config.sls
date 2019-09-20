{% from "vsftpd/map.jinja" import vsftpd with context %}

vsftpd_config:
  file.managed:
    - name: {{ vsftpd.vsftpd_config }}
    - source: {{ vsftpd.vsftpd_config_src }}
    - template: jinja
    - user: root
    - mode: 644
    - makedirs: true
    - watch_in:
      - service: {{ vsftpd.service }}
