#!/bin/sh
bundle exec ruby -Ilib dispatcher.rb &
bundle exec rackup config.ru -p $1
