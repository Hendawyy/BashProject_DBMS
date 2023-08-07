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

  metadata_file="$table_name/$table_name.md"
  column_data=()

 
   column_name=$(awk -F ' : ' 'NR > 3 {print $1}' "../$DB_name/$selected_tb/$selected_tb.md")
   data_type=$(awk -F ' : ' 'NR > 3 {print $2}' "../$DB_name/$selected_tb/$selected_tb.md")
   primary_key=$(awk -F ' : ' 'NR > 3 {print $3}' "../$DB_name/$selected_tb/$selected_tb.md")
   auto_increment=$(awk -F ' : ' 'NR > 3 {print $4}' "../$DB_name/$selected_tb/$selected_tb.md")
   unique=$(awk -F ' : ' 'NR > 3 {print $5}' "../$DB_name/$selected_tb/$selected_tb.md")
   nullable=$(awk -F ' : ' 'NR > 3 {print $6}' "../$DB_name/$selected_tb/$selected_tb.md")
   echo $column_name
   echo $data_type
   echo $primary_key
   echo $auto_increment
   echo $unique
   echo $nullable



for i in "${!column_name[@]}"; do
  echo "Inserting data for column: ${column_name[i]}"

  if [[ "${data_type[i]}" == "ID--Int--Auto Inc." ]]; then
  elif [[ "${data_type[i]}" == "INT" ]]; then
  elif [[ "${data_type[i]}" == "Double" ]]; then
  elif [[ "${data_type[i]}" == "Varchar" ]]; then
  elif [[ "${data_type[i]}" == "Enum" ]]; then
  elif [[ "${data_type[i]}" == "Phone" ]]; then
  elif [[ "${data_type[i]}" == "Email" ]]; then
  elif [[ "${data_type[i]}" == "Password" ]]; then
  elif [[ "${data_type[i]}" == "Date" ]]; then
  elif [[ "${data_type[i]}" == "Current Date Time" ]]; then
  fi
done
data_type_options=("ID--Int--Auto Inc." "INT" "Double" "Varchar" "Enum" "Phone" "Email" "Password" "Date" "Current Date Time")
  
insert_line=$(IFS=':'; echo "${column_data[*]}")

echo "$insert_line" >> "$table_name/$table_name"

zenity --info --text="Data inserted successfully!"


}
Insert_Table