#
# spec file for package virtualization-formulas
#
# Copyright (c) 2022 SUSE LLC
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


Name:           virtualization-formulas
Version:        0.6.2
Release:        0
Summary:        Virtualization Salt Formulas for SUSE Manager
License:        Apache-2.0
Group:          System/Management
URL:            https://github.com/SUSE/salt-formulas 
Source:         %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
BuildRequires:  salt-master
Requires:       salt-master
Provides:       virtualization-host-formula = %version-%release
Obsoletes:      virtualization-host-formula < %version-%release

%description
Virtualization Salt Formula for SUSE Manager for both the hypervisor and the guest.

%prep
%setup -q

%build

%install
install -D -t %{buildroot}/usr/share/susemanager/formulas/states/virtualization-host host/states/*
install -D -t %{buildroot}/usr/share/susemanager/formulas/metadata/virtualization-host host/metadata/*
install -D -t %{buildroot}/usr/share/susemanager/formulas/states/virtualization-guest guest/states/*
install -D -t %{buildroot}/usr/share/susemanager/formulas/metadata/virtualization-guest guest/metadata/*
install -D -t %{buildroot}/usr/share/susemanager/formulas/states/SR-IOV sriov/states/*
install -D -t %{buildroot}/usr/share/susemanager/formulas/metadata/SR-IOV sriov/metadata/*

install -D -t %{buildroot}/usr/share/susemanager/formulas/states/virtualization-host/_states host/src/states/*.py
install -D host/virtualization-host-formula.conf %{buildroot}/etc/salt/master.d/virtualization-host-formula.conf

%files
%defattr(-,root,root,-)
%license LICENSE
/usr/share/susemanager
%config /etc/salt/master.d/virtualization-host-formula.conf

%changelog

