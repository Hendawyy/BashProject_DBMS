#! /bin/bash
: 'desc: a script to check if a directory (database) exists if not it creates the database, else it return "data base already exist try another name" 
'
: '
	later on we should use awk to get the reset of the input from the gui
	for now database name are case senstive
'
function db_name_check {
x=$REPLY
#x=$1
if [[ $x =~ [\'\"\^\\[\#\`\~\$\%\=\+\<\>\|\:\ \(\)\@\;\?\&\*\\\/]+ ]]
then
        echo "invalid name, avoid using special character"
        echo "like: ws, &, *, @"
elif [[ $x =~ ^[0-9] ]]
then
        echo "DB name can't start with numbers"
else
        echo "valid name"
        mkdir $REPLY
fi
}

read -p "enter DB name: " -e #can be replaced with $1 if we have argument
if [[ -d $REPLY ]]; then			#will return true if DB exists
  echo "database already exists, try another name."
else						#DB doesn't exist
	 db_name_check
fi
