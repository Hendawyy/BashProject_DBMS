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


