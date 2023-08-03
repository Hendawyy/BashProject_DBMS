#!/bin/bash

source components.sh

function create_data_base {
while true; do
    db_name=$(zenity --entry \
      --title="Create Database" \
      --text="Enter The DB Name:")
    
    $db_name=$(echo "$db_name" | awk '{print tolower($0)}')

    if [ $? -eq 1 ]; then
      DBmenu
      return
    fi
    rtrn=$(check_if_dir_exists $db_name)
    if [ $rtrn == true ]
    then 
      zenity --error --text="A database with the name '$db_name' already exists."
    else
      rtrn=$(check_if_name_starts_with_number $db_name)
      if [ $rtrn == true ]
      then
      zenity --error --text="A database can't Start With Numbers."
      else

		rtrn=$(check_special_char $db_name)
		if [ $rtrn == true ]
		then
    zenity --error --text="invalid name, avoid using special character\n like: ws, &, *, @"
		else
			mkdir -p "Databases/$db_name"
      zenity --info --text="Database '$REPLY'.db created successfully!"
        
		fi
	fi
fi
done
}
create_data_base