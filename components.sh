#!/bin/bash



function check_special_char {
  x=$1
  if [[ $x =~ [\!\'\"\^\\[\#\`\~\$\%\=\+\<\>\|\:\ \(\)\@\;\?\&\*\\\/]+ ]]
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
	if [[ -d "$1" ]]
	then
		echo true
	else
		echo false
	fi
}



function list_databases() {
  local database_list=$(ls  Databases/ | awk '{print $0 ".db"}')

  selected_db=$(zenity --list --width=300 --height=250 \
    --title="List of Databases" \
    --text="Choose a DB to connect to:" \
    --column="Databases" $database_list)

  if [ $? -eq 1 ]; then
    DBmenu
  fi

  zenity --question --width=400 --height=100  --text="Do you want to connect to '$selected_db'?" 
  response=$?
  if [ $response -eq 0 ]; then
    connect_to_database "$selected_db"
  else
    zenity --info --width=400 --height=100 \
  --text="You chose not to connect to any database."
    DBmenu
  fi
}

function connect_to_database() {
  local db_name=$(echo "$1" | sed 's/\.db$//')

  cd "Databases/$db_name"
  zenity --info --width=400 --height=100 \
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
  table_name=$2 
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


function Tb_txf {

  arg_name=$(echo $* | awk '{print tolower($0)}')

  # Check for naming constraints
  rtrn=$(check_special_char $arg_name)
  if [ "$rtrn" == true ]; then
     zenity --error --width=400 --height=100  --text="Name can't contain special characters"
    return 1
  else
    rtrn=$(check_if_name_starts_with_number $arg_name)
    if [ "$rtrn" == true ]; then
       zenity --error --width=400 --height=100  --text="Name can't start with numbers"
      return 1
    else
      rtrn=$(check_for_empty_string $arg_name)
      if [ "$rtrn" == true ]; then
         zenity --error --width=400 --height=100  --text="Column name must be provided"
        return 1
      else
        rtrn=$(check_if_dir_exists $arg_name)
        if [ "$rtrn" == true ]; then
          echo  zenity --error --width=400 --height=100  --text="Table name already exists in your DB"
          return 1
        else
          echo true  # All checks passed successfully
        fi
      fi
    fi
  fi
}


function append_attribute {
  filtered_line=`echo $* | cut -d \( -f 2 |cut -d \) -f 1`
  echo $filtered_line | sed 's/,/\n/g' > temp.md
  table_name=`echo $* | cut -d " " -f 3`
  rm $table_name.md
  while read line; do arguments_checker $line >> $table_name.md; done < temp.md
  rm temp.md
}


function validate_password_strength {
    password=$1

    if [[ ${#password} -ge 8 && "$password" == *[A-Z]* && "$password" == *[a-z]* && "$password" == *[0-9]* ]]; then
        echo true
    else
        echo false
    fi
}

function data_type {

  shopt -s extglob

  input=$*
  str="^[a-zA-Z0-9 ]{0,255}$"
  date_pattern="^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$"
  date_time_pattern="^[0-9]{4}-((0[1-9])|(1[0-2]))-((0[1-9])|([1-2][0-9])|(3[0-1]))---((2[0-3])|([0-1][0-9])):[0-5][0-9]:[0-5][0-9]$"
  email_pattern="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$"
  enum_pattern="^(([0-9]+)|([a-zA-Z0-9 ]+))(,(([0-9]+)|([a-zA-Z0-9 ]+)))*$"
  phone_pattern="^01[0-9]{9}$"
 
  if  [[ $input =~ ^[1-9][0-9]*$ ]]
  then
    echo "int"
  elif [[ $input =~ $phone_pattern ]]
  then
    echo "phone"
  elif [[ $input =~ ^[-+]?[0-9]+\.?[0-9]*$ ]]
  then
    echo "double"
  elif [[ $input =~ $str ]]
  then
    echo "varchar"
  elif [[ $input =~ $date_pattern ]]
  then
    echo "date"
  elif [[ $input =~ $date_time_pattern ]]
  then
    echo "current--date--time"
  elif [[ $input =~ $email_pattern ]]
  then
    echo "email"
  elif [[ $input =~ $enum_pattern ]]
  then
    echo "enum"
  else
    echo "text"
  fi
}

function isNumber {
  if [[ $* =~ ^[1-9][0-9]*$ ]]; then
    echo "true"
  else
    echo "false"
  fi
}

function check_repeated_columns {
  local columns=("$@")

  declare -A column_counts

  for column in "${columns[@]}"; do
    ((column_counts["$column"]++))
  done

  for column in "${!column_counts[@]}"; do
    if [ "${column_counts[$column]}" -gt 1 ]; then
      zenity --error --width=400 --height=100  --text="You Can't Have 2 Columns with the Same Name"
      return 1
    fi
  done

  return 0
}





function data_type_match {
        #should path to it the expected data type
        #then the input
  expected_data_type=$1
  if [ "$expected_data_type" == "ID--Int--Auto--Inc." ]; 
  then
  expected_data_type="INT"
  fi
  lower_expected=`echo $expected_data_type | awk '{print tolower($0)}'`
  shift
  if [ "$lower_expected" == "password" ]; then
    vp=$(validate_password_strength "$1")
    if [ "$vp" == true ]; then
        echo true
    else
        echo false
    fi
  else
    data_type=$(data_type "$*")
    # echo $data_type
    if [ "$lower_expected" == "$data_type" ]; then
        echo true
    else
        echo false
    fi
  fi

}

# data_type_match "Phone" "01011339798"



function list_tables() {
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

}


function check_for_unique {
   
    col=$1
    file=$2
    shift 2
    data=$*
    count=$(cat $file | cut -d ';' -f $col | grep -i ^"$data"$ | wc -l)
    if [ $count -eq 0 ]
    then
        echo true
    else
        echo false
    fi
}

#check_for_unique 1 ./Databases/seif/Employee/Employee 5

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
        if [ "$rtrn" == true ]
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


function Select_All() {
  selected_tb=$(zenity --list --width=300 --height=250  \
    --title="List of Tables in $DB_name.db" \
    --text="Choose a Table:" \
    --column="Tables" $Tables_list)

  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  fi

  table_name="$selected_tb"
  data_file="../$DB_name/$table_name/$table_name"

  headers=$(awk -F: 'NR>3 {print $1}' "$data_file.md")
  num_fields=$(awk -F: 'NR>3 {print NR-3}' "$data_file.md" | wc -l)
  pk=$(awk -F':' '$3 == "y" { print $1 }' "$data_file.md")

  formatted_data="<html>
    <head>
      <style>
        body {
          font-family: Arial, sans-serif;
        }
        table {
          border-collapse: collapse;
          width: 100%;
        }
        th, td {
          border: 1px solid #dddddd;
          text-align: left;
          padding: 8px;
        }
        th {
          background-color: #f2f2f2;
        }
        .icons {
          font-size: 20px;
          cursor: pointer;
        }
      </style>
    </head>
    <center>
    <body>
    <center>
      <h2>$table_name Table</h2>
      <h5 style='color:crimson'><b>$pk</b> is the <b>PK</b> for this Table</h5>
    </center>
      <table>
        <tr>"

  for header in $headers; do
    formatted_data+="<th>$header</th>"
  done

  formatted_data+="<th>Actions</th>"
  formatted_data+="</tr>"

  while IFS= read -r line; do
    IFS=";" read -ra fields <<< "$line"
    formatted_data+="<tr>"

    for ((i = 0; i < num_fields; i++)); do
      formatted_data+="<td>${fields[i]}</td>"
    done

    formatted_data+="<td>&#9997; &#128465;</td>"
    formatted_data+="</tr>"
  done < "$data_file"

  formatted_data+="</table>
  </body>
  </center>
 </html>"

  zenity --text-info --title="$table_name Table" --width=1080 --height=950 \
    --html --filename=<(echo "$formatted_data") 2>>/dev/null


  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  fi
}


function Select_Columns() {
  selected_tb=$(zenity --list --width=300 --height=250  \
      --title="List of Tables in $DB_name.db" \
      --text="Choose a Table:" \
      --column="Tables" $Tables_list)

  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  fi

  local table_name="$selected_tb"
  local data_file="../$DB_name/$table_name/$table_name"

  headers=$(awk -F: 'NR>3 {print $1}' "$data_file.md")
  nf=$(awk -F: 'NR>3 {print NR-3":"$1}' "$data_file.md")
  wcl=$(awk ' END {print NR}' "$data_file")

  for header in $headers; do
    checklist_options+=(FALSE "$header")
  done

  selected_headers=$(zenity --list --width=300 --height=250  \
    --title="Columns" \
    --text="Choose the Columns you want to select :" \
    --checklist \
    --column="Check" \
    --column="Column" \
    "${checklist_options[@]}")
  checklist_options=()

  if [ $? -eq 0 ]; then
    IFS='|' read -ra selected_headers_array <<< "$selected_headers"
    selected_headers_table="<html>
    <head>
    <style>
      body {
        font-family: Arial, sans-serif;
      }
      table {
        border-collapse: collapse;
        width: 100%;
      }
      th, td {
        border: 1px solid #dddddd;
        text-align: left;
        padding: 8px;
      }
      th {
        background-color: #f2f2f2;
      }
    </style>
    </head>
    <center>
    <body>
    <center>
      <h2>$table_name Table</h2>
    </center>
    <table>
      <tr>"

    field_indices=()
    for selected_header in "${selected_headers_array[@]}"; do
      selected_headers_table+="<th>$selected_header</th>"
      field_index=$(echo "$nf" | grep -n "$selected_header" | cut -d ":" -f 1)
      field_indices+=("$field_index")
    done

    selected_headers_table+="<th>Actions</th>"
    selected_headers_table+="</tr>"

    while IFS= read -r line; do
      IFS=";" read -ra fields <<< "$line"
      selected_headers_table+="<tr>"

      for field_index in "${field_indices[@]}"; do
        field_data=${fields[field_index-1]}
        selected_headers_table+="<td>$field_data</td>"
      done

      selected_headers_table+="<td>&#9997; &#128465;</td>"
      selected_headers_table+="</tr>"
    done < "$data_file"

    selected_headers_table+="</table>
    </body>
    </center>
    </html>"

    zenity --text-info --title="$table_name Table" --width=1080 --height=950 \
      --html --filename=<(echo "$selected_headers_table") 2>>/dev/null


    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi
  fi
  
  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  fi
}


function Select_With_Condition() {
  local type=$1

  if [ "$type" == "All(*)" ]; then
    selected_tb=$(zenity --list --width=300 --height=250  \
        --title="List of Tables in $DB_name.db" \
        --text="Choose a Table:" \
        --column="Tables" $Tables_list)

    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi

    local table_name="$selected_tb"
    local data_file="../$DB_name/$table_name/$table_name"

    pk=$(awk -F':' '$3 == "y" { print $1 }' "$data_file.md")
    colsz=$(awk -F: 'NR>3 {print $1}' "$data_file.md")

    selected_col=$(zenity --list --width=300 --height=250  \
      --title="List of Columns" \
      --text="Choose a Column You want to condition:" \
      --column="Columns" $colsz)

    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi

    DT=$(awk -F: -v selected_col="$selected_col" '$1==selected_col {print $2}' "$data_file.md")
    operatots=("==" "!=" ">" "<" ">=" "<=")
    if [ "$DT" == "ID--Int--Auto--Inc." ] || [ "$DT" == "INT" ] || [ "$DT" == "Double" ]; then
      operatots=("==" "!=" ">" "<" ">=" "<=")
    else
      operatots=("==" "!=" ">" "<")
    fi


    selected_op=$(zenity --list --width=300 --height=250  \
      --title="List of Operators" \
      --text="Choose The Operator You Want To Use In The Condition:" \
      --column="Operators" "${operatots[@]}")

    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi

    arg=$(awk -F: -v selected_col="$selected_col" '$1==selected_col {print NR-3}' "$data_file.md")


    value=$(zenity --entry --width=400 --height=100  --title="Enter Value" \
      --text="Enter value for $selected_col ($DT):")

    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi

    rtrn=$(data_type_match "$DT" "$value")
    if [ "$rtrn" == true ]; then
      formatted_data="<html>
      <head>
      <style>
        body {
          font-family: Arial, sans-serif;
        }
        table {
          border-collapse: collapse;
          width: 100%;
        }
        th, td {
          border: 1px solid #dddddd;
          text-align: left;
          padding: 8px;
        }
        th {
          background-color: #f2f2f2;
        }
        .icons {
          font-size: 20px;
          cursor: pointer;
        }
      </style>
      </head>
      <center>
      <body>
      <center>
        <h2>$table_name Table</h2>
        <h5 style='color:crimson'><b>$pk</b> is the <b>PK</b> for this Table</h5>
      </center>
      <table>
        <tr>"

      headers=$(awk -F: 'NR>3 {print $1}' "$data_file.md")
      num_fields=$(awk -F: 'NR>3 {print NR-3}' "$data_file.md" | wc -l)

      for header in $headers; do
        formatted_data+="<th>$header</th>"
      done

      formatted_data+="<th>Actions</th>"
      formatted_data+="</tr>"

      if [ "$DT" == "ID--Int--Auto--Inc." ] || [ "$DT" == "INT" ] || [ "$DT" == "Double" ]; then
        if [ "$selected_op" == "==" ]; then
          operator="-eq"
        elif [ "$selected_op" == "!=" ]; then
          operator="-ne"
        elif [ "$selected_op" == ">" ]; then
          operator="-gt"
        elif [ "$selected_op" == "<" ]; then
          operator="-lt"
        elif [ "$selected_op" == ">=" ]; then
          operator="-ge"
        elif [ "$selected_op" == "<=" ]; then
          operator="-le"
        fi
        while IFS= read -r line; do
          IFS=";" read -ra fields <<< "$line"
          if [ "$DT" == "Double" ]; then
            ASDasd=$(echo "${fields[$arg-1]} $selected_op $value" | bc)
          else
             ASDasd=$(echo "${fields[$arg-1]} $operator $value")
          fi
          echo $ASDasd
          if [ $ASDasd ]; then
            formatted_data+="<tr>"
            for ((i = 0; i < num_fields; i++)); do
              formatted_data+="<td>${fields[i]}</td>"
            done
            formatted_data+="<td>&#9997; &#128465;</td>"
            formatted_data+="</tr>"
          fi
        done < "$data_file"
      else
        while IFS= read -r line; do
          IFS=";" read -ra fields <<< "$line"
          if [ "${fields[$arg-1]}" $selected_op "$value" ]; then
            formatted_data+="<tr>"
            for ((i = 0; i < num_fields; i++)); do
              formatted_data+="<td>${fields[i]}</td>"
            done
            formatted_data+="<td>&#9997; &#128465;</td>"
            formatted_data+="</tr>"
          fi
        done < "$data_file"
      fi



      formatted_data+="</table>
      </body>
      </center>
      </html>"

      zenity --text-info --title="$table_name Table" --width=1080 --height=950 \
        --html --filename=<(echo "$formatted_data") 2>>/dev/null

      if [ $? -eq 1 ]; then
        Menu_Table "$DB_name"
      fi
    else
        zenity --error --width=400 --height=100  --text="Data Type Mismatch The Expected Value Must Be : $DT"
        Select_Tb
    fi
    
    

  elif [ "$type" == "Columns" ]; then
   selected_tb=$(zenity --list --width=300 --height=250  \
    --title="List of Tables in $DB_name.db" \
    --text="Choose a Table:" \
    --column="Tables" $Tables_list)

    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi

    local table_name="$selected_tb"
    local data_file="../$DB_name/$table_name/$table_name"

    headers=$(awk -F: 'NR>3 {print $1}' "$data_file.md")
    nf=$(awk -F: 'NR>3 {print NR-3":"$1}' "$data_file.md")
    wcl=$(awk ' END {print NR}' "$data_file")

    for header in $headers; do
      checklist_options+=(FALSE "$header")
    done

    selected_headers=$(zenity --list --width=300 --height=250  \
      --title="Columns" \
      --text="Choose the Columns you want to select :" \
      --checklist \
      --column="Check" \
      --column="Column" \
      "${checklist_options[@]}")
      checklist_options=()
      pk=$(awk -F':' '$3 == "y" { print $1 }' "$data_file.md")

      IFS="|" read -ra selected_headers_array <<< "$selected_headers"

      valuess=()
      for colzam in "${selected_headers_array[@]}"; do
          valuess+=("$colzam")
      done

    selected_col=$(zenity --list --width=300 --height=250  \
      --title="List of Columns" \
      --text="Choose a Column You want to condition:" \
      --column="Columns" "${valuess[@]}")

      hds=()

      for xxx in "${valuess[@]}"; do
          index=$(awk -F ':' -v col="$xxx" '($1 == col) { print NR - 3; }' "$data_file.md")
          if [ -n "$index" ]; then
              hds+=("$index")
          fi
      done


    DT=$(awk -F: -v selected_col="$selected_col" '$1==selected_col {print $2}' "$data_file.md")
    if [ "$DT" == "ID--Int--Auto--Inc." ] || [ "$DT" == "INT" ] || [ "$DT" == "Double" ]; then
      operatots=("==" "!=" ">" "<" ">=" "<=")
    else
      operatots=("==" "!=" ">" "<")
    fi
    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi
    

      selected_op=$(zenity --list --width=300 --height=250  \
        --title="List of Operators" \
        --text="Choose The Operator You Want To Use In The Condition:" \
        --column="Operators" "${operatots[@]}")

      if [ $? -eq 1 ]; then
        Menu_Table "$DB_name"
      fi
    
    arg=$(awk -F: -v selected_col="$selected_col" '$1==selected_col {print NR-3}' "$data_file.md")
    value=$(zenity --entry --width=400 --height=100  --title="Enter Value" \
      --text="Enter value for $selected_col ($DT):")

    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi

    rtrn=$(data_type_match "$DT" "$value")
    if [ $? -eq 0 ]; then
      if [ "$rtrn" == true ]; then
        IFS='|' read -ra selected_headers_array <<< "$selected_headers"
        selected_headers_table="<html>
        <head>
        <style>
          body {
            font-family: Arial, sans-serif;
          }
          table {
            border-collapse: collapse;
            width: 100%;
          }
          th, td {
            border: 1px solid #dddddd;
            text-align: left;
            padding: 8px;
          }
          th {
            background-color: #f2f2f2;
          }
        </style>
        </head>
        <center>
        <body>
        <center>
          <h2>$table_name Table</h2>
          <h5 style='color:crimson'><b>$pk</b> is the <b>PK</b> for this Table</h5>
        </center>
        <table>
          <tr>"

        field_indices=()
        for selected_header in "${selected_headers_array[@]}"; do
          selected_headers_table+="<th>$selected_header</th>"
          field_index=$(echo "$nf" | grep -n "$selected_header" | cut -d ":" -f 1)
          field_indices+=("$field_index")
        done

        selected_headers_table+="<th>Actions</th>"
        selected_headers_table+="</tr>"

      if [ "$DT" == "ID--Int--Auto--Inc." ] || [ "$DT" == "INT" ] || [ "$DT" == "Double" ]; then
        if [ "$selected_op" == "==" ]; then
          operator="-eq"
        elif [ "$selected_op" == "!=" ]; then
          operator="-ne"
        elif [ "$selected_op" == ">" ]; then
          operator="-gt"
        elif [ "$selected_op" == "<" ]; then
          operator="-lt"
        elif [ "$selected_op" == ">=" ]; then
          operator="-ge"
        elif [ "$selected_op" == "<=" ]; then
          operator="-le"
        fi
        while IFS= read -r line; do
            IFS=";" read -ra fields_split <<< "$line"
            if [ "$DT" == "Double" ]; then
              ASDasd=$(echo "${fields[$arg-1]} $selected_op $value" | bc)
            else
              ASDasd=$(echo "${fields[$arg-1]} $operator $value")
            fi
            echo $ASDasd
            if [ $ASDasd ]; then
                selected_headers_table+="<tr>"
                for field_index in "${hds[@]}"; do
                    field_data=${fields_split[field_index-1]}
                    selected_headers_table+="<td>$field_data</td>"
                done
                selected_headers_table+="<td>&#9997; &#128465;</td>"
                selected_headers_table+="</tr>"
            fi
        done < "$data_file"

      else
        while IFS= read -r line; do
            IFS=";" read -ra fields_split <<< "$line"
            if [ "${fields_split[$arg-1]}" "$selected_op" "$value" ]; then
                selected_headers_table+="<tr>"
                for field_index in "${hds[@]}"; do
                    field_data=${fields_split[field_index-1]}  # Fixed index
                    selected_headers_table+="<td>$field_data</td>"
                done
                selected_headers_table+="<td>&#9997; &#128465;</td>"
                selected_headers_table+="</tr>"
            fi
        done < "$data_file"

      fi


        selected_headers_table+="</table>
        </body>
        </center>
        </html>"

      zenity --text-info --title="$table_name Table" --width=1080 --height=950 \
        --html --filename=<(echo "$selected_headers_table") 2>>/dev/null

      if [ $? -eq 1 ]; then
        Menu_Table "$DB_name"
      fi
    

    
    else
    zenity --error --width=400 --height=100  --text="Data Type Mismatch The Expected Value Must Be : $DT"
            Select_Tb
    fi
  else
    Menu_Table "$DB_name"
  fi

fi
}




function Select_Without_Condition() {
  local type=$1

  if [ "$type" == "All(*)" ]; then
    Select_All
  elif [ "$type" == "Columns" ]; then
    Select_Columns

  fi
}

function insert_into {
    table_name=`echo $*|cut -d \( -f 1`
    file_path=./seif/$table_name 
    if [ $(check_if_dir_exists $file_path) == false ]
    then
        echo "table doesn't exist"
        return 1
    fi
    arguments=`echo $*|cut -d \( -f 2| cut -d \) -f 1`
    file_path=./Databases/seif/$table_name 
    data_file=$file_path/$table_name
    meta_data_file=$data_file.md
    echo $arguments |sed 's/,/\n/g' > $file_path/tmp.data
    no_of_arg=`cat $file_path/tmp.data |wc -l`
    no_of_arg_mdfile=`cat $meta_data_file|wc -l`
    no_of_arg_mdfile=$(($no_of_arg_mdfile-3))
    if [ $no_of_arg -gt $no_of_arg_mdfile ]
    then
        echo "too many arguments"
        return 1
    elif [ $no_of_arg -lt $no_of_arg_mdfile ]
    then
        echo "all arguments must be provided"
        return 1
    fi
    flag=0
    for ((i=1; i<=$no_of_arg; i++))
    {
        data=`awk -v line=$i '{if (NR==line) print $0}' $file_path/tmp.data`
        col=$(($i+3))
        prkey=`awk -F ":" -v line=$(($i+3)) '{if(NR==line) print $3}' $meta_data_file`
        unq=`awk -F ":" -v line=$(($i+3)) '{if(NR==line) print $5}' $meta_data_file`
        not_nul=`awk -F ":" -v line=$(($i+3)) '{if(NR==line) print $6}' $meta_data_file`
        data_col=$i
        if [ ! -z "$data" ]
        then
            if [ $(check_for_data_type $col $meta_data_file $data) == false ]
            then
                echo invalid input, $data
                flag=1
            fi
        fi
        if [ $unq == "y" ]
        then
            if [ $(check_for_unique $data_col $data_file $data) == false ]
            then
                echo "Unique values can't be repeated"
                flag=1
            fi
        fi
        if [ $not_nul == "y" ]
        then
            if [ $(check_for_not_null $data) == false ]
            then
                echo "This argument is required and can't be null"
                flag=1
            fi
        fi
        if [ $prkey == "y" ]
        then
            if [ $(check_for_pk $data_col $data_file $data) == false ]
            then
                echo "Value doesn't meet Primary Key constraints"
                flag=1
            fi
        fi
        if [ $auto_inc == "y" ]
        then
            echo "we will add that as soon as we have time"
        fi
    }
    if [[ $flag -eq 0 ]]
    then
    cat $file_path/tmp.data | sed -z 's/\n/;/g;s/;$/\n/' >> $data_file # IMPORTANT!
    fi
}

#insert_into "Employee(5,Ahmed seif,ahmed@gmail.com,2023-12-31)"


function check_if_col_exists {
    meta_data_file=$1
    col_name=$2
    col_num=`cat $meta_data_file|cut -d : -f 1 |grep -n ^$col_name$` #returns number:name
    if [ -z $col_num ]
    then
        echo "false"
    else
    num=`echo $col_num| cut -d : -f 1`
    num=$((num-3))
    echo $num
    fi
}
#check_if_col_exists ./Databases/seif/Employee/Employee.md email

function where {
    # where table_path column == 12345
    data_file_path=$1
    col=$2
    cond=$3
    shift 3
    value=$*
    cat $data_file_path|awk -F ";" -v col=$col -v cond=${cond} -v value="$value" '{
    IGNORECASE=1
    if($col == value && (cond == "==" || cond == "="))
    {print $0;}
    else if($col >= value && cond == ">=")
    {print $0}
    else if($col <= value && cond == "<=")
    {print $0}
    else if($col != value && cond == "!=")
    {print $0}
    else if($col > value && cond == ">")
    {print $0}
    else if($col < value && cond == "<")
    {print $0}
    }' 
}
#where "./Databases/seif/Employee/Employee" 4 "<=" 2022-10-31