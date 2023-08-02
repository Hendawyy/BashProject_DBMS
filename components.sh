#!/bin/bash

function chckNameRegex() {
  local name=$1

  if [[ ! $name =~ ^[[:alpha:]][[:alnum:]]*$ ]]; then
    zenity --error --text="Invalid name! It should not start with a number or have special characters."
    return 1
  else
    name=$(echo "$name" | awk '{print tolower($0)}')
    return 0
  fi
}

function check_special_char {
x=$1
if [[ $x =~ [\'\"\^\\[\#\`\~\$\%\=\+\<\>\|\:\ \(\)\@\;\?\&\*\\\/]+ ]]
then
	echo true
else
	echo false
fi
}


function check_if_name_starts_with_number {
if [[ $1 =~ ^[0-9] ]]
then
	echo true
else
	echo false
fi
}


function check_if_dir_exists {
	if [[ -d $1 ]]
	then
		echo true
	else
		echo false
	fi
}



function list_databases() {
  local database_list=$(ls -d Databases/* | sed 's|.*/||' | awk '{print $0 ".db"}')

  selected_db=$(zenity --list \
    --title="List of Databases" \
    --text="Choose a DB to connect to:" \
    --column="Databases" $database_list)

  if [ $? -eq 1 ]; then
    DBmenu
    return
  fi

  zenity --question --text="Do you want to connect to '$selected_db'.db?"
  response=$?
  if [ $response -eq 0 ]; then
    connect_to_database "$selected_db"
  else
    echo "You chose not to connect to any database."
    DBmenu
    return
  fi
}

function connect_to_database() {
  local db_name=$1

  cd "Databases/$db_name"
  echo "You are now connected to the database: $db_name.db"
  echo "Current directory: $(pwd)"
}

