%define app_path /www/ood/apps/sys/
%define deps_path /var/www/ood/deps/
%define config_path /etc/ood/config/

Name:           ood-persistent-ssh
Version:        3
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
%__install -m 0755 -D template/* %{buildroot}%{_localstatedir}%{app_path}%{name}/template
%__install -m 0644 manifest.yml *.erb README.md LICENSE %{buildroot}%{_localstatedir}%{app_path}%{name}/

%__install -m 0755 -D ssh_wrapper.sh %{buildroot}%{deps_path}ssh_wrapper
%__install -m 0755 -d %{buildroot}%{config_path}apps/shell
echo 'OOD_SSH_WRAPPER="%{deps_path}ssh_wrapper"' > %{buildroot}%{config_path}apps/shell/env
echo %{version}-%{release} > %{buildroot}%{_localstatedir}%{app_path}%{name}/VERSION

%files

%{_localstatedir}%{app_path}%{name}
%{deps_path}
%{config_path}apps/shell/env

%changelog
* Thu Feb 23 2023 Sami Ilvonen <sami.ilvonen@csc.fi>
- Initial version
