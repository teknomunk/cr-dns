class IO
	def read_network_short()
		b0 = read_byte
		b1 = read_byte
		raise "Expecting two bytes" if b0.nil? || b1.nil?

		b0.to_u16 << 8 | b1
	end
	def read_network_long()
		b0 = read_byte
		b1 = read_byte
		b2 = read_byte
		b3 = read_byte

		raise "Expecting four bytes" if b0.nil?
		raise "Expecting four bytes" if b1.nil?
		raise "Expecting four bytes" if b2.nil?
		raise "Expecting four bytes" if b3.nil?

		b0.to_u32 << 24 | b1.to_u32 << 16 | b2.to_u32 << 8 | b3
	end
end

