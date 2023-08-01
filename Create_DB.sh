#! /bin/bash
: 'desc: a script to check if a directory (database) exists if not it creates the database, else it return "data base already exist try another name" 
'
: '
	later on we should use awk to get the reset of the input from the gui
	for now database name are case senstive
'
read -p "enter DB name: " db_name #can be replaced with $1 if we have argument
full_path="$PWD/$db_name"
if [ -d $full_path ]; then			#will return true if DB exists
  echo "database already exists, try another name."
else						#DB doesn't exist
       : 'we should implement function for regex and DB names constrains
	 
	 it should be used before creating tables too
	 '
	 #mkdir $full_path
fi
