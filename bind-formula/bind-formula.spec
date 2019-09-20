#
# spec file for package bind-formula
#
# Copyright (c) 2019 SUSE LINUX GmbH, Nuernberg, Germany.
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


%define fname bind
%define fdir  %{_datadir}/susemanager/formulas
Name:           bind-formula
Version:        0.1
Release:        0
Summary:        Salt formula for configuring and running BIND
License:        Apache-2.0
Group:          System/Packages
Url:            https://github.com/saltstack-formulas/bind-formula
Source:         bind-formula-%{version}.tar.xz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
Salt formula for managing configuration and running of BIND server.

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{fdir}/states/%{fname}
mkdir -p %{buildroot}%{fdir}/metadata/%{fname}
cp -R bind/* %{buildroot}%{fdir}/states/%{fname}
cp -R form.yml metadata.yml LICENSE pillar.example pillar-with-views.example pillar.example.smr README.rst %{buildroot}%{fdir}/metadata/%{fname}

%files
%defattr(-,root,root)
%dir %{_datadir}/susemanager
%dir %{fdir}
%dir %{fdir}/states
%dir %{fdir}/metadata
%{fdir}/states/%{fname}
%{fdir}/metadata/%{fname}

%changelog
