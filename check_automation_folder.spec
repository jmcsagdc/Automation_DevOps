Summary: A jmcsagdc NRPE plugin
Name: check_automation_folder.sh
Version: 0.1
Release: 1
URL:     https://github.com/jmcsagdc/Automation_NTI-310
License: GPL
Group: Applications/Internet

BuildRoot: %{_tmppath}/%{name}-root

Source0: check_automation_folder-%{version}.tar.gz


%description
NRPE plugin to check for valid /root/Automation folder.

%prep
%setup

%build

%install
rm -rf ${RPM_BUILD_ROOT}

install -m 744 /root/rpmbuild/SOURCES/plugins/check_automation_folder ${RPM_BUILD_ROOT}/usr/lib64/nagios/plugins/check_automation_folder

%clean
rm -rf ${RPM_BUILD_ROOT}

%files
%defattr(-,nagios,nagios)
%attr(744,nagios,nagios) %{_bindir}/check_automation_folder.sh

%changelog
* Sun May 7 2017 jmcsagdc <jmcsagdc@gmail.com>
- Yay, pie.
