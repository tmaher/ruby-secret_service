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
    secret_decode(@proxy.GetSecret(session[1]))
  end

  def your_mom
    "your mom"
  end

  # http://standards.freedesktop.org/secret-service/ch14.html#type-Secret
  def secret_decode secret_arr
    puts "arr is #{secret_arr.to_s}"
    secret_struct = secret_arr[0]
    s = {}
    [:session, :params, :bytes, :mime].each do |x|
      s[x] = secret_struct.shift
    end

    secret_string = (s[:bytes].map {|x| x.chr}).join
    if(secret_string.respond_to? "encoding" and
       s[:mime] != "application/octet-stream")
      charset = s[:mime].match(/charset=(.+)/)[1]
      unless charset.nil?
        charset.upcase!.sub! /\AUTF([\w\d])/, "UTF-#{$1}"
        secret_string.force_encoding charset
      end
    end
    secret_string
  end

end
end
