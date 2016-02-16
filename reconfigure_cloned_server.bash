#!/usr/bin/env bash
# Reconfigure cloned server

cwd="$(pwd)"

oldname=''
newname=''

ip='127.0.0.1'

echo -n "Enter the previous name: "
read oldname
if [[ "x$oldname" != "x" ]]; then
	echo -n "Enter the new name: "
	read newname

	if [[ "x$newname" != "x" ]]; then

		echo -n "Migrating $oldname -> $newname? (y/N): "
		read sure

		case $sure in
			[yY]) echo "Ok";;
			*) exit;;
		esac

    ###
    #  SERVER
    ###

		# SSH Key
		rm /etc/ssh/ssh_host_*
		/usr/sbin/dpkg-reconfigure openssh-server

    hostname $newname
		echo $ip $newname >> /etc/hosts

		echo "Rememeber to exec at client machines:"
		echo "  ssh-keygen -R $newname"
		echo "  ssh-keygen -R $ip"

    ###
    #  DOKKU
    ###
		cd /home/dokku

    cat HOSTNAME | sed "s/$oldname/$newname/g" > HOSTNAME
    cat VHOST | sed "s/$oldname/$newname/g" > VHOST

		for proj in  */; do
			for file in nginx.conf URL URLS VHOST; do
				cp -n "${proj}${file}" "${proj}${file}_MIGRATION_BACKUP" &&
				cat "${proj}${file}" | sed "s/$oldname/$newname/g" > "${proj}${file}"
			done
		done
		cd "$cwd"
	fi
fi
