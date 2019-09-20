#
# spec file for package vsftpd-formula
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

%define fname vsftpd
%define fdir  %{_datadir}/susemanager/formulas
Name:           vsftpd-formula
Version:        0.1
Release:        0
Summary:        Formula for vsftpd server for SUSE Manager
License:        Apache-2.0
Group:          System/Packages
URL:            https://github.com/saltstack-formulas/vsftpd-formula
Source:         vsftpd-formula-%{version}.tar.xz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
Formula for installation and setup of vsftpd server.

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{fdir}/states/%{fname}/files
mkdir -p %{buildroot}%{fdir}/metadata/%{fname}
cp -R %{fname}/* %{buildroot}%{fdir}/states/%{fname}
cp form.yml %{buildroot}%{fdir}/metadata/%{fname}
cp metadata.yml %{buildroot}%{fdir}/metadata/%{fname}
cp LICENSE %{buildroot}%{fdir}/metadata/%{fname}

%files
%defattr(-,root,root)
%dir %{_datadir}/susemanager
%dir %{fdir}
%dir %{fdir}/states
%dir %{fdir}/metadata
%{fdir}/states/%{fname}
%{fdir}/metadata/%{fname}

%changelog
