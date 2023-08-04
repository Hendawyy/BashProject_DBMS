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
  local database_list=$(ls -d Databases/* | sed 's|.*/||' | awk '{print $0 ".db"}')

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
    dt_lower=$(echo "$dt" | awk '{print tolower($0)}')
    case $dt_lower in
    varchar)
    ;;
    int)
    ;;
    date)
    ;;
    [[ ^enum(*)$ ]]) # back to this later
    ;;
    auto_increment)
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
dt=$2
# check if data type is valid using case state
rtrn=$(check_data_type_entry $2)
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


