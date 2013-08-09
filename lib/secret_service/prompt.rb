class SecretService
class Prompt

  attr_accessor :path

  class NoPromptRequired < Exception ; end
  
  def initialize service, object_path
    raise NoPromptRequired if object_path == "/"
    @service = service
    @path = object_path
    @proxy = service.get_proxy object_path, SecretService::IFACE[:prompt]
  end

  def prompt!
    loop = DBus::Main.new
    loop << @service.bus
    @proxy.on_signal("Completed") do |dismissed, result|
      puts "prompt call complete: dismissed #{dismissed}, result #{result}"
      loop.quit
    end
    @proxy.Prompt ""
    loop.run
  end

  def dismiss
    @proxy.Dismiss
  end
  
end
end
