# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module I2conf
      
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
  <proxy_address>192.16.126.69</proxy_address>
  <proxy_protocol>UDP</proxy_protocol>
  <proxy_port>5060</proxy_port>
</sip_identity>}

    end
  end
end