#!/bin/bash

function Create_Table() {
  table_name=$(zenity --forms \
    --title="Create Table" \
    --text="Enter table name:" \
    --add-entry="Table Name")

  if [ $? -eq 1 ]; then
   zenity --error --text="Table creation failed."
   pwd
   Menu_Table $1
  fi

  num_columns=$(zenity --forms \
    --title="Create Table $table_name" \
    --text="Enter number of columns:" \
    --add-entry="Number of Columns")

  if [ $? -eq 1 ]; then
    zenity --error --text="Table $table_name creation failed."
    Create_Table
  fi

  mkdir -p "$table_name"
  
  touch "$table_name/$table_name"
  echo "Table Name: $table_name" > "$table_name/$table_name.md"
  echo "Number of Columns: $num_columns" >> "$table_name/$table_name.md"
  echo -e "attribute_name : data_type : primary_key(y/n) : auto_increment(y/n) : unique(y/n) : nullable(y/n)" >> "$table_name/$table_name.md"
  columns=()  
  data_types=()  
  primary_keys=()  
  nullable=() 
  unique=()  
  auto_increment=() 

  for ((i = 1; i <= num_columns; i++)); do
    column_info=$(zenity --forms \
      --title="Create Table $table_name" \
      --text="Enter information for Column $i:" \
      --add-entry="Column Name" \
      --add-entry="Nullable (y/n)" \
      --add-entry="Unique (y/n)")

    if [ $? -eq 1 ]; then
     zenity --error --text="Table $table_name creation failed."
     rm -r "$table_name"
     Create_Table
    fi

    column_name=$(echo "$column_info" | cut -d "|" -f 1)
    is_nullable=$(echo "$column_info" | cut -d "|" -f 2)
    is_unique=$(echo "$column_info" | cut -d "|" -f 3)

    if [[ "$is_nullable" != "y" && "$is_nullable" != "n" ]]; then
      zenity --error --text="Invalid value for Nullable in Column $i. Please enter 'y' or 'n'. Table $table_name creation failed."
      rm -r "$table_name"
      Create_Table
    fi

    if [[ "$is_unique" != "y" && "$is_unique" != "n" ]]; then
      zenity --error --text="Invalid value for Unique in Column $i. Please enter 'y' or 'n'. Table $table_name creation failed."
      rm -r "$table_name"
      Create_Table
    fi

    data_type_options=("ID--Int--Auto Inc." "INT" "Double" "Varchar" "Enum" "Phone" "Email" "Password" "Date" "Current Date Time")
    data_type=$(zenity --list \
      --title="Create Table $table_name" \
      --text="Select data type for Column $i:" \
      --column="Data Type" "${data_type_options[@]}")

    if [ $? -eq 1 ]; then
      zenity --error --text="Table $table_name creation failed."
      rm -r "$table_name"
      Create_Table
    fi

    if [ "$data_type" == "ID--Int--Auto Inc." ]; then
      is_auto_increment="y"
    else
      is_auto_increment="n"
    fi

    columns+=("$column_name")
    data_types+=("$data_type")
    nullable+=("$is_nullable")
    unique+=("$is_unique")
    auto_increment+=("$is_auto_increment")
  done

  selected_pk_column=$(zenity --list \
    --title="Create Table $table_name" \
    --text="Select the Primary Key column:" \
    --column="Column" "${columns[@]}")
  

  if [ $? -eq 1 ]; then
    zenity --error --text="Table $table_name creation failed."
    rm -r "$table_name"
    Create_Table
  fi


  for ((i = 0; i < ${#columns[@]}; i++)); do
    if [ "${columns[i]}" == "$selected_pk_column" ]; then
      primary_keys+=("y")
    else
      primary_keys+=("n")
    fi
  done

  if [[ -z $selected_pk_column ]]; then
    zenity --error --text="No Primary Key column selected. You must select at least one Primary Key. Table creation failed."
    Create_Table
    rm -r "$table_name"
  fi

  for ((i = 0; i < ${#columns[@]}; i++)); do
    echo -e "${columns[i]} : ${data_types[i]} : ${primary_keys[i]} : ${auto_increment[i]} : ${unique[i]} : ${nullable[i]}" >> "$table_name/$table_name.md"
  done

  zenity --info --text="Table '$table_name' created successfully!"
}

Create_Table
