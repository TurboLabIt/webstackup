#!/usr/bin/env bash

## Title printing function
function printTitle {

    echo ""
    echo "$1"
    printf '%0.s-' $(seq 1 ${#1})
    echo ""
}

printTitle "zzgit"
echo $(pwd)


printTitle "Checking if the current folder is a Git repo"
if [ ! -f ".git/config" ]; then

	echo "vvvvvvvvvvvvvvvvvvvv"
	echo "Catastrophic error!!"
	echo "^^^^^^^^^^^^^^^^^^^^"
	echo "##$(pwd)## is NOT a git dir"
	echo ""
	exit
	
else

	echo "OK! It's a repo!"
	cat ".git/config" | grep 'url = '
fi


printTitle "Acquiring owner"
GITUSER=$(stat -c '%U' ".git/config")
echo $GITUSER


printTitle "Checking current user matching"
CURRENTUSER=$(whoami)
if [ "$CURRENTUSER" == "$GITUSER" ]; then
	
	echo "Current user match! No sudo necessary"
	function zzgitcmd {

		git "$@"
	}

else

	echo "Current user DOESN'T match! Will sudo commands as $GITUSER"
	function zzgitcmd {

		sudo -u $GITUSER -H git "$@"
	}
fi


if [ "$1" == "push" ]; then

	printTitle "Display current status"
	zzgitcmd status
	read -p "Proceed with add,commit,push? " -n 1 -r
	echo
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then

		printTitle "KO, aborting."
		echo
		exit
	fi


	printTitle "Git add"
	zzgitcmd add .

	printTitle "Git commit"
	zzgitcmd commit --allow-empty-message -m "${2}"

	printTitle "Git pull"
	zzgitcmd pull

	printTitle "Git push"
	zzgitcmd push
	
elif [ "$1" == "pull" ]; then

	zzgitcmd pull
fi


printTitle "Operation completed"
echo ""
