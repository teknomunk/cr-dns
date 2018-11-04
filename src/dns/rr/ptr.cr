class DNS::RR::PTR < DNS::RR
	def initialize()
		@type = DNS::RR::Type::PTR
	end

	include DNS::RR::CommonRegex
	REGEX = /^#{ZONE_OPTIONAL}PTR#{WS}#{DNAME}$/

	def self.decode_zone( ctx, md : Regex::MatchData )
		rr = self.new()
		
		rr.domain_name = ctx.translate_dname(md[4])
		rr.ttl = ctx.ttl
		rr.cls = ctx.cls
		rr.name = ctx.name

		return rr
	end

	def get_raw_data( packet : Bytes ) : Bytes
		io = IO::Memory.new
		DNS.encode_name( @domain_name, io, packet )
		return io.to_slice
	end
	def set_raw_data( packet : Bytes, rdata : Bytes )
		io = IO::Memory.new(rdata)
		@domain_name = DNS.decode_name( io, packet )
	end

	def clone()
		other = typeof(self).new()
		{% for i in %w( name ttl domain_name ) %}
			other.{{i.id}} = @{{i.id}}
		{% end %}
		return other
	end

	property domain_name : String = ""
end

