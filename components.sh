#!/bin/bash



function check_special_char {
x=$1
if [[ $x =~ [\'\"\^\\[\#\`\~\$\%\=\+\<\>\|\:\ \(\)\@\;\?\&\*\\\/]+ ]]
then
	echo true
else
	echo false
fi
}



function check_if_name_starts_with_number {
if [[ $1 =~ ^[0-9] ]]
then
	echo true
else
	echo false
fi
}


function check_if_dir_exists {
	if [[ -d "Databases/$1" ]]
	then
		echo true
	else
		echo false
	fi
}



function list_databases() {
  local database_list=$(ls  Databases/ | awk '{print $0 ".db"}')

  selected_db=$(zenity --list \
    --title="List of Databases" \
    --text="Choose a DB to connect to:" \
    --column="Databases" $database_list)

  if [ $? -eq 1 ]; then
    DBmenu
  fi

  zenity --question --text="Do you want to connect to '$selected_db'?"
  response=$?
  if [ $response -eq 0 ]; then
    connect_to_database "$selected_db"
  else
    zenity --info \
  --text="You chose not to connect to any database."
    DBmenu
  fi
}

function connect_to_database() {
  local db_name=$(echo "$1" | sed 's/\.db$//')

  cd "Databases/$db_name"
  zenity --info \
  --text="Connected to the database: $db_name"
  echo "Current directory: $(pwd)"
  source ../../Table_menu.sh
}

function check_for_empty_string {
  if [ -z $1 ]
  then
    echo true
  else
    echo false
  fi
}

function check_for_repeated_col_name {
  col_name=$1
  table_name=$2 #file name
  count=`cut -d : -f 1 $table_name| grep -i ^$col_name$ | wc -l`
  echo $count  
}


function check_data_type_entry {
    dt_lower=$(echo "$1" | awk '{print tolower($0)}')
    case $dt_lower in
    number)
    ;;
    float)
    ;;
    string)
    ;;
    auto_increment)
    ;;
    "date")
    ;;
    date_time)
    ;;
    email)
    ;;
    text)
    ;;
    *)
    echo "invalid data type"
    ;;
    esac
}


function arguments_checker {
arguments=`echo $* | cut -d ' ' -f 3-`
arg_name=$1
#check for naming constraints
rtrn=$(check_special_char $1)
if [ $rtrn == true ]
then
    echo "name can't contain a special characters"
    return 1
else
    rtrn=$(check_if_name_starts_with_number $1)
    if [ $rtrn == true ]
    then
        echo "name can't start with numbers"
        return 1
    else
        rtrn=$(check_for_empty_string $1)
        if [ $rtrn == true ]
        then
            echo "column name must be provided"
            return 1
        fi
    fi
fi
dt=$2
# check if data type is valid using case state
rtrn=$(check_data_type_entry $dt)
if [ rtrn == "invalid data type" ]
then
    echo "invalid data type"
    return 1
fi
pk=`echo $arguments | grep -i primary_key| wc -l`
nn=`echo $arguments | grep -i not_null| wc -l`
uq=`echo $arguments | grep -i unique | wc -l`
inc=`echo $arguments | grep -i auto_increment |wc -l`
line_to_be_added="$1:$2"
for constraint in $pk $inc $uq $nn
do
        if [ $constraint -eq 1 ]
        then
                line_to_be_added="$line_to_be_added:y"
        elif [ $constraint -eq 0 ]
        then
                line_to_be_added="$line_to_be_added:n"
        else
                echo "too many arguments after $1"
        fi
done
echo $line_to_be_added
}


function append_attribute {
filtered_line=`echo $* | cut -d \( -f 2 |cut -d \) -f 1`
echo $filtered_line | sed 's/,/\n/g' > temp.md
table_name=`echo $* | cut -d " " -f 3`
rm $table_name.md
while read line; do arguments_checker $line >> $table_name.md; done < temp.md
rm temp.md
}


function data_type {

shopt -s extglob

input=$*

date_time="^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]) (2[0-3]|[0-1][0-9]):[0-5][0-9]:[0-5][0-9]$"

if  [[ $input =~ ^[1-9][0-9]*$ ]]
then
        echo "number" 
elif [[ $input =~ ^[-+]?[0-9]+\.?[0-9]*$ ]]
then
        echo "float"
elif [[ $input =~ ^[a-zA-Z]{0,255}$ ]]
then
        echo "string"
elif [[ $input =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$ ]]
then
        echo "date"
elif [[ $input =~ $date_time ]]
then
        echo "date_time"

elif [[ $input =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]
then
        echo "email"
else
        echo "text"
fi
}


function data_type_match {
        #should path to it the expected data type
        #then the input
expected_data_type=$1
shift
data_type=$(data_type $*)
if [ $expected_data_type == $data_type ]
then
        echo true
else
        echo false
fi
}

#data_type_match "date" "2023-13-15"



function list_tables() {
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

}


function check_for_unique {
    col=$1
    file=$2
    shift 2
    data=$*
    count=`cat $file |cut -d : -f $col| grep -i ^"$data"$ | wc -l`
    if [ $count -eq 0 ]
    then
        echo true
    else
        echo false
    fi
}

function check_for_not_null {
    input=$*
    if [ -z "$input" ]
    then
        echo false    #empty string = null
    else
        echo true
    fi
}

function check_for_pk {
    col=$1
    file=$2
    shift 2
    data=$*
    rtrn=$(check_for_not_null $data)
    if [ $rtrn == true ]
    then
        rtrn=$(check_for_unique "$col" "$file" "$data")
        if [ $rtrn == true ]
        then
            	echo true
	else
		echo false
        fi
    else
        echo false
    fi
}

function check_for_data_type {
    col=$1
    file=$2
    shift 2
    data=$*
    expected_data_type=`awk -v mycol=$col -F ":" '{ if (NR==mycol)
    {print $2}
}
    ' $file`
    rtrn=$(data_type_match $expected_data_type $data)
    echo $rtrn
}
#check_for_data_type 8 ./Student/Student.md "2023-12-32 23:59:59"
#check_for_not_null                 
#check_for_unique 1 /etc/passwd Caster
#check_for_pk 1 /etc/passwd asdasq asfsaga asd
