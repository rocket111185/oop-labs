#!/bin/bash

folder="lab$1"

if ! [ -d $folder ]; then
  printf "This lab doesn't exist!\n";
  exit 1;
fi

cd $folder;
if [[ $2 == "r" ]]; then
  RELEASE="-d:release --app:gui";
fi

nim c --os:windows --cpu:i386 --verbosity:0\
  $RELEASE\
  --gcc.exe:i686-w64-mingw32-gcc\
  --gcc.linkerexe:i686-w64-mingw32-gcc\
  MyProg.nim;

wine MyProg.exe;

if ! [[ $3 == "c" ]]; then
  rm MyProg.exe
fi