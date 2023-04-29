#!/bin/bash

#TODO: check if ips file can be opened

#Global variables and constants

SSH_OPTIONS="-ostricthostkeychecking=no"
user_command=""

display_welcome_screen() {
	clear
	echo -e "\nWelcome to SSH Mass Command Sender\n"
	echo -e "Usage: ./script.sh IPS_FILE USERNAME PASSWORD(not mandatory)\n"
	echo -e "Please, make sure your ips file ends with a new line character\n"
}

create_logs_folder() {
	if ! [ -d "./logs" ]; then
		mkdir logs
		if [ $? -ne 0 ]; then
			user_option = ""
			while [ $user_option != "n" ] || [ $user_option != "y" ]; do
				read -p "Failed to create logs folder. Proceed y/n? "
				echo -e "\n"
			done
			if [ $user_option == "n" ]; then
				exit
			fi
		fi
	fi 
}
		
check_parameters() {
	# If the string is null, it means there is no value for the first argument
	if  [ -z "$1" ]  ||  [ -z "$2" ]; then	
		if  [ -z "$1" ]; then
			echo -e "No argument IPS_FILE provided. Exiting.\n"
		elif [ -z "$2" ]; then
			echo -e "No argument USERNAME provided. Exiting.\n"
		fi
		exit
	fi
}

check_for_ssh_and_sshpass() {
	if ! command -v ssh &> /dev/null; then
		echo -e "SSH not present. Please check your PATH or install SSH\n"	
		exit
	fi

	if ! command -v sshpass &> /dev/null; then
		echo -e "SSHPass not present. Please check your PATH or install SSHPass\n"
		exit
	fi
}

get_user_command() {
	read -r -p "Please, provide the command you want to send over SSH: " user_command
}

send_command() {
	#TODO: Validate if the line contains only an ip address.
	while read line; do
		sshpass -p$3 ssh $2@$line $SSH_OPTIONS "${user_command}" > "./logs/${line}_$(date +"%y%m%d%H%M%S").log" &
	done < "$1" 
	echo -e "\nCommands sent. Please, check the logs folder for results. Exiting.\n"
}

display_welcome_screen
check_for_ssh_and_sshpass
check_parameters $1 $2
create_logs_folder
get_user_command
send_command $1 $2 $3

exit

