#!/bin/bash
echo "Setting permissions"
# Config file must not be world-readable due to sensitive data
chown -R tyk:tyk /opt/tyk-pump
chmod 660 /opt/tyk-pump/pump.conf

echo "Installing init scripts..."

SYSTEMD="/lib/systemd/system"
UPSTART="/etc/init"
SYSV1="/etc/init.d"
SYSV2="/etc/rc.d/init.d/"
DIR="/opt/tyk-pump/install"

if [ -d "$SYSTEMD" ] && systemctl status > /dev/null 2> /dev/null; then
	echo "Found Systemd"
	[ -f /etc/default/tyk-pump ] || cp $DIR/inits/systemd/default/tyk-pump /etc/default/
	cp $DIR/inits/systemd/system/tyk-pump.service /lib/systemd/system/
	systemctl --system daemon-reload
	exit
fi

if [ -d "$UPSTART" ]; then
	[ -f /etc/default/tyk-pump ] || cp $DIR/inits/upstart/default/tyk-pump /etc/default/
	if [[ "$(initctl version)" =~ .*upstart[[:space:]]1\..* ]]; then
		echo "Found upstart 1.x+"
		cp $DIR/inits/upstart/init/1.x/tyk-pump.conf /etc/init/
	else
		echo "Found upstart 0.x"
		cp $DIR/inits/upstart/init/0.x/tyk-pump.conf /etc/init/
	fi
	exit
fi

if [ -d "$SYSV1" ]; then
	echo "Found SysV1"
	[ -f /etc/default/tyk-pump ] || cp $DIR/inits/sysv/default/tyk-pump /etc/default/
	cp $DIR/inits/sysv/init.d/tyk-pump /etc/init.d/
	exit
fi

if [ -d "$SYSV2" ]; then
	echo "Found Sysv2"
	[ -f /etc/default/tyk-pump ] || cp $DIR/inits/sysv/default/tyk-pump /etc/default/
	cp $DIR/inits/sysv/init.d/tyk-pump /etc/rc.d/init.d/
	exit
fi
