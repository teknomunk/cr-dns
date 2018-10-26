class DNS::RR::SOA < DNS::RR
	def initialize()
		@type = DNS::RR::Type::SOA
	end

	include DNS::RR::CommonRegex
	REGEX = /^#{ZONE_OPTIONAL}SOA#{WS}#{DNAME}#{WS}(.*)$/

	def self.decode_zone( ctx, md : Regex::MatchData )
		rr = self.new()
		
		parts = md[5].split(/[ \t]+/)
		rr.mname = ctx.translate_dname(md[4])
		rr.rname = parts[0]
		rr.serial = parts[1].to_u32
		rr.refresh = DNS::Zone.time(parts[2])
		rr.retry = DNS::Zone.time(parts[3])
		rr.expire = DNS::Zone.time(parts[4])
		rr.minimum = DNS::Zone.time(parts[5])

		rr.name = ctx.name
		rr.ttl = ctx.ttl
		rr.cls = ctx.cls

		return rr
	end

	def raw_data()
		return Bytes.new(1,0)
	end
	def raw_data=( b : Bytes )
	end

	property mname : String = ""
	property rname : String = ""
	property serial : UInt32 = 0
	property refresh : UInt32 = 0
	property retry : UInt32 = 0
	property expire : UInt32 = 0
	property minimum : UInt32 = 0
end
