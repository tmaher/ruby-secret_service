#!/usr/bin/env ruby

require 'secret_storage'

ss = SecretStorage.new

secret_path = ss.get_collection.get_unlocked_items[0]

puts ss.init_session[1]

#item = SecretStorage::Item.new(session, secret_path)
#
#puts item.item["Modified"].class
