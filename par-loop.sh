#!/bin/bash

i=1
tmpfile=".tmp$(date +%s)"
touch $tmpfile

for file in $(find | grep "zip$")
do
  echo "echo now at file $file" >> $tmpfile
done 

parallel -j 10 < $tmpfile

rm $tmpfile
