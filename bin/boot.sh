#!/bin/sh
echo "bootscript"
ruby -Ilib dispatcher.rb &
echo "survived that"
echo "port = $1"
rackup config.ru -p $1
echo "never happens?"
