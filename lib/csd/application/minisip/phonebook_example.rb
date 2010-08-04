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
			HDVC Clients
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
				sip:client4@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client5
			</desc>
			<uri>
				sip:client5@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client6
			</desc>
			<uri>
				sip:client6@carenet-se.se
			</uri>
		</pop>
	</contact>
	<contact>
		<name>
			Carenet-SE
		</name>
		<pop>
			<desc>
				Multiparty Conference Room
			</desc>
			<uri>
				sip:mcu@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Carenet Support Hotline
			</desc>
			<uri>
				sip:uri@carenet-se.se
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