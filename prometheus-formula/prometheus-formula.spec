#
# spec file for package prometheus-formula
#
# Copyright (c) 2019 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

%define fname prometheus
%define fdir  %{_datadir}/susemanager/formulas
Name:           prometheus-formula
Version:        0.1
Release:        0
Summary:        Salt formula for installing and configuring Prometheus monitoring system
License:        Apache-2.0
Group:          System/Packages
Url:            https://github.com/SUSE/salt-formulas
Source:         prometheus-formula-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
Salt formula for installing and configuring Prometheus monitoring system.

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{fdir}/states/%{fname}
mkdir -p %{buildroot}%{fdir}/metadata/%{fname}
cp -R prometheus/* %{buildroot}%{fdir}/states/%{fname}
cp -R metadata/* %{buildroot}%{fdir}/metadata/%{fname}

%files
%defattr(-,root,root)
%license LICENSE
%dir %{_datadir}/susemanager
%dir %{fdir}
%dir %{fdir}/states
%dir %{fdir}/metadata
%{fdir}/states/%{fname}
%{fdir}/metadata/%{fname}

%changelog
