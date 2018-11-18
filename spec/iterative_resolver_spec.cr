require "./spec_helper"
require "./mock/network_factory.cr"

describe DNS do
	describe DNS::Resolver::Iterative do
		# . root nameserver stand in
		server1 = DNS::Server.new()
		server1.add_zone(DNS::Zone.new(IO::Memory.new(<<-DOC
			$ORIGIN .
			*.com.		1D	IN	NS	a.gtld-servers.net.
			a.gtld-servers.net.	1D	IN	A	1.2.3.4
			DOC
		)))
		# .com nameserver stand in
		server2 = DNS::Server.new()
		server2.add_zone(DNS::Zone.new(IO::Memory.new(<<-DOC
			$ORIGIN example.com.
			@		1D	IN	NS	ns1.example.com.
			ns1		1D	IN	A	2.3.4.15
			DOC
		)))

		# example.com nameserver stand in
		server3 = DNS::Server.new()
		server3.add_zone(DNS::Zone.new(IO::Memory.new(<<-DOC
			$ORIGIN example.com.
			@		1D	IN	NS	ns1.example.com.
			@		1D	IN	A	2.3.4.5
			ns1		1D	IN	A	2.3.4.15
			DOC
		)))

		resolver = DNS::Resolver::Iterative.new()
		resolver.factory = (factory=Mock::NetworkFactory.new())
		
		factory.servers["A 1.2.3.5"] = server1
		factory.servers["A 1.2.3.4"] = server2
		factory.servers["A 2.3.4.15"] = server3

		resolver.hint_zone = hint_zone = DNS::Zone.new(IO::Memory.new(<<-DOC
			$ORIGIN .
			@					1D	IN	NS	a.root-servers.net.
			a.root-servers.net.		1D	IN	A	198.41.0.4
			DOC
		))
		resolver.hint(hint_zone.records[0])

		it "can resolve domains" do
			msg = DNS::Message.simple_query("A", "www.example.com").not_nil!
			res = resolver.resolve(msg.not_nil!)	# TODO: Fix this, it will not compile if this is uncommented
			puts res.inspect
			res.should_not be_nil
			res.answers.size.should eq(1)
		end
	end
end
