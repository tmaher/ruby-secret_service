require 'dbus'


class SecretService
  SECRETS = 'org.freedesktop.secrets'
  SS_PREFIX = 'org.freedesktop.Secret.'
  SS_PATH = '/org/freedesktop/secrets'
  COLLECTION_PREFIX =  '/org/freedesktop/secrets/aliases/'
  DEFAULT_COLLECTION = "default"

  SERVICE_IFACE    = "#{SS_PREFIX}Service"
  COLLECTION_IFACE = "#{SS_PREFIX}Collection"
  ITEM_IFACE       = "#{SS_PREFIX}Item"

  ALGO = "plain"
  
  DBUS_UNKNOWN_METHOD  = 'org.freedesktop.DBus.Error.UnknownMethod'
  DBUS_SERVICE_UNKNOWN = 'org.freedesktop.DBus.Error.ServiceUnknown'
  DBUS_EXEC_FAILED     = 'org.freedesktop.DBus.Error.Spawn.ExecFailed'
  DBUS_NO_REPLY        = 'org.freedesktop.DBus.Error.NoReply'
  DBUS_NO_SUCH_OBJECT  = 'org.freedesktop.Secret.Error.NoSuchObject'

  attr_accessor :bus
  
  def initialize
    @bus = DBus::SessionBus.instance

    @proxy_maker = @bus.service SECRETS
    @proxy = get_proxy SS_PATH, SERVICE_IFACE
    
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
                                  COLLECTION_IFACE)
    end

    def session
      @service.session
    end

    def unlocked_items(search_pred = {})
      @proxy.SearchItems(search_pred)[0]
    end

    def locked_items(search_pref = {})
      @proxy.SearchItems(search_pred)[1]
    end
    
  end
end

class SecretService
  class Item

    def initialize(collection, item_path)
      @collection = collection
      @proxy = collection.service.get_proxy item_path, ITEM_IFACE
    end

    def session
      @collection.session
    end
    
    def get_secret path
      @proxy.GetSecret(session, path)
    end

    def your_mom
      "your mom"
    end
    
    
  end
end
