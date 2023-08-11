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
    
    rtrn=$(check_for_empty_string $db_namez)
    if [ "$rtrn" == false ]; then
        rtrn=$(check_if_dir_exists $db_namez)
        if [ "$rtrn" == true ]; then 
            zenity --error --text="A database with the name $db_namez already exists."
        else
            rtrn=$(check_if_name_starts_with_number $db_namez)
            if [ "$rtrn" == true ]; then
                zenity --error --text="A database can't Start With Numbers."
            else
                rtrn=$(check_special_char $db_namez)
                if [ "$rtrn" == true ]; then
                    zenity --error --text="invalid name, avoid using special characters like: ws, &, *, @"
                else
                    mkdir -p "Databases/$db_namez"
                    zenity --info --text="Database $db_namez.db created successfully!"
                    break  
                fi
            fi
        fi
    else
        zenity --error --text="DB Name can't be Empty"
    fi
done
}
create_data_base
