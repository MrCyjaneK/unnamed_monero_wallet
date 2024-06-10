Name:       unnamed-monero-wallet
Version:    1.0.0+100
Release:    100
Summary:    Unnamed Monero Wallet for SailfishOS
License:    GPLv3
BuildRequires: ffmpeg-tools
Requires: maliit-framework-wayland-glib

%description
Unnamed Monero Wallet (xmruw.net) port for SailfishOS.

%prep
# we have no source, so nothing here

%build
rm -rf files %{_datadir} || true
mkdir files
cp -r %{_bundledir}/* files
cp %{_sourcedir}/elinux/unnamed-monero-wallet.desktop unnamed-monero-wallet.desktop
cp %{_sourcedir}/assets/logo.png logo.png

%install
mkdir -p %{buildroot}%{_libdir}
mv files/lib/monero_libwallet2_api_c.so %{buildroot}%{_libdir}
mkdir -p %{buildroot}/opt/unnamed-monero-wallet
cp -r files/* %{buildroot}/opt/unnamed-monero-wallet
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/108x108/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/128x128/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/172x172/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/86x86/apps
ffmpeg -i logo.png -vf scale=108:108 %{buildroot}%{_datadir}/icons/hicolor/108x108/apps/unnamed_monero_wallet.png
ffmpeg -i logo.png -vf scale=128:128 %{buildroot}%{_datadir}/icons/hicolor/128x128/apps/unnamed_monero_wallet.png
ffmpeg -i logo.png -vf scale=172:172 %{buildroot}%{_datadir}/icons/hicolor/172x172/apps/unnamed_monero_wallet.png
ffmpeg -i logo.png -vf scale=86:86   %{buildroot}%{_datadir}/icons/hicolor/86x86/apps/unnamed_monero_wallet.png
mkdir -p %{buildroot}%{_datadir}/applications
cp unnamed-monero-wallet.desktop %{buildroot}%{_datadir}/applications/unnamed-monero-wallet.desktop

%files
/opt/unnamed-monero-wallet/
%{_datadir}/icons/hicolor/*/apps/unnamed_monero_wallet.png
%{_datadir}/applications/unnamed-monero-wallet.desktop
%{_libdir}/monero_libwallet2_api_c.so

%changelog
# let's skip this for now

# !/bin/bash
# rpmbuild -bs my_file.spec --define "_bundledir $PWD"
