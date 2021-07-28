#
# spec file for package virtualization-host-formula 
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


Name:           virtualization-host-formula
Version:        0.6
Release:        0
Summary:        Virtualization Salt Formula for SUSE Manager
License:        Apache-2.0
Group:          System/Management
URL:            https://github.com/SUSE/salt-formulas 
Source:         %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
BuildRequires:  salt-master
Requires:       salt-master

# This would be better with a macro that just strips "-formula" from {name}
%define fname virtualization-host

%description
Virtualization Salt Formula for SUSE Manager. Installs an hypervisor.

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}/usr/share/susemanager/formulas/states/%{fname}
mkdir -p %{buildroot}/usr/share/susemanager/formulas/metadata/%{fname}
cp virtualization-host/*.sls %{buildroot}/usr/share/susemanager/formulas/states/%{fname}
cp virtualization-host/*.jinja %{buildroot}/usr/share/susemanager/formulas/states/%{fname}
cp -R virtualization-host/src/states %{buildroot}/usr/share/susemanager/formulas/states/%{fname}/_states
cp -R metadata/* %{buildroot}/usr/share/susemanager/formulas/metadata/%{fname}
mkdir -p %{buildroot}/etc/salt/master.d/
cp %{name}.conf %{buildroot}/etc/salt/master.d/

%files
%defattr(-,root,root,-)
%license LICENSE
/usr/share/susemanager
%config /etc/salt/master.d/%{name}.conf

%changelog

