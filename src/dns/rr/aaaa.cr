class DNS::RR::AAAA < DNS::RR
	def initialize()
		@type = DNS::RR::Type::AAAA
	end

	include DNS::RR::CommonRegex
	REGEX = /^#{DNAME}?#{WS}#{TIME}#{WS}#{CLS}#{WS}AAAA#{WS}#{IPV6_ADDR}$/

	def self.decode_zone( ctx, md : Regex::MatchData )
		rr = self.new()
	
		rr.name = ctx.name
		rr.ttl = ctx.ttl
		rr.cls = ctx.cls
		rr.ip_addr = md[4]

		return rr
	end

	property ip_addr : String = "::1"
end

