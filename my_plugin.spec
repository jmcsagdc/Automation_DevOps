Name:           my_plugin
Version:        0.1
Release:        1%{?dist}
Summary:        A new plugin for nrpe

Group:          Applications
License:        GPL2+
URL:            http://127.0.0.1
Source0:        my_plugin-0.1.tar.gz

BuildRequires:  gcc, python >= 1.3
Requires:	bash

%description
Dumbest way I can think of to make this work.

%prep


%setup -q

%build
%configure
make %{?_smp_mflags}
cp /root/rpmbuild/SOURCES/my_plugin-0.1/* /root/rpmbuild/BUILD/my_plugin-0.1/.

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/%{_bindir}
mkdir -p %{buildroot}/%{_sysconfdir}/profile.d

make install DESTDIR=%{buildroot}
install -m 0755 %{name} %{buildroot}/%{_bindir}/%{name}
cp /root/rpmbuild/SOURCES/my_plugin-0.1/* %{buildroot}/%{_sysconfdir}/profile.d/
%clean

%files
%defattr(-,root,root)
/usr/bin/%{name}

%config
echo "echo 'hi'" >> /root/.bashrc

%doc

%post
