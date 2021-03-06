#!/usr/bin/env ruby

require 'secret_service'
require 'optparse'

options = {}
opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} -s|-g NAME"
  opts.on("-g", "--get NAME",
          "Reads existing secret called NAME, prints secret to stdout") do |key|
    options[:name] = key
    options[:mode] = :get
  end
  opts.on("-s", "--set NAME",
          "Creates new secret called NAME, reads secret from stdin") do |key|
    options[:name] = key
    options[:mode] = :set
  end
end
opts.parse!

ss = SecretService.new

case options[:mode]
when :set
  new_secret = STDIN.read
  typeinfo = nil
  attrs = ["a{ss}", {"name" => options[:name].to_s }]

  properties =
    {"org.freedesktop.Secret.Item.Label" => options[:name],
    "org.freedesktop.Secret.Item.Attributes" => attrs
  }
  item = ss.collection.create_item properties, new_secret
when :get
  item = ss.collection.unlocked_items({"name" => options[:name]})[0]
  puts item.get_secret
else
  puts opts.help
  exit 1
end

exit 0
name = ARGV[0]

item = ss.collection.unlocked_items({"name" => name})[0]
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

