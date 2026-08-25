#!/bin/bash
set -x

MD=$1
fbname=$(basename "$1" .md)
echo $fbname
# Canonical URL for this page; without it Google reports
# "User-declared canonical: None" and picks its own.
pandoc --standalone --template template.html \
       -V canonical="https://wmealing.bluegum.systems/$fbname.html" \
       "$MD" -o "$fbname.html"
