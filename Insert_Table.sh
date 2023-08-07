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
    echo "Table selection canceled."
    return
  fi
  
  table_name=$selected_tb

  column_data=()

   column_name=$(awk -F ' : ' 'NR > 3 {print $1}' "../$DB_name/$selected_tb/$selected_tb.md")
   data_type=$(awk -F ' : ' 'NR > 3 {print $2}' "../$DB_name/$selected_tb/$selected_tb.md")
   primary_key=$(awk -F ' : ' 'NR > 3 {print $3}' "../$DB_name/$selected_tb/$selected_tb.md")
   unique=$(awk -F ' : ' 'NR > 3 {print $4}' "../$DB_name/$selected_tb/$selected_tb.md")
   nullable=$(awk -F ' : ' 'NR > 3 {print $5}' "../$DB_name/$selected_tb/$selected_tb.md")
   echo $column_name
   echo $data_type
   echo $primary_key
   echo $unique
   echo $nullable


for i in "${!column_name[@]}"; do
  echo "Inserting data for column: ${column_name[i]}"

  if [[ "${data_type[i]}" == "ID--Int--Auto Inc." ]]; then
  last_value=$(tail -n 1 "$table_name/$table_name" | awk -F ':' '{print $1}')
  if [[ -z "$last_value" ]]; then
    column_data+=("1")
  else
    new_value=$((last_value + 1))
    column_data+=("$new_value")
  fi
fi
if [[ "${data_type[i]}" == "INT" ]]; then
  column_value=$(zenity --entry --title="Enter Value" --text="Enter value for ${columns[i]}:")
fi
if [[ "${data_type[i]}" == "Double" ]]; then
  column_value=$(zenity --entry --title="Enter Value" --text="Enter value for ${columns[i]}:")
fi
if [[ "${data_type[i]}" == "Varchar" ]]; then
  column_value=$(zenity --entry --title="Enter Value" --text="Enter value for ${columns[i]}:")
fi
if [[ "${data_type[i]}" == "Enum" ]]; then
  num_items=$(zenity --entry --title="Enter Number of Items" --text="Enter the number of items in ENUM for ${columns[i]}:")
  enum_values=()
  for ((j = 1; j <= num_items; j++)); do
    value=$(zenity --entry --title="Enter Value" --text="Enter value $j for ${columns[i]}:")
    enum_values+=("$value")
  done
fi
if [[ "${data_type[i]}" == "Phone" ]]; then
  column_value=$(zenity --entry --title="Enter Value" --text="Enter value for ${columns[i]}:")
fi
if [[ "${data_type[i]}" == "Email" ]]; then
  column_value=$(zenity --entry --title="Enter Value" --text="Enter value for ${columns[i]}:")
fi
if [[ "${data_type[i]}" == "Password" ]]; then
  column_value=$(zenity --password --title="Enter Value" --text="Enter password for ${columns[i]}:")
fi
if [[ "${data_type[i]}" == "Date" ]]; then
  column_value=$(zenity --calendar --title="Select Date" --text="Select date for ${columns[i]}:")
fi
if [[ "${data_type[i]}" == "Current Date Time" ]]; then
    current_datetime=$(date)
    column_data+=("$current_datetime")
fi
  column_data+=("$column_value")
done

insert_line=$(IFS=':'; echo "${column_data[*]}")

echo "$insert_line" >> "$table_name/$table_name"

zenity --info --text="Data inserted successfully!"


}
Insert_Table