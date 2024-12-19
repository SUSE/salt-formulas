#
# spec file for package locale-formula
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


%define fname locale
Name:           %{fname}-formula
Version:        0.4.0
Release:        0
Summary:        Locale Salt Formula for SUSE Multi-Linux Manager and Uyuni
License:        GPL-3.0-only
Group:          System/Management
URL:            https://github.com/SUSE/salt-formulas
Source0:        %{name}-%{version}.tar.gz
Requires:       salt-master
BuildArch:      noarch

%description
Salt Formula for SUSE Multi-Linux Manager and Uyuni.
It configures the locale - langauge, keyboard and timezone.


%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{_datadir}/susemanager/formulas/states/%{fname}
mkdir -p %{buildroot}%{_datadir}/susemanager/formulas/metadata/%{fname}
cp -R states/* %{buildroot}%{_datadir}/susemanager/formulas/states/%{fname}
cp -R metadata/* %{buildroot}%{_datadir}/susemanager/formulas/metadata/%{fname}

%files
%defattr(-,root,root,-)
%license COPYING
%doc README.rst
%{_datadir}/susemanager

%changelog
