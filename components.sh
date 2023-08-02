#!/bin/bash

function chckNameRegex() {
  local name=$1

  if [[ ! $name =~ ^[[:alpha:]][[:alnum:]]*$ ]]; then
    zenity --error --text="Invalid name! It should not start with a number or have special characters."
    return 1
  else
    name=$(echo "$name" | awk '{print tolower($0)}')
    return 0
  fi
}

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
	if [[ -d $1 ]]
	then
		echo true
	else
		echo false
	fi
}


