#!/bin/bash

function Menu_Table() {
    while
        selected_table=$(zenity  --list --width=300 --height=300 \
            --title="Table Menu" \
            --text="Choose an operation for the Database '$1':" \
            --column="Options" \
            "Create Table" \
            "List Tables" \
            "Drop Table" \
            "Insert Into Table" \
            "Select From Table" \
            "Delete From Table" \
            "Update Table" \
            "Disconnect From Database")
        if [ $? -eq 1 ]; then
            cd ../..
            echo "Current directory: $(pwd)"
            DBmenu
        else
            case "$selected_table" in
                "Create Table" )
                    source ../../Create_Table.sh $1;;
                "List Tables" )
                    source ../../List_Tables.sh;;
                "Drop Table" )
                    source ../../Drop_Table.sh;;
                "Insert Into Table" )
                    source ../../Insert_Table.sh;;
                "Select From Table" )
                    source ../../Select_Table.sh;;
                "Delete From Table" )
                    source ../../Delete_Data.sh;;
                "Update Table" )
                    source ../../Update_Table.sh;;
                "Disconnect From Database" )
                    cd ../..
                    echo "Current directory: $(pwd)"
                    DBmenu
                    ;;
                *)
                if [ $? -eq 1 ]; then
                    cd ../..
                    echo "Current directory: $(pwd)"
                    DBmenu
                else
                    zenity --error --width=400 --height=100 --text="Invalid choice. Please try again."
                fi
                ;;
            esac
        fi
    do :; done
}

Menu_Table $1
