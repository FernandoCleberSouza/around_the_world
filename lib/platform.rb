
#require "cloudwalk_handshake"

class Device
  self.adapter = Platform

  def self.version
    "0.1.0"
  end
end
