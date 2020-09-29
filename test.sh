#!/bin/bash

folder="lab$1"

read -p "Filename: " -r;

if ! [ -d $folder ]; then
  printf "This lab doesn't exist!\n";
  exit 1;
fi

cd $folder;

if ! [ -f "$REPLY.nim" ]; then
  printf "This file doesn't exist!\n";
  exit 1;
fi

if [[ $2 == "r" ]]; then
  RELEASE="-d:release --app:gui";
fi

nim c --os:windows --cpu:i386 --verbosity:0\
  $RELEASE --threads:on\
  --gcc.exe:i686-w64-mingw32-gcc\
  --gcc.linkerexe:i686-w64-mingw32-gcc\
 $REPLY.nim || exit;

wine $REPLY.exe;

if ! [[ $3 == "c" ]]; then
  rm $REPLY.exe
fi