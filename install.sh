#!/usr/bin/env bash

set -u
set -e
set -o pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <hostname>"
  exit
fi

workDir=$(dirname $0)
hostname=$1

#setup sources list
wget -q -O - https://apt.mopidy.com/mopidy.gpg | apt-key add -
wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/jessie.list
echo -e "APT::Install-Suggests "0";\nAPT::Install-Recommends "0";" > /etc/apt/apt.conf.d/00-no-recommends-or-suggests
apt-get update -y
apt-get install software-properties-common -y
add-apt-repository ppa:jean-francois-dockes/upnpp1 -y

#install packages
apt-get update -y
apt-get upgrade -y
apt-get install -y avahi-daemon avahi-discover libnss-mdns vim python-pip python-setuptools upmpdcli bluez-tools pulseaudio pulseaudio-module-bluetooth gstreamer1.0-alsa gstreamer1.0-plugins-bad gstreamer1.0-pulseaudio mopidy mopidy-local-sqlite mopidy-dirble mopidy-spotify mopidy-dleyna mpc
pip install -U tzupdate pulsectl sysfs-gpio mopidy-moped Mopidy-Iris mopidy-youtube git+https://github.com/mczerski/mopidy.git@feature/output_volume

#setup filesystem
cp -r --preserve=mode $workDir/etc /
cp -r --preserve=mode $workDir/usr /
cp -r --preserve=mode $workDir/root /
sed -i "s/%HOSTNAME%/$hostname/g" /etc/upmpdcli.conf
sed -i "s/%HOSTNAME%/$hostname/g" /etc/hostname
sed -i "s/%HOSTNAME%/$hostname/g" /etc/hosts

#enable services
systemctl enable pulseaudio
systemctl enable bt-agent
systemctl enable speaker-on-off
systemctl enable mopidy

#add user mopidy to lp group for bluetooth
usermod -a -G lp mopidy

#set timezone
tzupdate

#reboot
reboot
