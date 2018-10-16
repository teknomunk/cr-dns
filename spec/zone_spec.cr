require "./spec_helper"

describe DNS do
	describe DNS::Zone do
		it "#initialize" do
			io=IO::Memory.new("$ORIGIN localhost.\n"+
						   "@  1D  IN  SOA   @  root 1999010100 3h 15m 1w 1d ; test comment\n"+
						   "@  1D  IN  NS    @\n"+
						   "@  1D  IN  A     127.0.0.1\n"+
						   "@  1D  IN  AAAA  ::1\n" )

			zone = DNS::Zone.new(io)
			puts zone.records.inspect
			zone.records.size.should eq(4)
		end
	end
end
