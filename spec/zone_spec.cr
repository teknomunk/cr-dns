require "./spec_helper"

describe DNS do
	describe DNS::Zone do
		describe "#initialize" do
			it "Loads the example zone file from RFC 1035, section 5.3" do
				io=IO::Memory.new("
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
")
				zone = DNS::Zone.new(io)
				zone.records.size.should eq(11)
			end
			it "Loads a zone file sample from Wikipedia" do
				io=IO::Memory.new("$ORIGIN localhost.\n"+
							   "@  1D  IN  SOA   @  root 1999010100 3h 15m 1w 1d ; test comment\n"+
							   "@  1D  IN  NS    @\n"+
							   "@  1D  IN  A     127.0.0.1\n"+
							   "@  1D  IN  AAAA  ::1\n" )

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
			end
		end
	end
end
