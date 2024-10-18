Name:		harbour-supersonik
Version:	0.0.1
Release:	0
Summary:	Subsonic music client
License:	GPLv3
URL:		https://www.piggz.co.uk
Source0:        %{name}-%{version}.tar.bz2

Requires:       qt-runner-qt6
BuildRequires:	cmake
BuildRequires:	clang
BuildRequires:	kf6-extra-cmake-modules
BuildRequires:	kf6-rpm-macros
BuildRequires:	kf6-kirigami-devel
BuildRequires:	kf6-ki18n-devel
BuildRequires:	kf6-kcoreaddons-devel
BuildRequires:	kf6-kconfig-devel
BuildRequires:	kf6-kiconthemes-devel
BuildRequires:	kf6-kcolorscheme-devel
BuildRequires:	qt6-qtdeclarative-devel

%description
Subsonic music client for KDE desktops and mobile devices

%prep
%autosetup -n %{name}-%{version}

%build
%cmake_kf6 -DSAILFISHOS=ON
%cmake_build

%install
%cmake_install

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}/applications/uk.co.piggz.harbour-supersonik.desktop
%{_datadir}/icons/hicolor/86x86/apps/harbour-supersonik.png
