# http://standards.freedesktop.org/secret-service/ch14.html#id481899
# Creating a "secret"

class SecretService
class Secret

  attr_accessor :session_path, :parameters, :content_type

  def initialize attrs
    @session_path = attrs[:session_path]
    @parameters = attrs[:parameters] || []
    @value = attrs[:value]
    @content_type = attrs[:content_type] || sniff_content_type(@value)
  end

  def value
    @value
  end

  def value= val
    @value = val
    @content_type = sniff_content_type attrs[:value]
  end

  # Create a new SecretService::Secret from the DBus Struct format
  def self.from_struct s
    initialize(:session_path => s[0][0],
               :parameters => s[0][1],
               :value => (s[0][2].map {|x| x.chr}).join,
               :content_type => (s[0][3] == "") ? nil : s[0][3]
               )
  end

  # Convert the human-readable version into the format expected
  # by DBus.
  def to_struct
    [ "(oayays)",
      [@session_path, @parameters, @value.bytes.to_a, @content_type]
    ]
  end

  
  # Take a string, guess what the Content-type should be.
  # For Ruby < 1.9, assume binary encoding.  You can avoid this
  # by passing in an explicit content_type to the initializer.
  #
  # Or, y'know, using a more recent version of the language.
  def sniff_content_type str
    if (str.nil? or
        (not str.respond_to? :encoding ) or
        (str.encoding.to_s == "ASCII-8BIT"))
      "application/octet-stream"
    else
      "text/plain; charset=#{str.encoding}"
    end
  end

  # Derive the Ruby String encoding from a given Content-type.
  # When all else fails, assumes ASCII-8BIT (aka Binary)
  def self.content_type_to_encoding content_type=nil
    binary = "ASCII-8BIT"
    
    begin
      case charset = content_type.match(/; charset=(.+)\z/)[1].upcase
      when /\AUTF[^-]/
        # "UTF8" is a common misspelling of "UTF-8".
        charset.sub! /\AUTF/, "UTF-"
      when /./
        # Accept charset.upcase at face value & hope for the best
        charset
      else
        # This is a technical violation of RFC 2616, sec. 3.7.1, which
        # states ISO-8859-1 is the default for "text/*" when no
        # charset is specified. However, I claim UTF-8 is a safer
        # assumption on the modern Internet.
        charset = content_type.match(/\Atext\//) ? "UTF-8" : binary
      end
      "".encode charset
      charset
    rescue
      binary
    end
  end
  
end
end
