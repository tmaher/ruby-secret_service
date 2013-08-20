class SecretService
class Collection
  attr_accessor :service, :name, :path
  
  def initialize(service, name = DEFAULT_COLLECTION, path=nil)
    @service = service
    @name = name
    @path = path || "#{COLLECTION_PREFIX}#{name}"
    @proxy = @service.get_proxy(@path, IFACE[:collection])
  end

  def lock!
    locked_objs, prompt_path = @service.proxy.Lock [@path]
    return true if prompt_path == "/" and locked_objs.include?(@path)

    # need to do the prompt dance
    @service.prompt!(prompt_path)
    locked?
  end
  
  def unlock!
    unlocked_objs, prompt_path = @service.proxy.Unlock [@path]
    return true if prompt_path == "/" and unlocked_objs.include?(@path)

    #nuts, stupid prompt
    @service.prompt!(prompt_path)
    ! locked?
  end

  def locked?
    get_property(:locked)
  end

  def set_property name, new_val
    @proxy.Set(IFACE[:item], name.to_s.downcase.capitalize, new_val)
  end

  def get_property name
    @proxy.Get(IFACE[:collection], name.to_s.downcase.capitalize)[0]
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

  def create_item name, secret, properties=nil, replace=true
    if properties.nil? 
      # ruby-dbus's type inference system doesn't handle recursion for
      # vaguely complicated structs, yet the protocol requires
      # explicit type annotation.  Consequently, nontrivial structs
      # require the user to provide their own annotation
      attrs = ["a{ss}", {"name" => name.to_s }]

      properties =
        {"#{SS_PREFIX}Item.Label" => name.to_s,
        "#{SS_PREFIX}Item.Attributes" => attrs
      }
    end
    result = @proxy.CreateItem(properties, secret_encode(secret), replace)
    new_item_path = result[0]
    Item.new(self, new_item_path)
  end

  def get_item name
    (unlocked_items({"name" => name})[0])
  end

  def get_secret name
    get_item(name).get_secret
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
