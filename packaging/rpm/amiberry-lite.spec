%global _hardened_build 1
%global debug_package %{nil}

Name:           amiberry-lite
Version:        5.9.2
Release:        1%{?dist}
Summary:        Optimized Amiga emulator for ARM, ARM64, AMD64 and RISC-V platforms

License:        GPL-3.0-or-later
URL:            https://amiberry.com
Source0:        https://github.com/BlitterStudio/amiberry-lite/archive/refs/tags/v%{version}.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  cmake >= 3.16
BuildRequires:  ninja-build
BuildRequires:  gcc-c++
BuildRequires:  flac-devel
BuildRequires:  libmpeg2-devel
BuildRequires:  libpng-devel
BuildRequires:  SDL2-devel
BuildRequires:  SDL2_image-devel
BuildRequires:  SDL2_ttf-devel
BuildRequires:  mpg123-devel
BuildRequires:  portmidi-devel
BuildRequires:  libserialport-devel
BuildRequires:  enet-devel
BuildRequires:  libpcap-devel
BuildRequires:  libzstd-devel

Requires:       glibc
Requires:       libstdc++
Requires:       SDL2
Requires:       SDL2_image
Requires:       SDL2_ttf
Requires:       flac
Requires:       mpg123
Requires:       libpng
Requires:       zlib
Requires:       zstd
Requires:       libserialport
Requires:       portmidi
Requires:       enet

%description
Amiberry-Lite is an optimized Amiga emulator for various platforms.
It is based on the latest WinUAE and supports various Amiga models, including
the A4000T, A4000D, A1200, A3000 and A600. Features include support for WHDLoad
titles, RetroArch integration, custom controller mappings, and more.

%prep
%autosetup -n %{name}-%{version}

%build
%cmake \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=%{_prefix}
%cmake_build

%install
%cmake_install

%post
%{_bindir}/update-desktop-database 2>/dev/null || :
%{_bindir}/update-mime-database %{_datadir}/mime 2>/dev/null || :
touch --no-create %{_datadir}/icons/hicolor 2>/dev/null || :
%{_bindir}/gtk-update-icon-cache %{_datadir}/icons/hicolor 2>/dev/null || :

%postun
%{_bindir}/update-desktop-database 2>/dev/null || :
%{_bindir}/update-mime-database %{_datadir}/mime 2>/dev/null || :
if [ $1 -eq 0 ] ; then
    touch --no-create %{_datadir}/icons/hicolor 2>/dev/null || :
    %{_bindir}/gtk-update-icon-cache %{_datadir}/icons/hicolor 2>/dev/null || :
fi

%files
%license LICENSE
%doc %{_docdir}/amiberry-lite/
%{_bindir}/amiberry-lite
%{_libdir}/amiberry-lite/
%{_datadir}/amiberry-lite/
%{_datadir}/applications/Amiberry-Lite.desktop
%{_datadir}/icons/hicolor/scalable/apps/amiberry-lite.svg
%{_datadir}/metainfo/Amiberry-Lite.metainfo.xml
%{_datadir}/mime/packages/amiberry-lite.xml
%{_mandir}/man1/amiberry-lite.1.gz

%changelog
* Thu Sep 17 2026 Dimitris Panokostas <midwan@gmail.com> - 5.9.2-1
- Initial COPR packaging for amiberry-lite
