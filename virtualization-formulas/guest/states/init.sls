{%- if pillar.get("tuning", {})["disable_irq_balancing"] %}
irqbalance_stopped:
  service.dead:
    - name: irqbalance
    - enable: False
{%- else %}
irqbalance_package:
  pkg.installed:
    - pkgs:
      - irqbalance

irqbalance_started:
  service.running:
    - name: irqbalance
    - enable: True
    - require:
      - pkg: irqbalance_package
{%- endif %}

{%- if pillar.get("tuning", {})["disable_ksm"] %}
ksm_stopped:
  service.dead:
    - name: ksm
    - enable: False

ksm_disabled:
  cmd.run:
    - name: "echo 2 >/sys/kernel/mm/ksm/run"
    - unless: "test `cat /sys/kernel/mm/ksm/run` -eq 2"
    - require:
      - service: ksm_stopped
{%- else %}
ksm_package:
  pkg.installed:
    - pkgs:
      - qemu-ksm

ksm_started:
  cmd.run:
    - name: systemctl enable --now ksm
    - require:
      - pkg: ksm_package
{%- endif %}

{%- if pillar.get("tuning", {})["cpu_passthrough"] %}
no_kernel_default_base:
  pkg.removed:
    - pkgs:
      - kernel-default-base

kernel_package:
  pkg.installed:
    - pkgs:
      - kernel-default
    - require:
      - pkg: no_kernel_default_base

add_cpuidle_haltpoll:
  kmod.present:
    - name: cpuidle_haltpoll
    - persist: True
    - require:
      - pkg: kernel_package

guest_tuning_unit_file:
  file.managed:
    - name: /etc/systemd/system/guest-tuning.service
    - contents: |
        [Unit]
        Description = Set VM tuning parameters (haltpoll and clock source)

        [Service]
        Type=oneshot
        ExecStart=\
          sh -c "echo 800000 >/sys/module/haltpoll/parameters/guest_halt_poll_ns" ; \
          sh -c "echo 200000 >/sys/module/haltpoll/parameters/guest_halt_poll_grow_start" ; \
          sh -c "echo tsc > /sys/devices/system/clocksource/clocksource0/current_clocksource"

        [Install]
        WantedBy = basic.target

systemctl_daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - require:
        - file: guest_tuning_unit_file

{# Since it's a oneshot service the process will be dead, but the state shouldn't fail #}
guest_tuning_service:
  service.enabled:
    - name: guest-tuning
    - require:
        - cmd: systemctl_daemon_reload

guest_tuning_service_started:
  cmd.run:
    - name: systemctl start guest-tuning
    - require:
        - kmod: add_cpuidle_haltpoll
        - cmd: systemctl_daemon_reload

{%- else %}
remove_cpuidle_haltpoll:
  kmod.absent:
    - name: cpuidle_haltpoll
    - persist: True

guest_tuning_service:
  service.disabled:
    - name: guest-tuning

{% set default_clock = salt['grains.filter_by']({'xen': 'xen', 'kvm': 'kvm-clock'}) %}
default_clock:
  cmd.run:
    - name: "echo {{ default_clock }} > /sys/devices/system/clocksource/clocksource0/current_clocksource"
    - unless: "test `cat /sys/devices/system/clocksource/clocksource0/current_clocksource` -eq '{{ default_clock }}'"
{%- endif %}
