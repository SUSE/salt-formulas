{% from "virtualization-host/map.jinja" import packages with context %}

# SLES JeOS doesn't ship the KVM and Xen modules
no_kernel_default_base:
  pkg.removed:
    - name: kernel-default-base

virthost_packages:
  pkg.installed:
    - pkgs: {{ packages }}
    - require:
        - pkg: no_kernel_default_base

tuned_service:
  service.running:
    - name: tuned
    - enable: True
    - require:
      - pkg: virthost_packages

tuned_profile:
  cmd.run:
    - name: tuned-adm profile virtual-host
    - unless: 'tuned-adm active | grep virtual-host'
    - require:
      - service: tuned_service

libvirtd_service:
  service.running:
    - name: libvirtd
    - enable: True
    - require:
      - pkg: virthost_packages

{% if grains['osrelease'] == '12.4' %}
# Workaround for guestfs appliance missing libaugeas0 on 12SP4
guestfs-fix:
  file.append:
    - name: /usr/lib64/guestfs/supermin.d/packages
    - text: libaugeas0
    - require:
      - pkg: virthost_packages
{% endif %}

{% if pillar['hypervisor'] == 'Xen' %}
# Set XEN kernel as default in grub
set_xen_default:
  bootloader.grub_set_default:
    - name: Xen
    - require:
      - pkg: virthost_packages
{% endif %}  {# pillar['hypervisor'] == 'Xen' #}

{% if pillar['default_pool_enabled'] %}
# Default virtual storage pool creation
default_pool:
  virt.pool_running:
    - name: default
    - ptype: dir
    - target: {{ pillar['default_pool']['path'] }}
    - autostart: True
    - require:
      - service: libvirtd_service
{% endif %}

{% if pillar['default_net_enabled'] %}

{% if pillar['default_net']['mode'] == "Bridge" %}

# pick the first non-lo in grains['hwaddr_interfaces']
{% set port = grains['hwaddr_interfaces']|reject('equalto', 'lo')|first() %}
{% set nic = pillar['default_net']['bridge'] %}

ifcfg-{{ port }}:
  file.managed:
    - name: /etc/sysconfig/network/ifcfg-{{ port }}
    - contents: |
        STARTMODE=auto
        BOOTPROTO=none

ifcfg-{{ nic }}:
  file.managed:
    - name: /etc/sysconfig/network/ifcfg-{{ nic }}
    - contents: |
        STARTMODE=onboot
        BOOTPROTO=dhcp
        BRIDGE=yes
        BRIDGE_PORTS={{ port }}

{% endif %}  {# if pillar['default_net']['mode'] == "Bridge" #}

# We can't use the virt.network_running here since the IP patch isn't in 4.0's salt
default-net.xml:
  file.managed:
    - name: /root/default-net.xml
    - contents: |
        <network>
          <name>default</name>
          <forward mode='{{ pillar['default_net']['mode'] | lower }}' />
  {% if pillar['default_net']['mode'] == "NAT" %}
    {% for family in ['ipv4', 'ipv6'] %}
      {% if pillar['default_net'][family]['gateway'] %}
        {% set gateway = pillar['default_net'][family]['gateway'] %}
        {% set prefix = pillar['default_net'][family]['prefix'] %}
        {% set dhcp_start = pillar['default_net'][family]['dhcp_start'] %}
        {% set dhcp_end = pillar['default_net'][family]['dhcp_end'] %}
            <ip address='{{ gateway }}' prefix='{{ prefix }}' family='{{ family }}'>
        {% if dhcp_start and dhcp_end %}
              <dhcp>
                <range start='{{ dhcp_start }}' end='{{ dhcp_end }}'/>
              </dhcp>
        {% endif %}
            </ip>
      {% endif %}
    {% endfor %}
  {% endif %}  {# pillar['default_net']['mode'] == NAT #}
  {% if pillar['default_net']['mode'] == "Bridge" %}
          <bridge name='{{ pillar['default_net']['bridge'] }}'/>
  {% endif %}
        </network>

default-net_destroyed:
  cmd.run:
    - name: 'virsh net-destroy default'
    - onlyif: 'virsh net-info default | grep Active | grep yes'
    - require:
      - service: libvirtd_service
      - file: default-net.xml

default-net_undefined:
  cmd.run:
    - name: 'virsh net-undefine default'
    - onlyif: 'virsh net-dumpxml default'
    - require:
      - cmd: default-net_destroyed

default-net_defined:
  cmd.run:
    - name: 'virsh net-define /root/default-net.xml'
    - require:
      - cmd: default-net_undefined
      - file: default-net.xml

default-net_autostart:
  cmd.run:
    - name: 'virsh net-autostart default'
    - require:
      - cmd: default-net_defined

default_virt_net_start:
  cmd.run:
    - name: 'virsh net-start default'
    - require:
      - cmd: default-net_defined
{% endif %}


{# Update Kernel parameters #}
hugepagesz_setting:
  bootloader.kernel_param:
    - name: hugepagesz
    - value: {{ pillar.get("tuning", {})["hugepages_size"] }}

default_hugepagesz_setting:
  bootloader.kernel_param:
    - name: default_hugepagesz
    - value: {{ pillar.get("tuning", {})["hugepages_size"] }}

hugepages_setting:
  bootloader.kernel_param:
    - name: hugepages
    - value: {{ pillar.get("tuning", {})["hugepages_count"] }}

{%- if pillar.get("tuning", {})["hugepages_size"] %}
hugetlbfs_mount:
  mount.mounted:
    - device: hugetlbfs
    - fstype: hugetlbfs
    - name: /dev/hugepages
    - persist: True
{%- else %}
hugetlbfs_mount:
  mount.unmounted:
    - name: /dev/hugepages
    - persist: True
{%- endif %}

numa_balancing_persisted:
  bootloader.kernel_param:
    - name: numa_balancing
{%- if pillar.get("tuning", {})["disable_numa_balancing"] %}
    - value: "disable"
{%- else %}
    - value: null
{%- endif %}

{%- set numa_balancing_value = "0" if pillar.get("tuning", {})["disable_numa_balancing"] else "1" %}
numa_balancing_disabled:
  cmd.run:
    - name: "echo {{ numa_balancing_value }} >/proc/sys/kernel/numa_balancing"
    - unless: "test `cat /proc/sys/kernel/numa_balancing` -eq {{ numa_balancing_value }}"

persist_numa_balancing:
  sysctl.present:
    - name: kernel.numa_balancing
    - value: {{ numa_balancing_value }}

{%- if pillar.get("tuning", {})["disable_irq_balancing"] %}
irqbalance_stopped:
  service.dead:
    - name: irqbalance
    - enable: False
{%- else %}
irqbalance_started:
  service.running:
    - name: irqbalance
    - enable: True
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
ksm_running:
  cmd.run:
    - name: systemctl enable --now ksm
{%- endif %}

grub_config_update:
  cmd.run:
    - name: 'grub2-mkconfig -o /boot/grub2/grub.cfg'
    - onchanges:
      - bootloader: hugepages_setting
      - bootloader: numa_balancing_persisted
{%- if pillar['hypervisor'] == 'Xen' %}
      - bootloader: set_xen_default
{%- endif %}
