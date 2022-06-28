#
# spec file for package configure-proxy-formula
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


%define fname configure-proxy
%define fdir  %{_datadir}/salt-formulas
Name:           configure-proxy-formula
Version:        0.2
Release:        0
Summary:        Salt formula for configuring proxy
License:        Apache-2.0
Group:          System/Packages
Url:            https://github.com/mbussolotto/salt-formulas/tree/configure-proxy-formula/configure-proxy-formula
Source:         configure-proxy-formula-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
Salt formula for configuring non-containerized proxy.

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{fdir}/states/%{fname}
mkdir -p %{buildroot}%{fdir}/metadata/%{fname}
cp -R configure-proxy/* %{buildroot}%{fdir}/states/%{fname}
cp -R metadata/* %{buildroot}%{fdir}/metadata/%{fname}

%files
%defattr(-,root,root)
%license LICENSE
%dir %{_datadir}/salt-formulas
%dir %{fdir}
%dir %{fdir}/states
%dir %{fdir}/metadata
%{fdir}/states/%{fname}
%{fdir}/metadata/%{fname}

%changelog
