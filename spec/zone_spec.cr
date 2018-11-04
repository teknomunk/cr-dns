require "./spec_helper"

describe DNS do
	describe DNS::Zone do
		describe "#initialize" do
			it "Loads the example zone file from RFC 1035, section 5.3" do
				io=IO::Memory.new(
					<<-FILE
					@   IN  SOA     VENERA      Action\.domains (
					                                 20     ; SERIAL
					                                 7200   ; REFRESH
					                                 600    ; RETRY
					                                 3600000; EXPIRE
					                                 60)    ; MINIMUM
					
					        NS      A.ISI.EDU.
					        NS      VENERA
					        NS      VAXA
					        MX      10      VENERA
					        MX      20      VAXA
					
					A       A       26.3.0.103
					
					VENERA  A       10.1.0.52
					        A       128.9.0.32
					
					VAXA    A       10.2.0.27
					        A       128.9.0.33
					FILE
				)
				zone = DNS::Zone.new(io)
				zone.records.size.should eq(11)
			end # it "Loads the example zone file from RFC 1035, section 5.3"

			it "Loads a zone file sample from Wikipedia" do
				io=IO::Memory.new(
					<<-FILE
					$ORIGIN localhost.
					@  1D  IN  SOA   @  root 1999010100 3h 15m 1w 1d ; test comment
					@  1D  IN  NS    @
					@  1D  IN  A     127.0.0.1
					@  1D  IN  AAAA  ::1
					FILE
				)

				zone = DNS::Zone.new(io)
				zone.records.size.should eq(4)
				zone.records[0].type.should eq(DNS::RR::Type::SOA)
				if (rr=zone.records[0]).is_a?(DNS::RR::SOA)
					rr.rname.should eq("root")
					rr.mname.should eq("localhost.")
					rr.serial.should eq(1999010100)
					rr.refresh.should eq(10800)
					rr.retry.should eq(900)
					rr.expire.should eq(604800)
					rr.minimum.should eq(86400)
					rr.ttl.should eq(86400)
				else
					raise "Expecting DNS::RR::SOA, not #{rr.class}"
				end

				zone.records[1].type.should eq(DNS::RR::Type::NS)
				if (rr=zone.records[1]).is_a?(DNS::RR::NS)
					rr.name_server.should eq("localhost.")
					rr.name.should eq("localhost.")
					rr.ttl.should eq(86400)
				else
					raise "Error"
				end

				zone.records[2].type.should eq(DNS::RR::Type::A)
				if (rr=zone.records[2]).is_a?(DNS::RR::A)
					rr.ip_address.should eq("127.0.0.1")
					rr.name.should eq("localhost.")
					rr.ttl.should eq(86400)
				else
					raise "Error"
				end

				zone.records[3].type.should eq(DNS::RR::Type::AAAA)
				if (rr=zone.records[3]).is_a?(DNS::RR::AAAA)
					rr.ip_address.should eq("::1")
					rr.name.should eq("localhost.")
					rr.ttl.should eq(86400)
				else
					raise "Error"
				end
			end # it "Loads a zone file sample from Wikipedia"
		end # describe "#initialize" do

		describe "#to_s(io)" do
			it "Can turn a zone into a zone file" do
				#z = DNS::Zone.new()
			end
		end

		it "can read TXT records" do
			io=IO::Memory.new(
				<<-FILE
				$ORIGIN localhost.
				@	1D	IN	TXT "This is a test"
				FILE
			)
			zone = DNS::Zone.new(io)

			zone.records.size.should eq(1)
			rr=zone.records[0]
			rr.type.should eq(DNS::RR::Type::TXT)
			rr.name.should eq("localhost.")
			rr.ttl.should eq(86400)
			if rr.is_a?(DNS::RR::TXT)
				rr.text.should eq("This is a test")
			end
		end

		it "can read CNAME records" do
			io=IO::Memory.new(
				<<-FILE
				$ORIGIN localhost.
				@	1D	IN	CNAME	remote.host.
				FILE
			)
			zone = DNS::Zone.new(io)

			zone.records.size.should eq(1)
			rr=zone.records[0]
			rr.type.should eq(DNS::RR::Type::CNAME)
			rr.name.should eq("localhost.")
			rr.ttl.should eq(86400)
			if rr.is_a?(DNS::RR::CNAME)
				rr.domain_name.should eq("remote.host.")
			end
		end
		it "can read PTR records" do
			io=IO::Memory.new(
				<<-FILE
				$ORIGIN some.host.
				@	1D	IN	PTR	another.host.
				FILE
			)
			zone = DNS::Zone.new(io)

			zone.records.size.should eq(1)
			rr=zone.records[0]
			rr.type.should eq(DNS::RR::Type::PTR)
			rr.name.should eq("some.host.")
			rr.ttl.should eq(86400)
			if rr.is_a?(DNS::RR::PTR)
				rr.domain_name.should eq("another.host.")
			end
		end

		it "can read A records" do
			io=IO::Memory.new(
				<<-FILE
				$ORIGIN localhost.
				@	1D	IN	A	127.0.0.1
				FILE
			)
			zone = DNS::Zone.new(io)

			zone.records.size.should eq(1)
			rr=zone.records[0]
			rr.type.should eq(DNS::RR::Type::A)
			rr.name.should eq("localhost.")
			rr.ttl.should eq(86400)
			if rr.is_a?(DNS::RR::A)
				rr.ip_address.should eq("127.0.0.1")
			end
		end

		it "can read AAAA records" do
			io=IO::Memory.new(
				<<-FILE
				$ORIGIN localhost.
				@	1D	IN	AAAA	::1
				FILE
			)
			zone = DNS::Zone.new(io)

			zone.records.size.should eq(1)
			rr=zone.records[0]
			rr.type.should eq(DNS::RR::Type::AAAA)
			rr.name.should eq("localhost.")
			rr.ttl.should eq(86400)
			if rr.is_a?(DNS::RR::AAAA)
				rr.ip_address.should eq("::1")
			end
		end

		it "can read HINFO records" do
			io=IO::Memory.new(
				<<-FILE
				$ORIGIN localhost.
				@	1D	IN	HINFO "PDP-11/70" "UNIX"
				FILE
			)
			zone = DNS::Zone.new(io)

			zone.records.size.should eq(1)
			rr=zone.records[0]
			rr.type.should eq(DNS::RR::Type::HINFO)
			rr.name.should eq("localhost.")
			rr.ttl.should eq(86400)
			if rr.is_a?(DNS::RR::HINFO)
				rr.cpu.should eq("PDP-11/70")
				rr.os.should eq("UNIX")
			end
		end

		it "can be used with a DNS server" do
			srv = DNS::Server.new()

			io=IO::Memory.new(
				<<-FILE
				$ORIGIN localhost.
				@  1D  IN  SOA   @  root 1999010100 3h 15m 1w 1d ; test comment
				@  1D  IN  NS    @
				@  1D  IN  A     127.0.0.1
				@  1D  IN  AAAA  ::1
				*.test 1D IN A	127.0.0.2
				FILE
			)

			
			zone = DNS::Zone.new(io)

			srv.add_zone( zone )
			spawn do
				srv.run()
			end

			srv.channel_listener.send_request( DNS::Message.simple_query( "A", "localhost." ).not_nil! )
			msg = srv.channel_listener.get_response()
			
			msg.answers.size.should eq(1)
			msg.answers[0].type.should eq(DNS::RR::Type::A)
			msg.answers[0].name.should eq("localhost.")
			if (rr=msg.answers[0]).is_a?(DNS::RR::A)
				rr.ip_address.should eq("127.0.0.1")
				rr.ttl.should_not eq(0)
			end

			# Check wildcard request
			resolv = DNS::Resolver.new( srv.channel_listener )
			msg = resolv.resolve( DNS::Message.simple_query( "A", "something.test.localhost." ) )
			#srv.channel_listener.send_request( DNS::Message.simple_query( "A", "something.test.localhost." ).not_nil! )
			#msg = srv.channel_listener.get_response()

			msg.answers.size.should eq(1)
			msg.answers[0].type.should eq(DNS::RR::Type::A)
			msg.answers[0].name.should eq("something.test.localhost.")
			if (rr=msg.answers[0]).is_a?(DNS::RR::A)
				rr.ip_address.should eq("127.0.0.2")
				rr.ttl.should_not eq(0)
			end
		end
	end # describe DNS::Zone do
end # describe DNS do
