{% if grains['os_family'] == 'RedHat' %}

# Check if this machine was not already liberated
{% if not salt['file.file_exists']('/etc/sysconfig/liberated') %}

{% set release = grains.get('osmajorrelease', None)|int() %}
{% set osName = grains.get('os', None) %}
{% set reinstallPackages = salt['pillar.get']('liberate:reinstall_packages', true) %}

{% set liberated = false %}
{% set liberationDate = salt['system.get_system_date']() %}

{% set isLiberty = salt['file.search']('/etc/os-release', 'SUSE Liberty Linux') %}
{% set isSleES = salt['file.search']('/etc/os-release', 'SLES Expanded Support') %}

# EL 9
{% if release == 9 %}
{% if not isLiberty %}

/usr/share/redhat-release:
  file.absent

/etc/dnf/protected.d/redhat-release.conf:
  file.absent

{% if osName == 'Rocky' %}
/usr/share/rocky-release/:
  file.absent

remove_release_package:
  cmd.run:
    - name: "rpm -e --nodeps rocky-release"
{% endif %}

{% if osName == 'AlmaLinux' %}
/usr/share/almalinux-release/:
  file.absent

remove_release_package:
  cmd.run:
    - name: "rpm -e --nodeps almalinux-release"
{% endif %}

{% if osName == 'OEL' %}
/usr/share/oraclelinux-release/:
  file.absent

remove_release_package:
  cmd.run:
    - name: "rpm -e --nodeps oraclelinux-release"
{% endif %}

install_package_9:
  pkg.installed:
    - name: sll-release
    - refresh: True

install_logos_9:
  pkg.installed:
    - name: sll-logos
    - refresh: True

{% if reinstallPackages %}
re_install_from_SLL:
  cmd.run:
    - name: "dnf -x 'venv-salt-minion' reinstall '*' -y >> /var/log/dnf_sll_migration.log"
    - require:
      - pkg: install_package_9
{% endif %}

{% set liberated = true %}

{% endif %} # end if for search


# EL 8
{% elif release == 8 %}

# Starting tasks for EL clones 8 or under.
{% if not isSleES and not isLiberty %}

/usr/share/redhat-release:
  file.absent

/etc/dnf/protected.d/redhat-release.conf:
  file.absent

{% if osName == 'Rocky' %}
/usr/share/rocky-release/:
  file.absent

remove_release_package:
  cmd.run:
    - name: "rpm -e --nodeps rocky-release"
{% endif %}

{% if osName == 'AlmaLinux' %}
/usr/share/almalinux-release/:
  file.absent

remove_release_package:
  cmd.run:
    - name: "rpm -e --nodeps almalinux-release"
{% endif %}

install_package_8:
  pkg.installed:
    - name: sles_es-release
    - refresh: True

install_logos_8:
  pkg.installed:
    - name: sles_es-logos
    - refresh: True

{% if reinstallPackages %}
re_install_from_SLL:
  cmd.run:
    - name: "yum -x 'venv-salt-minion' -x 'salt-minion' reinstall '*' -y >> /var/log/dnf_sles_es_migration.log"
    - require:
      - pkg: install_package_8
{% endif %}

{% set liberated = true %}

{% endif %} # end if for search


# EL 7
{% elif release == 7 %}

# Starting tasks for EL clones 8 or under.
{% if not isSleES and not isLiberty %}

/usr/share/redhat-release:
  file.absent

/etc/dnf/protected.d/redhat-release.conf:
  file.absent

{% if osName == 'OEL' %}
/usr/share/oraclelinux-release/:
  file.absent

remove_release_package:
  cmd.run:
    - name: "rpm -e --nodeps oraclelinux-release-el7"
{% endif %}

install_package_7:
  pkg.installed:
    - name: sles_es-release-server
    - refresh: True

install_logos_7:
  pkg.installed:
    - name: sles_es-logos
    - refresh: True

{% if reinstallPackages %}
re_install_from_SLL:
  cmd.run:
    - name: "yum -x 'venv-salt-minion' -x 'salt-minion' reinstall '*' -y >> /var/log/yum_sles_es_migration.log"
    - require:
      - pkg: install_package_7
{% endif %}

{% set liberated = true %}

{% endif %} # end if for search

{% endif %} # end if for release number

create_liberation_file:
  file.managed:
    - name: /etc/sysconfig/liberated
    - contents: |
        LIBERATED="{{ liberated }}"
        LIBERATED_FROM="{{ osName }} {{ release }}"
        LIBERATED_DATE="{{ liberationDate }}"
        LIBERATED_REINSTALLED="{{ reinstallPackages }}"

{% endif %} # end if file /etc/sysconfig/liberated exists

{% endif %} # endif of rhel family
