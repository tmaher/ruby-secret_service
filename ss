#!/usr/bin/env ruby

require 'secret_service'

ss = SecretService.new

puts secret_path = ss.collection.unlocked_items[0]
#item = SecretService::Item.new(ss.bus, secret_path)

#puts item.your_mom

#puts ss.init_session[1]

#item = SecretService::Item.new(session, secret_path)
#
#puts item.item["Modified"].class

