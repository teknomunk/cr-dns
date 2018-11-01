require "./spec_helper"

class String
	def to_hexbytes()
		self.bytes.map {|i| "%02X" % i }.join("")
	end
end

describe DNS do
	describe DNS::RR do
		describe DNS::RR::NS do
			it "ecodes" do
				rr = DNS::RR::NS.new()
				rr.name = "example.com."
				rr.name_server = "ns1.example.com."
				rr.encode(io=IO::Memory.new)
				io.to_slice.should eq((
					"07#{ "example".to_hexbytes}03#{"com".to_hexbytes}00"+"0002"+"0001"+"00000000"+
					"0006"+
					"03#{ "ns1".to_hexbytes }C000"
					).to_slice_from_hexstring)
			end
		end
	end
end
