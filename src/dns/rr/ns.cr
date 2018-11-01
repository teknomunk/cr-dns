class DNS::RR::NS < DNS::RR
	def initialize()
		@type = DNS::RR::Type::NS
	end

	include DNS::RR::CommonRegex
	REGEX = /^#{ZONE_OPTIONAL}NS#{WS}#{DNAME}$/

	def self.decode_zone( ctx, md : Regex::MatchData )
		rr = self.new()
		
		rr.name_server = ctx.translate_dname(md[4])
		rr.ttl = ctx.ttl
		rr.cls = ctx.cls
		rr.name = ctx.name

		return rr
	end

	def get_raw_data( packet : Bytes ) : Bytes
		io = IO::Memory.new
		DNS.encode_name( @name_server, io, packet )
		return io.to_slice
	end
	def set_raw_data( packet : Bytes, rdata : Bytes )
	end

	def clone()
		other = DNS::RR::NS.new()
		other.name = @name
		other.ttl = @ttl
		other.name_server = @name_server
		return other
	end

	property name_server : String = ""
end

