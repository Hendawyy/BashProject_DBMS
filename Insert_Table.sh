#!/bin/bash

function Insert_Table() {
  current_dir=$(pwd)
  DB_name=$(basename "$current_dir")
  local Tables_list=$(ls "$current_dir/")

  selected_tb=$(zenity --list \
    --title="List of Tables in $DB_name.db" \
    --text="Choose a Table:" \
    --column="Tables" $Tables_list)

  if [ $? -eq 1 ]; then
    Menu_Table $DB_name
  fi

  table_name=$selected_tb
  column_data=()

  column_names=($(awk -F ' : ' 'NR > 3 {print $1}' "../$DB_name/$table_name/$table_name.md"))
  data_types=($(awk -F ' : ' 'NR > 3 {print $2}' "../$DB_name/$table_name/$table_name.md"))


  for i in "${!column_names[@]}"; do
    column_name="${column_names[i]}"
    data_type="${data_types[i]}"
    echo $column_name: $data_type
    if [[ "$data_type" == "ID--Int--Auto--Inc." ]]; then
      last_value=$(tail -n 1 "../$DB_name/$table_name/$table_name" | cut -d ':' -f 1)
      if [[ -z "$last_value" ]]; then
        column_data+=("1")
      else
        new_value=$((last_value + 1))
        column_data+=("$new_value")
      fi
    elif [[ "$data_type" == "INT" ]]; then
    column_value=$(zenity --entry --title="Enter Value" --text="Enter value for $column_name (INT):")
    column_data+=("$column_value")
    elif [[ "$data_type" == "Double" ]]; then
    column_value=$(zenity --entry --title="Enter Value" --text="Enter value for $column_name (Double):")
    column_data+=("$column_value")
    elif [[ "$data_type" == "Varchar" ]]; then
    column_value=$(zenity --entry --title="Enter Value" --text="Enter value for $column_name (Varchar):")
    column_data+=("$column_value")
    elif [[ "$data_type" == "Phone" ]]; then
    column_value=$(zenity --entry --title="Enter Value" --text="Enter value for $column_name (Phone):")
    column_data+=("$column_value")
    elif [[ "$data_type" == "Email" ]]; then
    column_value=$(zenity --entry --title="Enter Value" --text="Enter value for $column_name (Email):")
    column_data+=("$column_value")
    elif [[ "$data_type" == "Enum" ]]; then
     enum_values=$(awk -F ' : ' 'NR > 3 {print $6}' "../$DB_name/$table_name/$table_name.md" | tr '{}' ' ')
    selected_enum_value=$(zenity --list \
        --title="Select ENUM Value" \
        --text="Select ENUM value for $column_name:" \
        --column="Value" ${enum_values})
    column_data+=("$selected_enum_value")

     if [ $? -eq 1 ]; then
        Insert_Table
     fi
    elif [[ "$data_type" == "Password" ]]; then
      column_value=$(zenity --password --title="Enter Value" --text="Enter password for $column_name:")
      column_data+=("$column_value")
    elif [[ "$data_type" == "Date" ]]; then
      column_value=$(zenity --calendar --title="Select Date" --text="Select date for $column_name:")
      column_data+=("$column_value")
    elif [[ "$data_type" == "Current--Date--Time" ]]; then
      current_datetime=$(date +"%Y-%m-%d---%H:%M:%S")
      column_data+=("$current_datetime")
    fi
  done

  insert_line=$(IFS=':'; echo "${column_data[*]}")
  echo "$insert_line" >> "../$DB_name/$table_name/$table_name"

  zenity --info --text="Data inserted successfully!"
}

Insert_Table
