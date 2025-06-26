#
# spec file for package grafana-formula
#
# Copyright (c) 2024 SUSE LLC
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


%define fname grafana
%define fdir  %{_datadir}/susemanager/formulas
Name:           grafana-formula
Version:        0.12.1
Release:        0
Summary:        Salt formula for installing and configuring Grafana
License:        Apache-2.0
Group:          System/Packages
URL:            https://github.com/SUSE/salt-formulas
Source:         grafana-formula-%{version}.tar.gz
BuildArch:      noarch

%description
Salt Formula for installing and configuring Grafana.

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{fdir}/states/%{fname}
mkdir -p %{buildroot}%{fdir}/metadata/%{fname}
cp -R grafana/* %{buildroot}%{fdir}/states/%{fname}
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
