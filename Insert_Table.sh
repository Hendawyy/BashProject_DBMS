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
  metadata_file="$table_name/$table_name.md"
  column_data=()
  
  
  form_fields=""
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
        form_fields+="--add-entry=\"$column_info (INT)\" "
        ;;
      "Double")
        form_fields+="--add-entry=\"$column_info (Double)\" "
        ;;
      "Varchar")
        form_fields+="--add-entry=\"$column_info (Varchar)\" "
        ;;
      "Enum")
        form_fields+="--add-entry=\"$column_info (Enum)\" "
        ;;
      "Email")
        form_fields+="--add-entry=\"$column_info (Email)\" "
        ;;
      "Password")
        form_fields+="--add-entry=\"$column_info (Password)\" "
        ;;
      "Date")
        form_fields+="--add-Calendar=\"$column_info (Date)\" "
        ;;
      "Current Date Time")
        ;;
      "Phone")
        form_fields+="--add-entry=\"$column_info (Phone)\" "
        ;;
    esac
  done < "$metadata_file"

  form_fields+="--cancel-label=Go Back"
  
  user_input=$(zenity --forms \
    --title="Insert Data" \
    --text="Enter data for each column:" \
    $form_fields)

  if [ $? -eq 1 ]; then
    Insert_Table
  fi

}

Insert_Table