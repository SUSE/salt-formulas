#
# spec file for package openvpn-formula
#
# Copyright (c) 2020 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


Name:           openvpn-formula
Version:        0.1.2
Release:        0
BuildArch:      noarch
Summary:        OpenVPN Salt Formula for Uyuni/SUSE Manager
License:        Apache-2.0
URL:            https://github.com/SUSE/salt-formulas/
Source:         %{name}-%{version}.tar.xz
Requires:       susemanager-sls

%description
OpenVPN Salt Formula for use in Uyuni/SUSE Manager.

%prep
%setup -q

%install
mkdir -p %{buildroot}/usr/share/susemanager/formulas/metadata/openvpn
mkdir -p %{buildroot}/usr/share/susemanager/formulas/states/openvpn
cp metadata/* %{buildroot}/usr/share/susemanager/formulas/metadata/openvpn/
cp -r openvpn/* %{buildroot}/usr/share/susemanager/formulas/states/openvpn/

%files
%dir /usr/share/susemanager
%dir /usr/share/susemanager/formulas
%dir /usr/share/susemanager/formulas/metadata
%dir /usr/share/susemanager/formulas/states
%dir /usr/share/susemanager/formulas/metadata/openvpn
%dir /usr/share/susemanager/formulas/states/openvpn
%dir /usr/share/susemanager/formulas/states/openvpn/server
%dir /usr/share/susemanager/formulas/states/openvpn/files
/usr/share/susemanager/formulas/metadata/openvpn/form.yml
/usr/share/susemanager/formulas/metadata/openvpn/metadata.yml
/usr/share/susemanager/formulas/states/openvpn/common.sls
/usr/share/susemanager/formulas/states/openvpn/init.sls
/usr/share/susemanager/formulas/states/openvpn/map.jinja
/usr/share/susemanager/formulas/states/openvpn/server/init.sls
/usr/share/susemanager/formulas/states/openvpn/server/service.sls
/usr/share/susemanager/formulas/states/openvpn/files/_gateway.conf
/usr/share/susemanager/formulas/states/openvpn/files/server.conf
/usr/share/susemanager/formulas/states/openvpn/files/_subnet.conf
/usr/share/susemanager/formulas/states/openvpn/files/ipp.txt

%changelog
