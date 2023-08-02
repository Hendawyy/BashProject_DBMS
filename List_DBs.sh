#! /bin/bash

#desc: list all databases in vertical order

ls -d /Databases/ */ --format=single-column | sed 's/\//.db/g'
