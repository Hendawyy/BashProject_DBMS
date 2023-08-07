#!/bin/bash

function Select_Tb() {

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
  
  data_file="../$DB_name/$table_name/$table_name"
  
  headers=$(awk -F: 'NR==1 {print $0}' "$data_file")
  num_fields=$(awk -F: 'NR==1 {print NF}' "$data_file")
  
  formatted_data="<html>
  <head>
    <style>
      body {
        font-family: Arial, sans-serif;
      }
      table {
        border-collapse: collapse;
        width: 100%;
      }
      th, td {
        border: 1px solid #dddddd;
        text-align: left;
        padding: 8px;
      }
      th {
        background-color: #f2f2f2;
      }
      .icons {
        font-size: 20px;
        cursor: pointer;
      }
    </style>
  </head>
  <center>
  <body>
  <center>
    <h2>$table_name Table</h2>
</center>
    <table>
      <tr>"

  IFS=':' read -ra header_array <<< "$headers"
  for header in "${header_array[@]}"; do
    formatted_data+="<th>$header</th>"
  done
  formatted_data+="<th>Actions</th>"
  formatted_data+="</tr>"

  while IFS=':' read -r -a fields; do
    formatted_data+="<tr>"
    for ((i = 0; i < num_fields; i++)); do
      formatted_data+="<td>${fields[i]}</td>"
    done
    formatted_data+="<td>&#9997; &#128465;</td>"
    
    formatted_data+="</tr>"
  done <<< "$(tail -n +2 "$data_file")"

  formatted_data+="</table>
  </body>
  </center>
</html>"

  zenity --text-info --title="$table_name Table" --width=1080 --height=950 \
    --html --filename=<(echo "$formatted_data")

    if [ $? -eq 1 ]; then
        Menu_Table $DB_name
    fi
}

Select_Tb