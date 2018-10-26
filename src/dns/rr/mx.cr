class DNS::RR::MX < DNS::RR
	def initialize()
		@type = DNS::RR::Type::MX
	end

	include DNS::RR::CommonRegex
	REGEX = /^#{ZONE_OPTIONAL}MX#{WS}([0-9]+)#{WS}#{DNAME}$/

	def self.decode_zone( ctx, md : Regex::MatchData )
		rr = self.new()
		
		rr.preference = md[4].to_u16
		rr.exchange = ctx.translate_dname(md[5])
		rr.ttl = ctx.ttl
		rr.cls = ctx.cls
		rr.name = ctx.name

		return rr
	end

	def raw_data() : Bytes
		return Bytes.new(1,0)
	end
	def raw_data=( b : Bytes )
	end

	property preference : UInt16 = UInt16::MAX
	property exchange : String = ""
end

