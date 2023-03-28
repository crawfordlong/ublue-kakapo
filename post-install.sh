#!/bin/sh

set -ouex pipefail

systemctl enable rpm-ostreed-automatic.timer
systemctl enable flatpak-system-update.timer

systemctl enable tlp
systemctl mask power-profiles-daemon.service
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
tlp start

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.mozilla.firefox
flatpak install --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )

flatpak uninstall f

systemctl --global enable flatpak-user-update.timer

cp /usr/share/ublue-os/ublue-os-update-services/etc/rpm-ostreed.conf /etc/rpm-ostreed.conf
