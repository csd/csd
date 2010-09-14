# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module I2conf
      
      # This constant defines the example configuration contents for the i2conf server.
      # This configuration is based on the current running carenet-se service, while users can 
      # modify the configuration manually by applying their own network service parameter.
      #
      CONFIG_EXAMPLE = %{
<interface>eth0</interface>
<use_udp>true</use_udp>
<use_tcp>false</use_tcp>
<sip_identity>
  <uri>mcu@carenet-se.se</uri>
  <local_port>5060</local_port>
  <register>true</register>
  <username>mcu</username>
  <password>YOURPASSWORD</password>
  <realm>carenet-se.se</realm>
</sip_identity>}

    end
  end
end