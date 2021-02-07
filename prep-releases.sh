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
# prep the ldoc css file to all sub-projects we are making docs for
cp $basedir/ldoc.css sub-projects/TextGauges/ldoc.css
cp $basedir/ldoc.css sub-projects/fText/ldoc.css
cp $basedir/ldoc.css sub-projects/EMCO/ldoc.css

# prep TextGauges
cp $srcdir/TextGauges.lua sub-projects/TextGauges/src/resources/TextGauges.lua

# prep fText
cp $srcdir/ftext.lua sub-projects/fText/src/resources/ftext.lua
cp $srcdir/textformatter.lua sub-projects/fText/src/resources/textformatter.lua
cp $srcdir/tablemaker.lua sub-projects/fText/src/resources/tablemaker.lua

# prep EMCO
cp $srcdir/EMCO.lua sub-projects/EMCO/src/resources/EMCO.lua
cp $srcdir/demontools.lua sub-projects/EMCO/src/resources/demontools.lua
cp $srcdir/loggingconsole.lua sub-projects/EMCO/src/resources/loggingconsole.lua
