
class DNS::RR
	def self.parse_name( io : IO, packets : Bytes ) : String
		parts = [] of String
		part_size = 1

		while part_size != 0
			byte = io.read_byte
			raise "Expecting byte" if byte.nil?
			if ( byte & 0xC0 ) == 0xC0
				byte2 = io.read_byte
				raise "Expecting two byte sequence" if byte2.nil?

				offset = (byte.to_u32 & 0x3F) << 8 | byte2
				dname = parse_name( IO::Memory.new(packets+offset), packets )
				parts.push(dname)

				return parts.join(".")
			else
				part_size = byte.to_i32
				part = io.gets(part_size)
				parts.push(part) if !part.nil?
			end
		end

		return "." if parts.size == 0
		
		return parts.join(".")
	end
end
