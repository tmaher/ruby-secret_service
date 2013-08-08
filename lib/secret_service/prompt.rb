class SecretService
class Prompt

  def initialize service, object_path
    @service = service
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
