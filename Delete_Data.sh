#!/bin/bash

source ../../components.sh

function Delete_Data() {
  current_dir=$(pwd)
  DB_name=$(basename "$current_dir")
  local Tables_list=$(ls "$current_dir/")

  zenity --warning \
    --title="Delete Data From A Table" \
    --text="Check For The Primary Key Value Of the Record You want To Delete."
  
  Select_All
  if [ $? -eq 0 ]; then

    nf=$(awk -F':' 'NR>3 {print NR-3":"$1":"$3}' "$data_file.md")
    index=$(echo "$nf" | awk -F':' '$3 == "y" { print $1 }')
    col=$(echo "$nf" | awk -F':' '$3 == "y" { print $2 }')
    dv=$(zenity --entry --width=400 --height=100 \
      --title="Delete Record" \
      --text="Enter Value Of PK($col) for The Record You Want To Delete")
    
    DT=$(awk -F: -v selected_col="$col" '$1 == selected_col {print $2}' "$data_file.md")
    
    rtrn=$(data_type_match "$DT" "$dv")
    
    if [ "$rtrn" == true ]; then
      ltd=$(awk -v idx="$index" -v val="$dv" -F';' '$idx == val { print $0 }' "$data_file")
      echo "Line To Be Deleted : $ltd"
      
      zenity --question --width=400 --height=100  --text="Are you sure you want to delete this record?"
      response=$?
      
      if [ "$response" -eq 0 ]; then
        sed -i "\|$ltd|d" "$data_file"
        zenity --info --width=400 --height=100  --text="Record Deleted Successfully"
        Menu_Table "$DB_name"
      else
        zenity --info --width=400 --height=100  --text="You Chose Not To Delete The Record."
        Menu_Table "$DB_name"
      fi
      
      sed -i "/$ltd/d" "$data_file"
      
      if [ $? -eq 1 ]; then
        Menu_Table "$DB_name"
      fi
    else
      zenity --error --width=400 --height=100  --text="Data Type Mismatch The Expected Value Must Be : $DT"
      Menu_Table "$DB_name"
    fi
  fi
}

Delete_Data
