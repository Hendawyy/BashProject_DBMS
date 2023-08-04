#!/bin/bash

function Menu_Table() {
selected_table=$(zenity --list \
  --title="Table Menu" \
  --text="Choose an operation for the Database \' $1 \':" \
  --column="Options" \
  "Create Table" \
   "List Tables" \
   "Drop Table" \
   "Insert Into Table" \
   "Select From Table" \
   "Delete From Table" "Update Table")

    if [ $? -eq 1 ]; then
    cd ../..
    echo "Current directory: $(pwd)"
    DBmenu
    fi
}
Menu_Table $1