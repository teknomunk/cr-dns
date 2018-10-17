class DNS::RR::NS < DNS::RR
	def initialize()
		@type = DNS::RR::Type::NS
	end

	include DNS::RR::CommonRegex
	REGEX = /^#{DNAME}?#{WS}#{TIME}#{WS}#{CLS}#{WS}NS#{WS}#{DNAME}$/

	def self.decode_zone( ctx, md : Regex::MatchData )
		rr = self.new()
		
		rr.name_server = ctx.translate_dname(md[4])
		rr.ttl = ctx.ttl
		rr.cls = ctx.cls
		rr.name = ctx.name

		return rr
	end

	property name_server : String = ""
end

