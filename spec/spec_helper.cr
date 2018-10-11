require "spec"
require "../src/dns"

class Array(T)
	def to_slice()
		return Slice(T).new(0,0) if self.size == 0
		slice = Slice(T).new(size,self[0])
		self.each_with_index {|v,i| slice[i] = v }
		return slice
	end
end
class String
	def to_slice_from_hexstring()
		byte_count = (self.size+1)/2
		res = Bytes.new(byte_count,0)
		byte_count.times {|i|
			res[i] = self[i*2,2].to_i(16).to_u8
		}
		return res
	end
end
