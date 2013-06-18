#!/usr/bin/env ruby

require 'secret_service'

ss = SecretService.new

secret_path = ss.get_collection.get_unlocked_items[0]
item = SecretService::Item.new(ss.bus, secret_path)

#puts item.get_secret

#puts ss.init_session[1]

#item = SecretService::Item.new(session, secret_path)
#
#puts item.item["Modified"].class

