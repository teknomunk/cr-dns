require "mergeheapqueue"

class DNS::Cache
	class CacheLine
		property question : DNS::RR

		property answers : Array(DNS::RR)
		property authority : Array(DNS::RR)
		property additional : Array(DNS::RR)

		property expires : Time

		def index_string()
			"#{@question.type} #{@question.cls} #{@question.name}"
		end
		
		def initialize( @question, @answers, @authority, @additional )
			min_ttl = Int32::MAX
			{% for i in %w( answers authority additional) %}
				@{{i.id}}.each {|rr| min_ttl = {min_ttl,rr.ttl}.min }
			{% end %}
			@expires = Time.utc_now + Time::Span.new( seconds: min_ttl )
		end
	end

	@records = {} of String => CacheLine
	@queue = MergeHeapQueue(CacheLine).new

	def initialize()
		spawn do
			# Handle expiring entries from the cache
			loop {
				while !@queue.empty? && (n=@queue.next).expires <= Time.now
					@queue.pop()
					@records.delete( n.index_string )
				end
				sleep 1
			}
		end
	end

	def insert( msg : DNS::Message )
	end
	def find( msg : DNS::Message ) : Bool
		is_match = false
		msg.questions.each {|q|
			if !(line=@records[ CacheLine.new(q) ]?).nil?
				# TODO: add check here for expires in case any miss the normal sweep

				{% for i in %w( answers authority additional ) %}
					line.{{i.id}}.each {|rr| msg.{{i.id}}.push(rr) }
				{% end %}
				is_match = true
			end
		}
		return is_match
	end
end
