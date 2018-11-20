macro debug( *args )
	puts "{% for arg in args %}{{arg.id}}=#{{{arg.id}}}, {% end %}"
end

def monitor( id, &block )
	begin
		puts "entering #{id}"
		res = yield
	rescue e
		puts "error #{id}"
		raise e
	end
	puts "exiting #{id}"
	return res
end
