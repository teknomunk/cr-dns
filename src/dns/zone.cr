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

	include DNS::RR::CommonRegex

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
				$1.to_u32
		end
	end

	class Context
		property ttl : UInt32 = 0
		@name : String = ""
		@cls : String = ""
		property origin : String = "."

		def name()
			( @name == "@" ? @origin : @name )
		end
		def cls()
			#case @cls
			#when "IN"
				DNS::RR::Cls::IN
			#end
		end

		def update_optional( md : Regex::MatchData )
			puts md.inspect
			@ttl		= DNS::Zone.time(md[2]) if md[2] != ""
			@name 	= md[2] if md[2] != ""
			@cls		= md[3] if md[3] != ""
		end
	end

	private def do_initialize( io : IO)
		ctx = Context.new()
		while !(line=io.gets('\n')).nil?
			line = line.gsub(/[ \t]*;.*$/,"")
			{% begin %}
			case line
				when /^\$ORIGIN #{DNAME}$/
					ctx.origin = $1
				{% for type in %w(SOA A AAAA NS) %}
				when DNS::RR::{{type.id}}::REGEX
					ctx.update_optional(md=$~)
					@records.push( DNS::RR::{{type.id}}.decode_zone( ctx, md ) )
				{% end %}
				else
					puts "Unhandled line #{line}"
			end
			{% end %}
		end
	end
end

