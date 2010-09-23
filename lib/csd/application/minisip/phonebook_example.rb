# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      
      # This Array holds SHA1 hashes of phonebooks that should be overwritten by the AI without asking.
      #
      OUTDATED_PHONEBOOKS = [
        'ad51d1f3ec295dec000d9690bd1b7b801027c958',  # This is the default MiniSIP phonebook
        '611e86dfbf82457d6137371884b8f56d224fbf59',  # This is the AI-made phonebook up to (and including) version 0.3.1
        '81e65b55af8967c1cbba9947ca0de42fd79a2458'   # This is the AI-made phonebook up to (and including) version 0.3.6
      ]
      
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
				client1@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client2
			</desc>
			<uri>
				client2@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client3
			</desc>
			<uri>
				client3@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client4
			</desc>
			<uri>
				client4@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client5
			</desc>
			<uri>
				client5@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Client6
			</desc>
			<uri>
				client6@carenet-se.se
			</uri>
		</pop>
	</contact>
	<contact>
		<name>
			Virtual Rooms
		</name>
		<pop>
			<desc>
				Carenet-SE
			</desc>
			<uri>
				mcu@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				CESNET
			</desc>
			<uri>
				950087999@cesnet.cz
			</uri>
		</pop>
		<pop>
			<desc>
				TTA
			</desc>
			<uri>
			ttamcu@carenet-se.se
			</uri>
		</pop>
	</contact>
	<contact>
		<name>
			Carenet-SE
		</name>
		<pop>
			<desc>
				Carenet Support Hotline
			</desc>
			<uri>
				support@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				SIP test account
			</desc>
			<uri>
				test@carenet-se.se
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
				tandberg1@carenet-se.se
			</uri>
		</pop>
		<pop>
			<desc>
				Tandberg Client2
			</desc>
			<uri>
				tandberg2@carenet-se.se
			</uri>
		</pop>
	</contact>
</phonebook>}

    end
  end
end