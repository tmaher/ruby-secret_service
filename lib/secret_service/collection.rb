class SecretService
class Collection
  attr_accessor :service, :name
  
  def initialize(service, name = DEFAULT_COLLECTION)
    @service = service
    @name = name
    @proxy = @service.get_proxy("#{COLLECTION_PREFIX}#{name}",
                                IFACE[:collection])
  end

  def session
    @service.session
  end

  def unlocked_items(search_pred = {})
    @proxy.SearchItems(search_pred)[0].map {|path| Item.new self, path }
  end

  def locked_items(search_pref = {})
    @proxy.SearchItems(search_pred)[1].map {|path| Item.new self, path }
  end

  def create_item properties, secret, replace=true
    puts "about to try CreateItem with #{properties}"
    result = @proxy.CreateItem(properties, secret_encode(secret), replace)
    new_item_path = result[0]
    puts "path: #{new_item_path}"
    Item.new(self, new_item_path)
  end

  def secret_encode secret_string
    mime_type = "application/octet-stream"

    if(secret_string.respond_to? "encoding" and
       secret_string.encoding.to_s != "ASCII-8BIT")
      secret_string.encode! "UTF-8"
      #mime_type = "text/plain; charset=utf8"
    end

    [session[1], [], secret_string.bytes.to_a, mime_type]
  end
  
end
end
