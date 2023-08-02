#!/bin/bash

source components.sh

function create_database() {
  while true; do
    db_name=$(zenity --entry \
      --title="Create Database" \
      --text="Enter The DB Name:")

    if [ $? -eq 1 ]; then
      DBmenu
      return
    fi

    if ! chckNameRegex "$db_name"; then
      continue
    fi
    if [ -d "Databases/$db_name" ]; then
        zenity --error --text="A database with the name '$db_name' already exists."
     else
        mkdir -p "Databases/$db_name"
        zenity --info --text="Database '$db_name'.db created successfully!"
        return

    fi
  done
}


# fun_name: create_data_base
: 'desc: a script to check if a directory (database) exists if not it creates the database, else it return "data base already exist try another name" 
'
function create_data_base {
read -p "enter DB name: " -e
rtrn=$(check_if_dir_exists $REPLY)
if [ $rtrn == true ]
then 
	echo "DB name already taken"
else
	rtrn=$(check_if_name_starts_with_number $REPLY)
	if [ $rtrn == true ]
	then
		echo "DB name can't start with numbers"
	else

		rtrn=$(check_special_char $REPLY)
		if [ $rtrn == true ]
		then
			echo "invalid name, avoid using special character"
			echo "like: ws, &, *, @"
		else
			mkdir $REPLY
			echo "database created!!"
		fi
	fi
fi
}

create_data_base
#(refactor to the code to enhance its reusability)
