require 'dbus'

require 'secret_service/collection'
require 'secret_service/item'
require 'secret_service/secret'
require 'secret_service/prompt'

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
  [:service, :item, :collection, :prompt].each do |x|
    IFACE[x] = "#{SS_PREFIX}#{x.to_s.capitalize}"
  end
    
  attr_accessor :bus, :proxy

  class NoSessionBus < Exception
  end
  
  def initialize
    begin
      @bus = DBus::SessionBus.instance

      @proxy_maker = @bus.service SECRETS
      @proxy = get_proxy SS_PATH, IFACE[:service]
      @collections = {}

      @collection_paths = self.list_collections
    rescue
      raise NoSessionBus
    end
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
  
  def collection(name=DEFAULT_COLLECTION, path=nil)
    @collections[name.to_s] ||= Collection.new(self, name, path)
  end

  def list_collections
    @proxy.Get(IFACE[:service], 'Collections')
  end

  def create_collection name, properties=nil
    properties ||= {"#{SS_PREFIX}Collection.Label" => name}

    coll, prompt_path = @proxy.CreateCollection properties, ""
    prompt!(prompt_path) if prompt_path != "/"
    collection(name, coll)
  end

  
  def set_alias name, collection
    @proxy.SetAlias name, (collection.class == String ? collection : collection.path)
  end

  def read_alias name
    path = @proxy.ReadAlias name
    collection(name, path)
  end
  
  def search_items attrs={}
    @proxy.SearchItems(attrs)
  end

  def unlock objects
    @proxy.Unlock objects
  end

  def prompt!(prompt_path)
    SecretService::Prompt.new(self, prompt_path).prompt!
  end
  
end
