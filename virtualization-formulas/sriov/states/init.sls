{% if pillar["devices"] is mapping %}
sriov_unit_file:
  file.managed:
    - name: /etc/systemd/system/sriov.service
    - contents: |
        [Unit]
        Description = Activate SR-IOV virtual interfaces
        After = network-online.target

        [Service]
        Type=oneshot
        ExecStart=\
  {%- for eth, count in pillar["devices"].items() %}
          sh -c "echo {{ count }} >/sys/class/net/{{ eth }}/device/sriov_numvfs" ; \
  {%- else %}
          sh -c 'for file in `ls /sys/class/net/*/device/sriov_numvfs`; do echo 0 >$file; done'
  {%- endfor %}

        [Install]
        WantedBy = default.target

systemctl_daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - require:
        - file: sriov_unit_file

{# Since it's a oneshot service the process will be dead, but the state shouldn't fail #}
sriov_service:
  service.enabled:
    - name: sriov
    - require:
        - cmd: systemctl_daemon_reload

sriov_service_started:
  cmd.run:
    - name: systemctl start sriov
    - require:
        - cmd: systemctl_daemon_reload
{% endif %}
