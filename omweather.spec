# 
# Do not Edit! Generated by:
# spectacle version 0.18
# 
# >> macros
# << macros

Name:       omweather
Summary:    OMWeather
Version:    0.3
Release:    1
Group:      Applications/Internet
License:    GPLv2.1
URL:        https://garage.maemo.org/projects/omweather/
Source0:    %{name}-%{version}.tar.bz2
Source100:  omweather.yaml
BuildRequires:  pkgconfig(QtCore) >= 4.7.0
BuildRequires:  pkgconfig(libcurl)
BuildRequires:  pkgconfig(sqlite3)
BuildRequires:  pkgconfig(dbus-glib-1)
BuildRequires:  pkgconfig(libxml-2.0)
BuildRequires:  pkgconfig(meego-panel)
BuildRequires:  pkgconfig(mutter-plugins)
BuildRequires:  gettext
BuildRequires:  qt-qmake
BuildRequires:  libqt-devel


%description
Weather Forecast on Nokia N900. Ultra-customisable weather widget for showing forecast the way you want.



%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
#export PATH=/usr/lib/qt4/bin:$PATH
qmake PREFIX=%{_prefix} -r
make
# << build pre



# >> build post
# << build post
%install
rm -rf %{buildroot}
# >> install pre
# << install pre

# >> install post
make INSTALL_ROOT=%{buildroot} install
ln -s /usr/share/omweather/icons  %{buildroot}/usr/share/meego-panel-omweather/theme/icons
devel -p /sbin/ldconfig
# << install post




%postun
# >> postun
devel -p /sbin/ldconfig
# << postun


%files
%defattr(-,root,root,-)
/usr/bin/omweather-settings
%{_libdir}
%{_libexecdir}/meego-panel-omweather
/usr/share/meego-panel-omweather
/usr/share/dbus-1/services
/usr/share/omweather
/usr/share/locale
/usr/share/mutter-meego/panels/meego-panel-omweather.desktop
/etc/xdg
/usr/lib/omweather/weathercom
/usr/share/omweather/copyright_icons/weather.com.png
/usr/share/omweather/db/weather.com.db
/usr/share/omweather/sources/weather.com.xml
# >> files
# << files


