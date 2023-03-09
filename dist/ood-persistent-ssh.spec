%define app_path /www/ood/apps/sys/

Name:           ood-persistent-ssh
Version:        13
Release:        1%{?dist}
Summary:        Open on Demand persistent ssh

BuildArch:      noarch

License:        MIT
Source:         %{name}-%{version}.tar.bz2

Requires:       ondemand
Requires:       ood-util
Requires:       ood-initializers

# Disable debuginfo
%global debug_package %{nil}

%description
Open on Demand persistent ssh

%prep
%setup -q

%build

%install

%__install -m 0755 -d %{buildroot}%{_localstatedir}%{app_path}%{name}/template
%__install -m 0644 -D template/* %{buildroot}%{_localstatedir}%{app_path}%{name}/template
%__install -m 0644 manifest.yml *.erb README.md LICENSE %{buildroot}%{_localstatedir}%{app_path}%{name}/
# TODO: Add ssh_wrapper.sh somewhere, add OOD_SSH_WRAPPER to /etc/ood/config/apps/shell/env

%post
# TODO: include form_validated.js globally to avoid this?
ln -fns "$(rpm -qil ood-util | grep form_validated.js)" %{_localstatedir}%{app_path}%{name}/form.js

%files

%{_localstatedir}%{app_path}%{name}

%changelog
* Thu Feb 23 2023 Sami Ilvonen <sami.ilvonen@csc.fi>
- Initial version
