#!/bin/bash

function Insert_Table() {
  current_dir=$(pwd)
  DB_name=$(basename "$current_dir")
  local Tables_list=$(ls "$current_dir/")

  selected_tb=$(zenity --list --width=300 --height=250 \
    --title="List of Tables in $DB_name.db" \
    --text="Choose a Table:" \
    --column="Tables" $Tables_list)

  if [ $? -eq 1 ]; then
    Menu_Table $DB_name
  fi

  table_name=$selected_tb

  column_names=($(awk -F ':' 'NR > 3 {print $1}' "../$DB_name/$table_name/$table_name.md"))
  data_types=($(awk -F ':' 'NR > 3 {print $2}' "../$DB_name/$table_name/$table_name.md"))
  PKin=($(awk -F ':' 'NR > 3 {print $3}' "../$DB_name/$table_name/$table_name.md"))
  Uniquein=($(awk -F ':' 'NR > 3 {print $4}' "../$DB_name/$table_name/$table_name.md"))
  nullablen=($(awk -F ':' 'NR > 3 {print $5}' "../$DB_name/$table_name/$table_name.md"))
 
  column_data=()
  flag=0
  for i in "${!column_names[@]}"; do
    column_name="${column_names[i]}"
    data_type="${data_types[i]}"
    PKz="${PKin[i]}"
    Uniquez="${Uniquein[i]}"
    nullablez="${nullablen[i]}"
    colzzz=($(awk -F ':' -v cn=$column_name '$1 == cn  {print NR-3}' "../$DB_name/$table_name/$table_name.md"))

    # echo $column_name: $data_type
    if [[ "$data_type" == "ID--Int--Auto--Inc." ]]; then
      last_value=$(tail -n 1 "../$DB_name/$table_name/$table_name" | cut -d ';' -f 1)
      if [[ -z "$last_value" ]]; then
        column_data+=("1")
        # echo "lv:"$last_value
        # echo "cd:" $column_data
        continue #Added This during debugging Produced error on PK
      else
        new_value=$((last_value + 1))
        column_data+=("$new_value")
        # echo "lv:"$last_value
        # echo "NV:" $new_value
        # echo "cd:" $column_data
        continue
      fi
    elif [[ "$data_type" == "INT" ]]; then
    column_value=$(zenity --width=400 --height=100 --entry --title="Enter Value" --text="Enter value for $column_name (INT):")
    rtrn=$(data_type_match $data_type $column_value)
    if [ $rtrn == true ]; then
      column_data+=("$column_value")
    else
      zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $data_type"
      Insert_Table
    fi
    elif [[ "$data_type" == "Double" ]]; then
    column_value=$(zenity --entry --width=400 --height=100 --title="Enter Value" --text="Enter value for $column_name (Double):")
    rtrn=$(data_type_match $data_type $column_value)
    if [ $rtrn == true ]; then
      column_data+=("$column_value")
    else
      zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $data_type"
      Insert_Table
    fi
    elif [[ "$data_type" == "Varchar" ]]; then
    column_value=$(zenity --entry --width=400 --height=100 --title="Enter Value" --text="Enter value for $column_name (Varchar):")
    rtrn=$(data_type_match $data_type $column_value)
    if [ $rtrn == true ]; then
      column_data+=("$column_value")
    else
      zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $data_type"
      Insert_Table
    fi
    elif [[ "$data_type" == "Phone" ]]; then
    column_value=$(zenity --entry --width=400 --height=100 --title="Enter Value" --text="Enter value for $column_name (Phone):")
    rtrn=$(data_type_match $data_type $column_value)
    if [ $rtrn == true ]; then
      column_data+=("$column_value")
    else
      zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $data_type"
      Insert_Table
    fi
    elif [[ "$data_type" == "Email" ]]; then
    column_value=$(zenity --entry --width=400 --height=100 --title="Enter Value" --text="Enter value for $column_name (Email):")
    rtrn=$(data_type_match $data_type $column_value)
    if [ $rtrn == true ]; then
      column_data+=("$column_value")
    else
      zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $data_type"
      Insert_Table
    fi
    elif [[ "$data_type" == "Enum" ]]; then
     enum_values=$(awk -F ':' 'NR > 3 {print $6}' "../$DB_name/$table_name/$table_name.md"| tr '{}' ' ')

    selected_enum_value=$(zenity --list --width=300 --height=250 \
        --title="Select ENUM Value" \
        --text="Select ENUM value for $column_name:" \
        --column="Value" ${enum_values})
    column_data+=("$selected_enum_value")

     if [ $? -eq 1 ]; then
        Insert_Table
     fi
    elif [[ "$data_type" == "Password" ]]; then
      column_value=$(zenity --width=500 --height=100 --password --title="Enter Value" --text="Enter password for $column_name:")
      rtrn=$(validate_password_strength "$column_value")
    if [ $rtrn == false ]; then
          zenity --error --width=400 --height=100 --text="Password must have at least 8 characters ,has at least one digit,has at least one Upper case Alphabet,has at least one Lower case Alphabet"
          Insert_Table
    else
          column_data+=("$column_value")
    fi
    elif [[ "$data_type" == "Date" ]]; then
      column_value=$(zenity --calendar --width=300 --height=250 --title="Select Date" --text="Select date for $column_name:")
      column_data+=("$column_value")
    elif [[ "$data_type" == "Current--Date--Time" ]]; then
      current_datetime=$(date +"%Y-%m-%d---%H:%M:%S")
      column_data+=("$current_datetime")
    fi
    #echo echo $colzzz:"cv":$column_value
     if [ $Uniquez == "y" ]
        then
            asden=$(check_for_unique "$colzzz" "$table_name/$table_name" $column_value)
            # echo "asddas":$asden
            if [ $asden == "false" ]
            then
                zenity --error --width=400 --height=100 --text="Unique values can't be repeated"
                flag=1
                Insert_Table
            fi
        fi
        if [ $nullablez == "y" ]
        then
            if [ $(check_for_not_null $column_value) == false ]
            then
                zenity --error --width=400 --height=100 --text="This argument is required and can't be null"
                flag=1
                Insert_Table
            fi
        fi
        if [ $PKz == "y" ]
        then
            if [ $(check_for_pk $colzzz "$table_name/$table_name" $column_value) == false ]
            then
                zenity --error --width=400 --height=100 --text="Value doesn't meet Primary Key constraints"
                flag=1
                Insert_Table
            fi
        fi
  done
  if [[ $flag -eq 0 ]]
    then
    insert_line=$(IFS=';'; echo "${column_data[*]}")
    echo "$insert_line" >> "../$DB_name/$table_name/$table_name"
    zenity --info --width=400 --height=100 --text="Data inserted successfully!"
    Menu_Table $DB_name
  else
     zenity --error --width=400 --height=100 --text="Data insertion Failed!"
     Insert_Table
  fi
}

Insert_Table
