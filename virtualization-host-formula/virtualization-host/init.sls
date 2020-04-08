{% from "virtualization-host/map.jinja" import packages with context %}

virthost_packages:
  pkg.installed:
    - pkgs: {{ packages }}

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
