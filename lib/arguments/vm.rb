gem 'ruby_parser', '>= 2.0.2'
require 'ruby_parser'

module Arguments
  class PermissiveRubyParser < RubyParser
    def on_error t, val, vstack
      @rescue = vstack.first
    end

    def parse str, file = "(string)"
      super || @rescue
    end
  end
  
  def self.ast_for_method klass, method, am_self
    source, line = klass.instance_method(method).source_location
    strs = []
#    strs << IO.readlines( source )[ (line-1)..(line+5) ].join # +5 necessary to parse http://github.com/rdp/p2pwebclient/blob/9539a7f01c761da95081f3121097c368d64fc70a/src/lib/block_manager.rb -- nobody would want a method def. > 5 anyway, right?
    strs << IO.readlines( source )[ (line-1)..-1 ].join # whole file

    for str in strs
      ast = PermissiveRubyParser.new.parse( str )
      if ast
        if am_self
          return (ast.assoc( :defs ) or ast)
        else
          return (ast.assoc( :defn ) or ast)
        end
      end
    end
    raise 'unable to parse method' + klass.to_s + method
  end
end