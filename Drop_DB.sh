#!/bin/bash

# Function to delete the selected database directory
function Drop_DB() {
  local database_list=$(ls -d Databases/* | sed 's|.*/||')

  local database_list_with_extension=""
    for db in $database_list; do
        database_list_with_extension+="$db.db "
    done

  selected_db=$(zenity --list \
    --title="List of Databases" \
    --text="Choose a database to Drop:" \
    --column="Databases" $database_list_with_extension)
  
  if [ $? -eq 1 ]; then
    DBmenu
    return
  fi

  zenity --question --text="Are you sure you want to delete the database '$selected_db'?\nAll tables and data inside this database will be permanently deleted."

  response=$?
  if [ $response -eq 0 ]; then
    rm -r "Databases/$selected_db"
    zenity --info --text="Database '$selected_db' has been successfully deleted."
  else
    zenity --info --text="Deletion of database '$selected_db' has been canceled."
  fi
}

Drop_DB
