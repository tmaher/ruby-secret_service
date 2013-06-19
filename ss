#!/usr/bin/env ruby

require 'secret_service'

ss = SecretService.new

item = ss.collection.unlocked_items[0]
puts "last modified #{item.modified}, locked: #{item.locked?}, label: #{item.label}"



#item = SecretService::Item.new(ss.bus, secret_path)

#puts item.your_mom

#puts ss.init_session[1]

#item = SecretService::Item.new(session, secret_path)
#
#puts item.item["Modified"].class

