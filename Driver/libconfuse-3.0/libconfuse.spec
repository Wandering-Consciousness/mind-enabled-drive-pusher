%define _srcname	confuse
%define _name		lib%{_srcname}
%define _version	3.0
%define _rel		1

%define _prefix	/usr
%define _pkgdoc	%{_docdir}/%{_name}

%define _suse	%(if [ -f /etc/SuSE-release ]; then echo 1; else echo 0; fi)

%if %_suse
%define _suse_version	%(grep VERSION /etc/SuSE-release|cut -f3 -d" ")
%define _suse_vernum		%(echo "%_suse_version"|tr -d '.')
%define _release			%{_rel}suse%{_suse_vernum}
%define _has_distro		1
%define _distribution	SuSE Linux %_suse_version
%define _group				Development/Libraries/C and C++
%else
%define _release			%_rel
%define _has_distro		0
%define _group				Development/Libraries
%endif

Summary:			A library for parsing configuration files
Name:				%{_name}
Version:			%{_version}
Release:			%{_release}
Source:			http://savannah.nongnu.org/download/confuse//%{_srcname}-%{_version}.tar.gz
URL:				http://www.nongnu.org/confuse/
Group:			%{_group}
Packager:		Pascal Bleser <guru@unixtech.be>
Copyright:		ISC
BuildRoot:		%{_tmppath}/build-%{_name}-%{_version}
BuildRequires:     xmlto doxygen
Prefix:			%{_prefix}
%if %_has_distro
Distribution:  %_distribution
%endif

%description
libConfuse is a configuration file parser library written in C.
It supports sections and (lists of) values (strings, integers,
floats, booleans or other sections), as well as some other features
(such as single/double-quoted strings, environment variable expansion,
functions and nested include statements).

It makes it easy to add configuration file capability to a
program using a simple API. LibConfuse aims to be easy to use and
quick to integrate with your code.

%package devel
Summary:		Development Environment for %{_name}
Group:			%{_group}
Requires:		%{_name} = %{_version}

%description devel
Development Environment for %{_name}

Documentation and examples can be found in %{_pkgdoc}/doc
and %{_pkgdoc}/examples respectively.

%changelog
* Fri May 21 2004 Martin Hedenfalk <mhe@home.se> 2.3-%{_rel}suse%{_suse_vernum}
- New upstream version, updated URLs
* Sat Apr 05 2003 Martin Hedenfalk <mhe@home.se> 2.0-%{_rel}suse%{_suse_vernum}
- removed doxygen dependence as pre-built documentation are now included
* Fri Mar 28 2003 Pascal Bleser <guru@unixtech.be> 1.2.3-%{_rel}suse%{_suse_vernum}
- first RPM

%prep
%setup -q -n "%{_srcname}-%{_version}"
CFLAGS="${RPM_OPT_FLAGS}" \
./configure \
	--prefix="%{_prefix}" \
	--enable-shared

%build
%{__make}

%install
%{__rm} -rf "${RPM_BUILD_ROOT}"
%{__make} \
	DESTDIR="${RPM_BUILD_ROOT}" \
	install-strip

%{__mkdir_p} "${RPM_BUILD_ROOT}%{_mandir}"
cp -R doc/man/* "${RPM_BUILD_ROOT}%{_mandir}/"

%{__mkdir_p} "${RPM_BUILD_ROOT}%{_pkgdoc}"
echo -n > _rpm_doc_files_
for f in AUTHORS LICENSE ChangeLog.md README.md; do
	%{__cp} "$f" "${RPM_BUILD_ROOT}%{_pkgdoc}/$f"
	echo "%doc %{_pkgdoc}/$f" >> _rpm_doc_files_
done
%{__make} -C examples clean
%{__rm} examples/Makefile*
%{__rm} -rf doc/man
%{__cp} -R examples doc "${RPM_BUILD_ROOT}%{_pkgdoc}/"

%clean
%{__rm} -rf "${RPM_BUILD_ROOT}"

%post
echo Updating dynamic linker cache...
/sbin/ldconfig

%postun
echo Updating dynamic linker cache...
/sbin/ldconfig

%files -f _rpm_doc_files_
%defattr(-,root,root)
%{_libdir}/lib*.so.*
%{_datadir}/locale/*/LC_MESSAGES/*

%files devel
%defattr(-,root,root)
%doc %{_pkgdoc}/examples
%doc %{_pkgdoc}/doc
%{_includedir}/*
%{_libdir}/lib*.a
%{_libdir}/lib*.la
%{_libdir}/lib*.so
%doc %{_mandir}/man*/*

