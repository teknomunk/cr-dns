class DNS::RR::HINFO < DNS::RR
	def initialize()
		@type = DNS::RR::Type::HINFO
	end

	include DNS::RR::CommonRegex
	REGEX = /^#{ZONE_OPTIONAL}HINFO#{WS}"(.*)"#{WS}"(.*)"$/

	def self.decode_zone( ctx, md : Regex::MatchData )
		rr = self.new()
	
		rr.cpu = md[4]
		rr.os = md[5]

		rr.name = ctx.name
		rr.ttl = ctx.ttl
		rr.cls = ctx.cls

		return rr
	end

	def get_raw_data( packet : Bytes )
		io = IO::Memory.new()
		io.write_byte( @cpu.size.to_u8 )
		io.write( @cpu.to_slice )
		io.write_byte( @os.size.to_u8 )
		io.write( @os.to_slice )
		io.to_slice()
	end
	def set_raw_data( packet : Bytes, rdata : Bytes )
		cpu_len = rdata[0].to_i32
		os_len = rdata[1+cpu_len].to_i32
		@cpu = String.new(rdata[1,cpu_len])
		@os = String.new(rdata[2+cpu_len,os_len])
	end

	def clone()
		other = typeof(self).new()
		{% for field in %w( name ttl cpu os ) %}
			other.{{field.id}} = @{{field.id}}
		{% end %}
		return other
	end

	property cpu : String = ""
	property os : String = ""
end

