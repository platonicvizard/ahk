#!/bin/bash

# Basic range in for look

for value in {1..5}
do
	echo $value
done

echo Basic range in for look

# Basic range with steps for loop
for value in {10..0..2}
do
	echo $value
done

echo Basic range with steps for loop
echo $1 :path:
# make a php copy of any html files
for value in $1/*.html
do
	cp $value $1/$( basename -s .html $value ).php
done
echo make a php copy of any html files



echo All done
