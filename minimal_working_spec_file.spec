Name: test
Version: 1.0.0
Release: 1
Summary: Mister potatohead.
License: GNU
Group: Applications/System
BuildArch: noarch

%description
Brief description of software package.

%prep

%build

%install
mkdir -p %{buildroot}/usr/share/something
cp /root/jason_test/something/* %buildroot/usr/share/something/

%clean

%files
%defattr(0644, root,root)
/usr/share/something/*
