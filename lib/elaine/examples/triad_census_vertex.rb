require 'elaine/distributed'
require 'json'
require 'logger'

module Elaine
  module Examples
    class TriadCensusVertex < Elaine::Distributed::Vertex

      def logger
        @logger ||= Logger.new(STDERR)
      end

      def sym_id_to_i(sym_id)
        sym_id.to_s.split("_")[1].to_i
      end

      def compute
        # puts "Working on supserstep: #{superstep}"
        if superstep == 1
          # if id == :n_1
            logger.info "Super step 1: #{id}"
            neighborhood = []
            @outedges.each do |e|
              neighborhood << e
            end
            # @outedges.each 
            msg = {source: id, neighborhood: neighborhood}
            # deliver_to_all_neighbors(msg)
            my_numeric_id = id.to_s.split("_")[1].to_i 
            @outedges.each do |e|
              their_numeric_id = e.to_s.split("_")[1].to_i 
              if their_numeric_id < my_numeric_id
                deliver(e, msg)
              end
            end

            # @outedges.each do |e|
            #   future = Celluloid::Actor[:postoffice].future(:deliver, e, msg)
            #   future.value
            # end
          # end
        elsif superstep == 2
          logger.info "Super step 2: #{id}"
          # sum = messages.inject(0) {|total,msg| total += msg; total }
          # sum = messages.reduce(0, :+)
          u = id.to_s.split("_")[1].to_i 
          messages.each do |msg|
            # msg = JSON.parse(msg_json, symbolize_names: true)
            # raise "Got an out-of-step message! current superstep: #{superstep}, message from superstep: #{msg[:superstep]}" if msg[:superstep] != (superstep - 1)  
            v = sym_id_to_i msg[:source]
            if u < v
              type3s = (@outedges & msg[:neighborhood]).select { |neighbor| v < neighbor.to_s.split("_")[1].to_i }
              @value[:type3] += type3s.size
              
              possible_type2s = (@outedges | msg[:neighborhood]).select { |neighbor| u < sym_id_to_i(neighbor) && sym_id_to_i(neighbor) != v }
              possible_type2s = possible_type2s - type3s

              possible_type2s.each do |w|
                if @outedges.include? w
                  # i am the pivot
                  @value[:type2] += 1 if v < sym_id_to_i(w)
                else
                  # i am not the pivot.
                  @value[:type2] += 1
                end
              end

              # it would be nice to do this locally...
              @value[:type1] += @value[:n] - ((@outedges | msg[:neighborhood]).size)
            end
          end
        
        else
          logger.info "Voting to stop"
          vote_to_stop
        end

        
      end
    end

  end # module Examples
end # module Elaine

    