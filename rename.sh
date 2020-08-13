#!/bin/bash

# stupid simple script that renames all images in the current directory to
# be sequential numbers

a=1
for i in *.jpg; do
  new=$(printf "%04d.jpg" "$a") #04 pad to length of 4
  mv -i -- "$i" "$new"
  let a=a+1
done

