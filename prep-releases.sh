#!/usr/bin/env bash

basedir=`dirname "$0"`
srcdir=$basedir/src/resources
VERSION=$1
releaseFileName="build/demonnic-MDK-$VERSION.zip"
if [ -z $VERSION ]; then
  echo You must provide a version as the first and only argument
  exit 1
fi

echo $VERSION > ./src/resources/mdkversion.txt

muddle
./gendoc.sh
zip -r -j $releaseFileName src/resources/*
zip -u -r $releaseFileName doc
zip -u $releaseFileName README.md
