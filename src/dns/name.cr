
module DNS
	def self.decode_name( io : IO, packets : Bytes ) : String
		parts = [] of String
		part_size = 1

		while part_size != 0
			byte = io.read_byte
			raise "Expecting byte" if byte.nil?
			if ( byte & 0xC0 ) == 0xC0
				byte2 = io.read_byte
				raise "Expecting two byte sequence" if byte2.nil?

				offset = (byte.to_u32 & 0x3F) << 8 | byte2
				dname = decode_name( IO::Memory.new(packets+offset), packets )
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
	def self.encode_name( name : String, io : IO, packet : Bytes )
		if name == "."
			io.write_byte 0_u8
			return
		else
			parts = name.split(".")
			parts.pop() if parts[-1] == ""
		end

		parts = parts.map {|part|
			i = IO::Memory.new()
			i.write_byte( part.size.to_u8 )
			i.write part.to_slice if part.size > 0
			i.to_slice
		}

		i = 0
		i_limit = parts.size
		while i < i_limit
			substr = Bytes.concat_slices(parts[i..-1])
			if substr.size >= 2 && (idx=packet.substring_search(substr))
				io.write_network_short( 0xC000_u16 | idx )
				return
			else
				io.write parts[i]
			end
			i += 1
		end

		io.write_byte 0_u8
	end

end
