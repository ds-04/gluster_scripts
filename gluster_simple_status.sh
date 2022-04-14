#!/bin/bash

echo ""
echo -e '\x1b[7m'
echo $HOSTNAME
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt"
echo -e '\x1b[0m'
echo
gluster volume status all | sed -e 's/\sY\s/\x1b[0;32m&\x1b[0m/' -e 's/\sN\s/\x1b[0;33m&\x1b[0m/'
gluster peer status | sed -e 's/Connected/\x1b[0;32m&\x1b[0m/'
