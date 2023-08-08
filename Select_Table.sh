#!/bin/bash

source ../../components.sh

function Select_Tb() {
  current_dir=$(pwd)
  DB_name=$(basename "$current_dir")
  local Tables_list=$(ls "$current_dir/")
  local type=("All(*)" "Columns")
  
  type=$(zenity --list \
    --title="How do you wish to select for the $DB_name.db" \
    --text="Choose a Method:" \
    --column="Tables" ${type[*]})
    
  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  fi

  if [ "$type" == "All(*)" ]; then
    Select_All
  elif [ "$type" == "Columns" ]; then
    echo "cols"
  fi
}

Select_Tb