require 'dbus'

require 'secret_service/collection'
require 'secret_service/item'
require 'secret_service/secret'

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
    
  attr_accessor :bus, :proxy
  
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

  def list_collections
    @proxy.Get(IFACE[:service], 'Collections')
  end
  
end
