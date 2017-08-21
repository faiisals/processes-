#! /bin/bash

#This scripts will help you if you have a suspecios process ID, you can find it's childs and how many file descriptors it opened.
#it will run perfictly in CentOS 


main() {

#Firsh check if no pid is supplyed, if no display help, if yes execute the functions.

if [ $# -eq 1 ]; then 

		get_process_name $@
		get_childs_names $@
		get_number_of_fd $@

	else 

		display_help
fi
}


display_help () {

	printf "You must supply process id number!! for ex: ./processes.sh 9021 "
}




get_number_of_fd() {

#returns the number of open file descriptors of. aprocess (only if you are the owner if the file or you are the root)

userID=$(ps -p $1 -o uid --noheaders)

printf "Number of fd: \t"
if [ "$UID" == "0"]; then 
		ls /proc/$1/fd | wc -l 
	elif ["  $UID" == "$userID"]; then 
		ls /proc/$1/fd | wc -l 
	else 
		echo "YOU NEED ROOT PREVILAGES"

fi

}



get_childs_names() {

#returns the childs names of process, if it has no child it will return "None".

flag="false"
printf "Childs names: \t" 

while read line;
do
	printf "<$line> "
	flag="true"
done < <( ps --ppid $1 -o cmd --noheaders )


if [$flag == 'false']; then 
	printf "None"
fi 

printf "\n"

}


get_process_name () {

#returns the process name as displayed in ps command.

printf "Process name: \t"
	ps -p $1 -o cmd --noheaders
}




main $@ 












