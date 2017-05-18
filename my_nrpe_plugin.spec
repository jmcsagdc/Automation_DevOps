Name:           my_nrpe_plugin
Version:        0.1
Release:        3
Summary:        A new plugin for nrpe

Group:          Applications
License:        GPL2+

BuildRequires:  gcc, python >= 1.3
Requires:	bash

%description
Dumbest way I can think of to make this work.

%prep


%build


%install
mkdir -p %{buildroot}/tmp/my_plugin
cp /root/my_plugin/* %buildroot/tmp/my_plugin

%clean


%files
%defattr(0644, root,root)
/tmp/my_plugin/*


%post
chmod +x /tmp/my_plugin/*
mv /tmp/my_plugin/* /usr/lib64/nagios/plugins/.
echo "this worked: `date`  ~  here's where I'd echo that command in..." >> /root/my_plugins_log
echo >>	/etc/nagios/nrpe.cfg
echo 'command[check_process]=/usr/lib64/nagios/plugins/check_process.sh crond' >> /etc/nagios/nrpe.cfg

%changelog
