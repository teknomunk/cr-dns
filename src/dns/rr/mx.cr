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

	def get_raw_data( packet : Bytes ) : Bytes
		io = IO::Memory.new()
		io.write_network_short( @preference )
		DNS.encode_name( @exchange, io, packet )
		return io.to_slice
	end
	def set_raw_data( packet : Bytes, rdata : Bytes )
	end

	def clone()
		other = DNS::RR::MX.new()
		other.name = @name
		other.ttl = @ttl
		other.preference = @preference
		other.exchange = @exchange
		return other
	end

	property preference : UInt16 = UInt16::MAX
	property exchange : String = ""
end

