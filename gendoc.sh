#!/usr/bin/env bash
rm -rf doc
ldoc --style "$(pwd)" --project MDK --not_luadoc src/resources
