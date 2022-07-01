patterns-uyuni_proxy:
  pkg.installed

/run/server.key:
  file.managed:
    - source: {{ salt['pillar.get']('configure-proxy:ssl:key_group') }}
    - skip_verify: True
    - mode: 600

/run/ca.crt:
  file.managed:
    - source: {{ salt['pillar.get']('configure-proxy:ssl:ca_group') }}
    - skip_verify: True
    - mode: 600

/run/server.crt:
  file.managed:
    - source: {{ salt['pillar.get']('configure-proxy:ssl:cert_group') }}
    - skip_verify: True
    - mode: 600

/run/config-answers.txt:
  file.managed:
    - source: salt://configure-proxy/config-answers.txt
    - user: root
    - group: root
    - mode: 644
    - template: jinja

configure-proxy:
  cmd.run:
    - name: configure-proxy.sh --rhn-user={{ grains.get('server_username') | default('admin', true) }} --rhn-password={{ grains.get('server_password') | default('admin', true) }} --non-interactive --answer-file /run/config-answers.txt
    - require:
      - pkg: patterns-uyuni_proxy
      - file: /run/config-answers.txt
      - file: /run/server.crt
      - file: /run/ca.crt
      - file: /run/server.key
      
