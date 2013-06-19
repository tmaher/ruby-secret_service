#!/usr/bin/env ruby

require 'secret_service'

ss = SecretService.new

item = ss.collection.unlocked_items[0]
puts "label: #{item.label}"
puts "last modified #{item.modified}, locked: #{item.locked?}"
puts "attributes: #{item.attributes.to_s}"

# item.attributes = ["name", "test2"]
#  {"magic" => "secret_service.rb", "name" => "test"}
  

#item = SecretService::Item.new(ss.bus, secret_path)

#puts item.your_mom

#puts ss.init_session[1]

#item = SecretService::Item.new(session, secret_path)
#
#puts item.item["Modified"].class

