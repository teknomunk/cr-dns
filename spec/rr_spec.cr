require "./spec_helper"

class String
	def to_hexbytes()
		self.bytes.map {|i| "%02X" % i }.join("")
	end
end

describe DNS do
	describe DNS::RR do
		describe DNS::RR::A do	# RFC 1035 section 3.4.1 A RDATA format
			it "encodes" do
				rr = DNS::RR::A.new()
				rr.name = "example.com."
				rr.ip_address = "127.1.2.3"
				rr.encode(io=IO::Memory.new)
				io.to_slice.should eq((
					"07#{ "example".to_hexbytes}03#{"com".to_hexbytes}00"+"0001"+"0001"+"00000000"+
					"0004"+
					"7F010203"
					).to_slice_from_hexstring)
			end
		end
		describe DNS::RR::NS do
			it "encodes" do
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
		describe DNS::RR::TXT do
			it "encodes" do
				rr = DNS::RR::TXT.new()
				rr.name = "example.com."
				rr.text = (t="DNSLINK=/ipfs/QmYrmnuar6wM7SkUTtdyfv1b4Dsq6HAnHkdhLYF2F1dwZ2/")
				rr.encode(io=IO::Memory.new)
				io.to_slice.should eq((
					"07#{ "example".to_hexbytes}03#{"com".to_hexbytes}00"+"0010"+"0001"+"00000000"+
					("%04X" % (t.size+1))+
					("%02X" % t.size)+"#{ t.to_hexbytes }"
					).to_slice_from_hexstring)
			end
		end
	end
end
