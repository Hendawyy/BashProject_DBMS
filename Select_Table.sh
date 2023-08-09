#!/bin/bash

source ../../components.sh

function Select_Tb() {
  current_dir=$(pwd)
  DB_name=$(basename "$current_dir")
  local Tables_list=$(ls "$current_dir/")
  local type=("All(*)" "Columns")
  local con=("Condition" "Conditionless")

  conn=$(zenity --list \
    --title="How do you wish to select for the $DB_name.db" \
    --text="Choose a Method:" \
    --column="Tables" "${con[@]}")

  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  else
    type=$(zenity --list \
      --title="How do you wish to select for the $DB_name.db" \
      --text="Choose a Method:" \
      --column="Tables" "${type[@]}")

    if [ $? -eq 1 ]; then
      Select_Tb
    fi

    if [ "$conn" == "Condition" ]; then
      Select_With_Condition "$type"
    elif [ "$conn" == "Conditionless" ]; then
      Select_Without_Condition "$type"
    fi
  fi
}


Select_Tb