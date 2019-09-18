{% from "vsftpd/map.jinja" import vsftpd with context %}
{% set vsftpd_config = salt['pillar.get']('vsftpd_config') %}
    
include:
  - vsftpd.config

vsftpd:
  {% if vsftpd.server is defined %}
  pkg.installed:
    - name: {{ vsftpd.server }}
  {% endif %}
  service.running:
    - enable: True
    - name: {{ vsftpd.service }}
    - require:
      - file: vsftpd_chroot_dir
  {% if vsftpd_config.anon_root is defined %}        
      - file: vsftpd_anon_dir_check
  {% endif %}
  {% if vsftpd.server is defined %}
      - pkg: {{ vsftpd.server }}
  {% endif %}

  
vsftpd_chroot_dir:  
  file.directory:
    - user:  root
    - name:  {{ pillar['vsftpd_config']['secure_chroot_dir'] }}
    - group:  root
    - mode:  755
    - makedirs: True


{% if vsftpd_config.anon_root is defined %}        
vsftpd_anon_dir_check:
  file.exists:
      - name: {{ vsftpd_config.anon_root }}
{% endif %}
