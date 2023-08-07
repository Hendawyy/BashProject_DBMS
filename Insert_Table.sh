#!/bin/bash

function Insert_Table() {

  current_dir=$(pwd)

  DB_name=$(basename "$current_dir")

  local Tables_list=$(ls "$current_dir/")

  selected_tb=$(zenity --list \
    --title="List of Tables in $DB_name.db" \
    --text="Choose a Table:" \
    --column="Tables" $Tables_list)

  table_name=$selected_tb
  echo $table_name
  metadata_file="$table_name/$table_name.md"
  column_data=()

  while IFS= read -r line; do
    if [[ $line == "attribute_name"* ]]; then
      continue  
    fi
    column_info=$(echo "$line" | awk -F ' : ' '{print $1}')
    data_type=$(echo "$line" | awk -F ' : ' '{print $2}')
    primary_key=$(echo "$line" | awk -F ' : ' '{print $3}')
    auto_increment=$(echo "$line" | awk -F ' : ' '{print $4}')
    unique=$(echo "$line" | awk -F ' : ' '{print $5}')
    nullable=$(echo "$line" | awk -F ' : ' '{print $6}')

    case $data_type in
      "ID--Int--Auto Inc.")
        ;;
      "INT")
        ;;
      "Double")
        ;;
      "Varchar")
        ;;
      "Enum")
        ;;
      "Email")
        ;;
      "Password")
        ;;
      "Date")
        ;;
      "Current Date Time")
        ;;
      "Phone")
        ;;
    esac
  done < "$metadata_file"

  insert_line=$(IFS=':'; echo "${column_data[*]}")

  echo "$insert_line" >> "$table_name/$table_name"

  zenity --info --text="Data inserted successfully!"
}

Insert_Table
