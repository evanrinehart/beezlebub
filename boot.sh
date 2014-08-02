#!/bin/sh
bundle exec rackup config.ru -p $1 &
ruby dispatcher.rb
