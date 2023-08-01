#! /bin/bash
: 'desc: a script to check if a directory (database) exists if not it creates the database, else it return "data base already exist try another name" 
'
: '
	later on we should use awk to get the reset of the input from the gui
	for now database name are case senstive
'
read -p "enter DB name: " db_name #can be replaced with $1 if we have argument
full_path="$PWD/$db_name"
if [[ -d $full_path ]]; then			#will return true if DB exists
  echo "database already exists, try another name."
else						#DB doesn't exist
	 db_name_check
fi


function db_name_check {
x=$db_name
#x=$1
echo $x
if [[ $x =~ [\'\"\^\#\`\~\$\%\=\+\<\>\|\:\ \(\)\@\;\?\&\*\\\/]+ ]]
then
	echo "invalid name, avoid using special character"
	echo "like: ws, &, *, @"
elif [[ $x =~ ^[0-9] ]]
then
	echo "DB name can't start with numbers"
else
	echo "valid name"
	mkdir $full_path
fi
}

