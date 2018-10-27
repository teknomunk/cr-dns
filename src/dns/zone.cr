class DNS::Zone
	def initialize( path : String )
		File.open(path,"r") {|f| do_initialize(f) }
	end
	def initialize( io : IO )
		do_initialize(io)
	end

	@origin = "."
	@ttl = 0
	property records : Array(RR) = [] of RR

	include RR::CommonRegex

	def self.time( str : String )
		case str
			when /([0-9]+)[Ww]/
				$1.to_u32 * 3600*24*7
			when /([0-9]+)[Dd]/
				$1.to_u32 * 3600*24
			when /([0-9]+)[Hh]/
				$1.to_u32 * 3600
			when /([0-9]+)[Mm]/
				$1.to_u32 * 60
			else
				str.to_u32
		end
	end

	class Context
		property ttl : UInt32 = 0
		@name : String = ""
		@cls : String = ""
		property origin : String = "."

		def name()
			translate_dname(@name)
		end
		def translate_dname(name)
			case name
			when "@"
				@origin
			when /\.$/
				name.downcase
			else
				"#{name.downcase}.#{@origin}"
			end
		end
		def cls()
			#case @cls
			#when "IN"
				RR::Cls::IN
			#end
		end

		def update_optional( md : Regex::MatchData )
			if !(md1=md[1]?).nil? && md1 != ""
				@name 	= md1
			end
			if !(md2=md[2]?).nil? && md2 != ""
				@ttl		= Zone.time(md2)
			end
			if !(md3=md[3]?).nil? && md3 != ""
				@cls		= md3
			end
		end
	end

	private def do_initialize( io : IO)
		ctx = Context.new()
		while !(line=io.gets('\n')).nil?
			line = line.gsub(/[ \t]*;.*$/,"")

			# If there is a '(', continue until we get a ')'
			if /\([^"]*$/ =~ line
				# Remove the matching '('
				line = line.gsub(/\([^"]*$/) {|md| md.gsub(/^\(/,"") }

				while !(line2=io.gets('\n')).nil?
					line2 = line2.gsub(/[ \t]*;.*$/,"").gsub(/[ \t]*$/,"").gsub("\n","")

					if /\)[ \t]*$/ =~ line2
						line2 = line2.gsub(/\)[^"]*$/) {|md| md.gsub(/^\)/,"") }
						line += line2
						break
					end

					line += line2
				end	
			end
			line = line.gsub(/[ \t]*$/,"").gsub("\n","")
			{% begin %}
				case line
					when /^\$ORIGIN #{DNAME}$/
						ctx.origin = $1.downcase
					{% for type in RR::TYPES %}
						when RR::{{type.id}}::REGEX
							ctx.update_optional(md=$~)
							rr = RR::{{type.id}}.decode_zone( ctx, md ) 
							@records.push(rr) if !rr.nil?
					{% end %}
					when ""
					else
						puts "Candidates: "
						{% for type in RR::TYPES %}
							puts "\t/#{RR::{{type.id}}::REGEX.source.inspect[1..-2]}/"
						{% end %}
						raise "Unhandled line #{line.inspect}"
				end
			{% end %}
		end
	end
end

