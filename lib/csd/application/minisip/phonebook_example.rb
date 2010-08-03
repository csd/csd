# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      
      PHONEBOOK_EXAMPLE = %{
<phonebook>
	<name>
		TTA
	</name>
	<contact>
		<name>
			TTA HDVC
		</name>
		<pop>
			<desc>
				Client 1
			</desc>
			<uri>
				sip:client1@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client2
			</desc>
			<uri>
				sip:client2@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client3
			</desc>
			<uri>
				sip:client3@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client4
			</desc>
			<uri>
				ip:client4@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client5
			</desc>
			<uri>
				ip:client5@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Clien6
			</desc>
			<uri>
				ip:client6@carenet-se.se
			</uri>
		</pop>
	</contact>
	<contact>
		<name>
			Carenet-SE
		</name>
		<pop>
			<desc>
				Reflector
			</desc>
			<uri>
				sip:mcu@carenet-se.se
			</uri>
		</pop>
	</contact>
	<contact>
		<name>
			Tandberg
		</name>
		<pop>
			<desc>
				Tandberg Client1
			</desc>
			<uri>
				sip:tandberg1@carenet-se.se
			</uri>
		</pop>
	</contact>
	<contact>
		<name>
			Tandberg
		</name>
		<pop>
			<desc>
				Tandberg Client2
			</desc>
			<uri>
				sip:tandberg2@carenet-se.se
			</uri>
		</pop>
	</contact>
</phonebook>}

    end
  end
end