#!/bin/bash

source ../../components.sh

function UpdateTb {
    current_dir=$(pwd)
    DB_name=$(basename "$current_dir")

    Tables_list=$(ls "$current_dir/")

    selected_tb=$(zenity --list  --width=300 --height=250 \
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
    selected_col=$(zenity --list  --width=300 --height=250 \
        --title="List of Columns in $table_name.tb" \
        --text="Choose a Column:" \
        --column="Column" $column_names)
    
    if [ $? -eq 1 ]; then
         Menu_Table "$DB_name"
    fi
    
    column_name=$selected_col

    DT=$(awk -F: 'NR>3 && $1 == selected_col {print $2}' selected_col="$selected_col" "$table_path/$table_name.md")

    if [[ "$DT" == "ID--Int--Auto--Inc." ]]; then
        New_val=$(zenity --entry --width=400 --height=100 --title="Enter New Value" --text="Enter New Value for $column_name ($DT):")
        rtrn=$(data_type_match $DT $New_val)
        if [ $rtrn == true ]; then
            new_data=$New_val
        else
            zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $DT"
            UpdateTb
        fi
    elif [[ "$DT" == "INT" ]]; then
         New_val=$(zenity --entry --width=400 --height=100 --title="Enter New Value" --text="Enter New Value for $column_name ($DT):")
        rtrn=$(data_type_match $DT $New_val)
        if [ $rtrn == true ]; then
            new_data=$New_val
        else
            zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $DT"
            UpdateTb
        fi
    elif [[ "$DT" == "Double" ]]; then
         New_val=$(zenity --entry --width=400 --height=100 --title="Enter New Value" --text="Enter New Value for $column_name ($DT):")
        rtrn=$(data_type_match $DT $New_val)
        if [ $rtrn == true ]; then
            new_data=$New_val
        else
            zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $DT"
            UpdateTb
        fi
    elif [[ "$DT" == "Varchar" ]]; then
         New_val=$(zenity --entry --width=400 --height=100 --title="Enter New Value" --text="Enter New Value for $column_name ($DT):")
        rtrn=$(data_type_match $DT $New_val)
        if [ $rtrn == true ]; then
            new_data=$New_val
        else
            zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $DT"
            UpdateTb
        fi
    elif [[ "$DT" == "Phone" ]]; then
         New_val=$(zenity --entry --width=400 --height=100 --title="Enter New Value" --text="Enter New Value for $column_name ($DT):")
        rtrn=$(data_type_match $DT $New_val)
        if [ $rtrn == true ]; then
            new_data=$New_val
        else
            zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $DT"
            UpdateTb
        fi
    elif [[ "$DT" == "Email" ]]; then
         New_val=$(zenity --entry --width=400 --height=100 --title="Enter New Value" --text="Enter New Value for $column_name ($DT):")
        rtrn=$(data_type_match $DT $New_val)
        if [ $rtrn == true ]; then
            new_data=$New_val
        else
            zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $DT"
            UpdateTb
        fi
    elif [[ "$DT" == "Enum" ]]; then
        enum_values=$(awk -F ':' 'NR > 3 {print $6}' "../$DB_name/$table_name/$table_name.md" | tr '{}' ' ')
        New_val=$(zenity --list  --width=300 --height=250 \
            --title="Select ENUM Value" \
            --text="Select ENUM value for $column_name:" \
            --column="Value" ${enum_values})
            new_data=$New_val
    elif [[ "$DT" == "Password" ]]; then
        New_val=$(zenity --password --width=400 --height=100 --title="Enter New Value" --text="Enter password for $column_name:")
        rtrn=$(data_type_match $DT $New_val)
        if [ $rtrn == true ]; then
            new_data=$New_val
        else
            zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $DT"
            UpdateTb
        fi
    elif [[ "$DT" == "Date" ]]; then
        New_val=$(zenity --calendar --title="Select Date" --text="Select date for $column_name:")
        rtrn=$(data_type_match $DT $New_val)
        if [ $rtrn == true ]; then
            new_data=$New_val
        else
            zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $DT"
            UpdateTb
        fi
    elif [[ "$DT" == "Current--Date--Time" ]]; then
        New_val=$(date +"%Y-%m-%d---%H:%M:%S")
        new_data=$New_val
    fi

    
    selected_colcond=$(zenity --list  --width=300 --height=250 \
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

    selected_op=$(zenity --list  --width=300 --height=250 \
      --title="List of Operators" \
      --text="Choose The Operator You Want To Use In The Condition:" \
      --column="Operators" "${operators[@]}")

    if [ $? -eq 1 ]; then
        Menu_Table "$DB_name"
    fi

    operator="$selected_op"

    value=$(zenity --entry --width=400 --height=100 --title="Enter Condition Value" \
      --text="Enter Condition value for $selected_colcond ($DTcond):")

    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi
    rtrn=$(data_type_match "$DTcond" "$value")
    if [ "$rtrn" == true ]; then
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
                
                # echo "d1:"$data1
                # echo "d2:"$data2
                # echo "d3:"$data3
                # echo "j:"$j
                if [ "$data1" == "$data2" ]; then
                    echo $data3 >> tmp.txt
                    j=$((j + 1))
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
         zenity --info --width=400 --height=100 --text="Table $table_name Updated Succesfully on Col($column_name) New Value($new_data)"
    else
         zenity --error --width=400 --height=100 --text="Data Type Mismatch The Expected Value Must Be : $DTcond"
        UpdateTb
    fi
}
UpdateTb