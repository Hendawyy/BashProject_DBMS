#!/bin/bash

source ../../components.sh

function update {
    current_dir=$(pwd)
    DB_name=$(basename "$current_dir")

    Tables_list=$(ls "$current_dir/")

    selected_tb=$(zenity --list \
        --title="List of Tables in $DB_name.db" \
        --text="Choose a Table:" \
        --column="Tables" $Tables_list)

    table_name="$selected_tb"
    data_file="../../$DB_name/$table_name/$table_name"
    if [ $? -eq 1 ]; then
        Menu_Table "$DB_name"
    fi

    keyword1='update' 
    keyword2='set'
    keyword3='='
    table_name=$selected_tb
    table_path=../$DB_name/$table_name
    
    column_names=$(awk -F: 'NR>3 {print $1}' "$table_path/$table_name.md")
    selected_col=$(zenity --list \
        --title="List of Columns in $table_name.tb" \
        --text="Choose a Column:" \
        --column="Column" $column_names)
    
    if [ $? -eq 1 ]; then
         Menu_Table "$DB_name"
    fi
    
    column_name=$selected_col

    DT=$(awk -F: 'NR>3 && $1 == selected_col {print $2}' selected_col="$selected_col" "$table_path/$table_name.md")

    if [[ "$DT" == "ID--Int--Auto--Inc." ]]; then
        New_val=$(zenity --entry --title="Enter New Value" --text="Enter New Value for $column_name (ID--Int--Auto--Inc.):")
    elif [[ "$DT" == "INT" ]]; then
        New_val=$(zenity --entry --title="Enter New Value" --text="Enter New Value for $column_name (INT):")
    elif [[ "$DT" == "Double" ]]; then
        New_val=$(zenity --entry --title="Enter New Value" --text="Enter New Value for $column_name (Double):")
    elif [[ "$DT" == "Varchar" ]]; then
        New_val=$(zenity --entry --title="Enter New Value" --text="Enter New Value for $column_name (Varchar):")
    elif [[ "$DT" == "Phone" ]]; then
        New_val=$(zenity --entry --title="Enter New Value" --text="Enter New Value for $column_name (Phone):")
    elif [[ "$DT" == "Email" ]]; then
        New_val=$(zenity --entry --title="Enter New Value" --text="Enter New Value for $column_name (Email):")
    elif [[ "$DT" == "Enum" ]]; then
        enum_values=$(awk -F ':' 'NR > 3 {print $6}' "../$DB_name/$table_name/$table_name.md" | tr '{}' ' ')
        New_val=$(zenity --list \
            --title="Select ENUM Value" \
            --text="Select ENUM value for $column_name:" \
            --column="Value" ${enum_values})
    elif [[ "$DT" == "Password" ]]; then
        New_val=$(zenity --password --title="Enter New Value" --text="Enter password for $column_name:")
        validate_password_strength "$New_val"
    elif [[ "$DT" == "Date" ]]; then
        New_val=$(zenity --calendar --title="Select Date" --text="Select date for $column_name:")
    elif [[ "$DT" == "Current--Date--Time" ]]; then
        New_val=$(date +"%Y-%m-%d---%H:%M:%S")
    fi

    new_data=$New_val

    selected_colcond=$(zenity --list \
        --title="List of Columns in $table_name.tb" \
        --text="Choose a Column (Condition):" \
        --column="Column" $column_names)
    
    if [ $? -eq 1 ]; then
        Menu_Table "$DB_name"
    fi
    
    DTcond=$(awk -F: 'NR>3 && $1 == selected_col {print $2}' selected_col="$selected_colcond" "$table_path/$table_name.md")
    
    cat $table_path/$table_name > ./update.tmp
    operators=("==" "!=" ">" "<" ">=" "<=")

    if [ "$DTcond" == "ID--Int--Auto--Inc." ] || [ "$DT" == "INT" ] || [ "$DT" == "Double" ]; then
        operators=("==" "!=" ">" "<" ">=" "<=")
    else
        operators=("==" "!=" ">" "<")
    fi

    selected_op=$(zenity --list \
      --title="List of Operators" \
      --text="Choose The Operator You Want To Use In The Condition:" \
      --column="Operators" "${operators[@]}")

    if [ $? -eq 1 ]; then
        Menu_Table "$DB_name"
    fi

    operator="$selected_op"

    value=$(zenity --entry --title="Enter Condition Value" \
      --text="Enter Condition value for $selected_colcond ($DTcond):")

    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi
    
    col_cond=$(awk -F: 'NR>3 && $1 == selected_col {print NR-3}' selected_col="$selected_colcond" "$table_path/$table_name.md")

    cond_value=$value
    colxn=$(check_if_col_exists $table_path/$table_name.md $column_name) 

    where $table_path/$table_name $col_cond "$operator" $cond_value > ./update.tmp
    number_of_affected_line=$(cat ./update.tmp | wc -l)
    uniqueness_check=$(cat $table_path/$table_name.md | awk -F : -v col=$(($colxn + 3)) '{if(NR==col && ($3=="y"||$5=="y")) print "unique"}')

    if [ "$uniqueness_check" == "unique" ] && [ $number_of_affected_line -gt 1 ]; then
                     echo "Unique constraint is applied on the $col_name column, try updating one value at a time"
    else
        cat ./update.tmp | awk -F ";" -v new_data=$new_data -v col=$colxn 'BEGIN { OFS = ";"; ORS = "\n" }{
            $col=new_data
            print $0
        }' > ./awk.tmp
        readarray -t where_Arr < ./update.tmp
        readarray -t modified_Arr < ./awk.tmp
        readarray -t old_data_Arr < $table_path/$table_name
        j=0

        for((i=0;i<${#old_data_Arr[@]};i++)); do
            data1=${old_data_Arr[i]} 
            data2=${where_Arr[j]}
            data3=${modified_Arr[j]}
            
            if [ "$data1" == "$data2" ]; then
                echo $data3 >> tmp.txt
                j+=1
            else
                echo $data1 >> tmp.txt
            fi
        done
        cat tmp.txt > $table_path/$table_name
    fi

    if [ -f ./update.tmp ]
        then rm ./update.tmp
    fi

    if [ -f ./awk.tmp ]
        then rm ./awk.tmp
    fi
    
    if [ -f ./tmp.txt ]
        then rm ./tmp.txt
    fi
}
update