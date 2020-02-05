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
