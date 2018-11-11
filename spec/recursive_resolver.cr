require "./spec_helpers"

describe DNS do
	describe DNS::Resolver::Iterative do
		server1 = DNS::Server.new()
		server1.add_zone(DNS::Zone.new(IO::Memory.new(<<-DOC
			$ORIGIN .
			com.		1D	IN	NS	a.gtld-servers.net.
			a.gtld-servers.net.	1D	IN	A	1.2.3.4
			DOC
		))
		server2.add_zone(DNS::Zone.new(IO::Memory.new(<<-DOC
			$ORIGIN example.com.
			@		1D	IN	NS	ns1.example.com.
			@		1D	IN	A	2.3.4.5
			ns1		1D	IN	A	2.3.4.15
			DOC
		))

		resolver = DNS::IterativeResolver.new()
		
	end
end
