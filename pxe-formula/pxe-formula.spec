#
# spec file for package pxe-formula
#
# Copyright (c) 2025 SUSE LLC
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


%define fname pxe
Name:           %{fname}-formula
Version:        0.3.0
Release:        0
Summary:        Formula for PXE boot server files on Retail branchserver
License:        GPL-2.0-or-later
Group:          System/Packages
URL:            https://github.com/SUSE/salt-formulas
Source:         %{fname}-formula-%{version}.tar.gz
BuildArch:      noarch

%description
Formula for install, setup and uninstall of syslinux pxe boot on POS branchserver

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{_datadir}/susemanager/formulas/states/%{fname}/files
mkdir -p %{buildroot}%{_datadir}/susemanager/formulas/metadata/%{fname}
cp -R %{fname}/* %{buildroot}%{_datadir}/susemanager/formulas/states/%{fname}
cp form.yml %{buildroot}%{_datadir}/susemanager/formulas/metadata/%{fname}
cp metadata.yml %{buildroot}%{_datadir}/susemanager/formulas/metadata/%{fname}


%files
%{_datadir}/susemanager
%license LICENSE

%changelog
