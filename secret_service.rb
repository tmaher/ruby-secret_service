require 'dbus'

class SecretService
  SECRETS = 'org.freedesktop.secrets'
  SS_PREFIX = 'org.freedesktop.Secret.'
  SS_PATH = '/org/freedesktop/secrets'
  COLLECTION_PREFIX =  '/org/freedesktop/secrets/aliases/'
  DEFAULT_COLLECTION = "default"

  ALGO = "plain"
  
  DBUS_UNKNOWN_METHOD  = 'org.freedesktop.DBus.Error.UnknownMethod'
  DBUS_SERVICE_UNKNOWN = 'org.freedesktop.DBus.Error.ServiceUnknown'
  DBUS_EXEC_FAILED     = 'org.freedesktop.DBus.Error.Spawn.ExecFailed'
  DBUS_NO_REPLY        = 'org.freedesktop.DBus.Error.NoReply'
  DBUS_NO_SUCH_OBJECT  = 'org.freedesktop.Secret.Error.NoSuchObject'

  IFACE = {}
  [:service, :item, :collection].each do |x|
    IFACE[x] = "#{SS_PREFIX}#{x.to_s.capitalize}"
  end
    
  attr_accessor :bus
  
  def initialize
    @bus = DBus::SessionBus.instance

    @proxy_maker = @bus.service SECRETS
    @proxy = get_proxy SS_PATH, IFACE[:service]
    
    @collections = {}
  end

  def get_proxy path, iface=nil
    obj = @proxy_maker.object path
    obj.introspect
    obj.default_iface = iface unless iface.nil?
    obj
  end
  
  def session
    @session ||= @proxy.OpenSession(ALGO, "")
  end
  
  def collection(name=DEFAULT_COLLECTION)
    @collections[name.to_s] ||= Collection.new(self, name)
  end

end

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
      result = @proxy.CreateItem(properties, secret, replace)
      new_item_path = result[0]
      puts "path: #{new_item_path}"
      Item.new(self, new_item_path)
    end
    
  end
end

class SecretService
  class Item

    attr_accessor :path
    
    def initialize(collection, path)
      @collection = collection
      @path = path
      @proxy = collection.service.get_proxy @path, IFACE[:item]
    end

    def modified
      Time.at get_property(:modified)
    end

    def created
      Time.at get_property(:created)
    end

    def locked?
      get_property(:locked)
    end

    def label
      get_property(:label)
    end

    def label= new_label
      set_property(:label, new_label)
    end

    def attributes
      get_property(:attributes)
    end

    # TODO: this keeps throwing type errors
    def attributes= new_attrs
      set_property(:attributes, new_attrs)
    end

    def set_property name, new_val
      @proxy.Set(IFACE[:item], name.to_s.downcase.capitalize, new_val)
    end
    
    def get_property name
      @proxy.Get(IFACE[:item], name.to_s.downcase.capitalize)[0]
    end
      
    def session
      @collection.session
    end
    
    def get_secret
      secret_decode(@proxy.GetSecret session[1])
    end

    def your_mom
      "your mom"
    end

    def secret_decode secret_arr
      secret_struct = secret_arr[0]
      s = {}
      [:session, :params, :bytes, :mime].each do |x|
        s[x] = secret_struct.shift
      end

      (s[:bytes].map {|x| x.chr}).join
    end
    
  end
end
