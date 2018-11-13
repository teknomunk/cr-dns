require "./spec_helper"
#require "./mock/network_factory.cr"

describe DNS do
	describe DNS::Resolver::Iterative do
		server1 = DNS::Server.new()
		server1.add_zone(DNS::Zone.new(IO::Memory.new(<<-DOC
			$ORIGIN .
			*.com.		1D	IN	NS	a.gtld-servers.net.
			a.gtld-servers.net.	1D	IN	A	1.2.3.4
			DOC
		)))
		server2 = DNS::Server.new()
		server2.add_zone(DNS::Zone.new(IO::Memory.new(<<-DOC
			$ORIGIN example.com.
			@		1D	IN	NS	ns1.example.com.
			@		1D	IN	A	2.3.4.5
			ns1		1D	IN	A	2.3.4.15
			DOC
		)))

		resolver = DNS::Resolver::Iterative.new()
		#resolver.factory = (factory=Mock::NetworkFactory.new())
		
		#factory.servers["A 1.2.3.5"] = server1
		#factory.servers["A 1.2.3.4"] = server2

		it "can resolve domains" do
			msg = DNS::Message.simple_query("A", "www.example.com").not_nil!
			#puts msg.inspect
			res = resolver.resolve(msg.not_nil!)	# TODO: Fix this, it will not compile if this is uncommented
			#puts res.inspect
		end
	end
end
