#!/bin/bash

source components.sh

function create_data_base {
while true; do
    db_name=$(zenity --entry \
      --title="Create Database" \
      --text="Enter The DB Name:")
    
    if [ $? -eq 1 ]; then
      DBmenu
    fi
    
    db_namez=$(echo "$db_name" | awk '{print tolower($0)}')
    echo $db_namez
    
    
    rtrn=$(check_if_dir_exists $db_namez)
    if [ $rtrn == true ]
    then 
      zenity --error --text="A database with the name $db_namez already exists."
    else
      rtrn=$(check_if_name_starts_with_number $db_namez)
      if [ $rtrn == true ]
      then
      zenity --error --text="A database can't Start With Numbers."
      else

		rtrn=$(check_special_char $db_namez)
		if [ $rtrn == true ]
		then
    zenity --error --text="invalid name, avoid using special character\n like: ws, &, *, @"
		else
			mkdir -p "Databases/$db_namez"
      zenity --info --text="Database $db_namez.db created successfully!"
        
		fi
	fi
fi
done
}
create_data_base