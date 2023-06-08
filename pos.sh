#!/bin/bash
## ------------------
trap '' 2 
stty susp undef
## ------------------
while :; do
	rm tmp/session.lock
	dialog --title " Login [1/2] " \
	--ok-label "Enter" \
	--no-cancel \
	--form "Enter Registered User" 8 40 0 \
	"Username" 1 2 "$emp" 1 12 25 15 > tmp/session.lock \
	2>&1 >/dev/tty
	if [[ ! -z $(grep '[^[:space:]]' tmp/session.lock) ]]; then
		username=`sed -n 1p tmp/session.lock`
		if [ $(cat data/user.csv | grep -w "$username" | wc -l) -eq 1 ]; then
			pass=$(dialog --title " Login [2/2] " \
			--no-cancel \
			--ok-label "Enter" \
			--insecure \
			--passwordform "Entering: $username" 8 40 0 \
			"Password" 1 2 "$emp" 1 12 25 22 \
			2>&1 >/dev/tty)
			if [[ $(echo $pass | md5sum | cut -d ' ' -f 1) == $(cat data/user.csv | grep -w "$username" | cut -d ',' -f 2) ]]; then
				bash src/dashboard.sh $username $(cat data/user.csv | grep -w "$username" | cut -d ',' -f 4)
				exit 0
			fi
		fi
	fi
done