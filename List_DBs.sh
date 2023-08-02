#! /bin/bash

ls -d Databases/* | sed 's|.*/||' | awk '{print $0 ".db"}'
