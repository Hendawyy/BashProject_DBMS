#!/bin/bash
source components.sh

function update {
    keyword1=$(echo "$1" | awk '{print tolower($0)}') #update 
    keyword2=$(echo "$3" | awk '{print tolower($0)}') # set
    keyword3=$(echo "$5" | awk '{print $0}') # = operand
    if [ $keyword1 != "update" -o $keyword2 != "set" -o $keyword3 != "=" ]
    then
        echo "invalid syntax"
    else
    table_name=$2
    table_path=./Databases/seif/$table_name
    rtrn=$(check_if_dir_exists $table_path) #database name then the table
    if [ $rtrn == false ]
    then
        echo "invalid table name"
    else
    column_name=$4
    rtrn=$(check_if_col_exists $table_path/$table_name.md $column_name) #must make this dynamic
    if [ $rtrn == false ]
    then
        echo "column $column_name doesn't exist"
    else
    expected_data_type=`cat $table_path/$table_name.md|awk -F : -v col=$(($rtrn+3)) '{if(NR==col) print $2}'`
    new_data=$6
    rtrn2=$(data_type_match $expected_data_type $new_data)
    if [ $rtrn2 == false ]
    then
        echo "Invalid data type ----- expected data type is $expected_data_type"
    else
    if [ $# -eq 6 ]
    then 
        cat $table_path/$table_name > ./update.tmp
    else
    shift 7
    col_name=$1
    col_num=`check_if_col_exists $table_path/$table_name.md $col_name`
    if [ $col_num == false ]
    then
        echo "column $col_name doesn't exist"
    else
    operator="$2"
    cond_value=$3
    where $table_path/$table_name $col_num "$operator" $cond_value > ./update.tmp
    number_of_affected_line=`cat ./update.tmp|wc -l`
    uniqueness_check=`cat $table_path/$table_name.md|awk -F ":" -v col=$(($rtrn+3)) '{if(NR==col && ($3=="y"||$5=="y")) print "unique"}'`
    if [ "$uniqueness_check" == "unique" ] && [ $number_of_affected_line -gt 1 ]
    then
        echo "invalid update, Unique constraint is applied on the $col_name column, try updating one value at a time"
    else
        cat ./update.tmp |awk -F ";" -v new_data="$new_data" -v col=$rtrn 'BEGIN { OFS = ";"; ORS = "\n" }{
            $col=new_data
            print $0
        }' > ./awk.tmp
    readarray -t where_Arr < ./update.tmp
    readarray -t modified_Arr < ./awk.tmp
    readarray -t old_data_Arr < $table_path/$table_name
    j=0
    for((i=0;i<${#old_data_Arr[@]};i++))
    do
    data1=${old_data_Arr[i]} 
    data2=${where_Arr[j]}
    data3=${modified_Arr[j]}
    if [ "$data1" == "$data2" ]
    then
        echo $data3 >> tmp.txt
        j+=1
    else
        echo $data1 >> tmp.txt
    fi 
    done
    cat tmp.txt > $table_path/$table_name
    echo "UPDATED"
    fi
    fi
    fi
    fi
    fi
    fi
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
update update Employee set email = JR_seif_hendawy@gmail.com where id "=" 7