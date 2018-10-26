class DNS::RR::A < DNS::RR
	def initialize()
		@type = DNS::RR::Type::A
	end

	include DNS::RR::CommonRegex
	REGEX = /^#{ZONE_OPTIONAL}A#{WS}#{IPV4_ADDR}$/

	def self.decode_zone( ctx, md : Regex::MatchData )
		rr = self.new()
	
		rr.ip_address = md[4]

		rr.name = ctx.name
		rr.ttl = ctx.ttl
		rr.cls = ctx.cls

		return rr
	end

	def raw_data()
		b = Bytes.new(4,0)
		@ip_address.split(".").each_with_index {|v,i| b[i] = v.to_u8 }
		return b
	end
	def raw_data=( b : Bytes )
		raise "Expecting 4 bytes, not #{b.size}" if b.size != 4
		@ip_address = b.to_a.join(".")
	end

	property ip_address : String = "0.0.0.0"
end

