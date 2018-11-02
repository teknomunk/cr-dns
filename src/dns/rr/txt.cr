class DNS::RR::TXT < DNS::RR
	def initialize()
		@type = DNS::RR::Type::TXT
	end

	include DNS::RR::CommonRegex
	REGEX = /^#{ZONE_OPTIONAL}TXT#{WS}"(.*)"$/

	def self.decode_zone( ctx, md : Regex::MatchData )
		rr = self.new()
	
		rr.txt = md[4]

		rr.name = ctx.name
		rr.ttl = ctx.ttl
		rr.cls = ctx.cls

		return rr
	end

	def get_raw_data( packet : Bytes )
		@text.to_slice()
	end
	def set_raw_data( packet : Bytes, rdata : Bytes )
		@text = String.new(rdata)
	end

	def clone()
		other = DNS::RR::TXT.new()
		other.name = @name
		other.ttl = @ttl
		other.text = @text
		return other
	end

	property text : String = ""
end

