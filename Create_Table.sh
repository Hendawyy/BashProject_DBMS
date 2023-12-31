#!/bin/bash

function Create_Table() {
  table_name=$(zenity --entry --width=400 --height=100  \
    --title="Create Table" \
    --text="Enter Table name:")

  if [ $? -eq 1 ]; then
   zenity --error --text="Table creation failed."
   pwd
   Menu_Table $1
  fi

  rtrn=$(Tb_txf "$table_name")
  if [ "$rtrn" != true ]; then
    Create_Table
  else
    num_columns=$(zenity --entry --width=400 --height=100  \
      --title="Create Table $table_name" \
      --text="Enter number of columns:" )

    if [ $? -eq 1 ]; then
      zenity --error --text="Table $table_name creation failed."
      Create_Table
    fi

    rtrn=$(isNumber "$num_columns")
    if [ "$rtrn" == "false" ]; then
      zenity --error --text="Must Enter A Valid Number."
    else
      mkdir "$table_name"
      touch "$table_name/$table_name" "$table_name/$table_name.md"
      echo "Table Name:$table_name" > "$table_name/$table_name.md"
      echo "Number of Columns:$num_columns" >> "$table_name/$table_name.md"
      echo -e "attribute_name:data_type:primary_key(y/n):unique(y/n):nullable(y/n)" >> "$table_name/$table_name.md"
      columns=()
      data_types=()
      primary_keys=()
      nullable=()
      unique=()

      for ((i = 1; i <= num_columns; i++)); do
        column_info=$(zenity --forms --width=300 --height=100 \
          --title="Create Table $table_name" \
          --text="Enter information for Column $i:" \
          --add-entry="Column Name" \
          --add-entry="Nullable (y/n)" \
          --add-entry="Unique (y/n)")

        if [ $? -eq 1 ]; then
         zenity --error --width=400 --height=100 --text="Table $table_name creation failed."
         rm -r "$table_name"
         Create_Table
        fi

        column_name=$(echo "$column_info" | cut -d "|" -f 1)
        is_nullable=$(echo "$column_info" | cut -d "|" -f 2)
        is_unique=$(echo "$column_info" | cut -d "|" -f 3)

        rtrn=$(Tb_txf "$column_name")
        if [ "$rtrn" != true ]; then
          rm -r "$table_name"
          Create_Table
        else
          if [[ "$is_nullable" != "y" && "$is_nullable" != "n" ]]; then
            zenity --error --width=400 --height=100 --text="Invalid value for Nullable in Column $i. Please enter 'y' or 'n'. Table $table_name creation failed."
            rm -r "$table_name"
            Create_Table
          fi

          if [[ "$is_unique" != "y" && "$is_unique" != "n" ]]; then
            zenity --error --width=400 --height=100 --text="Invalid value for Unique in Column $i. Please enter 'y' or 'n'. Table $table_name creation failed."
            rm -r "$table_name"
            Create_Table
          fi

          data_type_options=("ID--Int--Auto--Inc." "INT" "Double" "Varchar" "Enum" "Phone" "Email" "Password" "Date" "Current--Date--Time")
          data_type=$(zenity --list --width=300 --height=350 \
            --title="Create Table $table_name" \
            --text="Select data type for Column $i:" \
            --column="Data Type" "${data_type_options[@]}")

          if [ $? -eq 1 ]; then
            zenity --error --text="Table $table_name creation failed."
            rm -r "$table_name"
            Create_Table
          fi
          
          if [[ "$data_type" == "Enum" ]]; then
            num_enum_values=$(zenity --entry --title="Enum Values" --text="Enter the number of ENUM values for $column_name:")
            rtrn=$(isNumber "$num_enum_values")
            if [ "$rtrn" == "false" ]; then
              zenity --error --width=400 --height=100  --text="Must Enter A Valid Number."
            else
              enum_values=()
              for ((j = 1; j <= num_enum_values; j++)); do
                enum_value=$(zenity --entry --title="Enter ENUM Value" --text="Enter ENUM value $j for $column_name:")
                enum_values+=("$enum_value")
              done
              formatted_enum="{${enum_values[*]}}"
            fi
          fi

          columns+=("$column_name")
          data_types+=("$data_type")
          nullable+=("$is_nullable")
          unique+=("$is_unique")
        fi
      done

      selected_pk_column=$(zenity --list --width=300 --height=250 \
        --title="Create Table $table_name" \
        --text="Select the Primary Key column:" \
        --column="Column" "${columns[@]}")

      if [ $? -eq 1 ]; then
        zenity --error --width=400 --height=100 --text="Table $table_name creation failed."
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
        zenity --error --width=400 --height=100 --text="No Primary Key column selected. You must select at least one Primary Key. Table creation failed."
        rm -r "$table_name"
        Create_Table
      fi

      check_repeated_columns "${columns[@]}"
      if [ $? -eq 0 ]; then
        for ((i = 0; i < ${#columns[@]}; i++)); do
          echo -e "${columns[i]}:${data_types[i]}:${primary_keys[i]}:${unique[i]}:${nullable[i]}" >> "$table_name/$table_name.md" $([[ "${data_types[i]}" == "Enum" ]] && echo ":${formatted_enum}")
        done
        zenity --info --width=400 --height=100 --text="Table '$table_name' created successfully!"
      else
        rm -r "$table_name"
        Create_Table
      fi
    fi
  fi
}

Create_Table
