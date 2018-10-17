class DNS::RR::A < DNS::RR
	def initialize()
		@type = DNS::RR::Type::A
	end

	include DNS::RR::CommonRegex
	REGEX = /^#{DNAME}?#{WS}#{TIME}#{WS}#{CLS}#{WS}A#{WS}#{IPV4_ADDR}$/

	def self.decode_zone( ctx, md : Regex::MatchData )
		rr = self.new()
	
		rr.ip_address = md[4]

		rr.name = ctx.name
		rr.ttl = ctx.ttl
		rr.cls = ctx.cls

		return rr
	end

	property ip_address : String = "0.0.0.0"
end

