struct Slice(T)
	def substring_search( substr : Slice(T) ) : Int32?
		puts "substr: #{substr.inspect}"
		i = 0
		puts "self= #{self.inspect}"
		i_limit = size - substr.size + 1
		puts "i_limit = #{i_limit}"
		while i < i_limit
			j = 0
			j_limit = substr.size
			match = true
			while match && j < j_limit
				match = false if self[i+j] != substr[j]
				j += 1
			end
			return i if match

			i += 1
		end

		return nil
	end
	def self.concat_slices( arr : Array(Slice(T)) ) : Slice(T)
		total_size = arr.reduce(0) {|acc,i| acc + i.size }
		out = Slice(T).new( total_size )
		i = 0
		arr.each do |item|
			j = 0
			j_limit = item.size
			while j < j_limit
				out[i] = item[j]
				j += 1
				i += 1
			end
		end
		out
	end
end

