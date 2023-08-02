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

create_database
 