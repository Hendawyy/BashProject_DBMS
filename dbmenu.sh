#!/bin/bash


function DBmenu(){
    while true; do
    choice=$(zenity --list \
    --title="Bashmohandes Mina's DBMS Main Menu" \
    --text="Please Choose An Option:" \
    --column="What Do You Wish To Do" \
    "Create a DB" \
    "List All DataBases" \
    "Connect To A DB" \
    "Drop DB" \
    )
    if [ $? -eq 1 ];then
        echo "Thanks Bashmohandes Mina , Goodbye XD !"
        exit 
    else
        case $choice in
            "Create a DB" )
                source Create_DB.sh;;
            "List All DataBases" )
                source List_DBs.sh;;
            "Connect To A DB" )
                source Connect_DB.sh;;
            "Drop DB" )
                source Drop_DB.sh;;
            *)
                zenity --error --text="Invalid choice. Please try again." ;;
        esac
    fi
    
done
}

DBmenu
