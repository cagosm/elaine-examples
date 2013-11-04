require 'thor'
require 'dcell'

require 'elaine/examples/triad_census_vertex'

module Elaine
  module Examples
    class TriadCensusCLI < Thor

      desc "run", "Run the triad census"
      option :name, type: :string, required: true, "The name of this node."
      option :ip, type: :string, required: true, "The ip address to run this node on."
      option :port, type: :numeric, required: true, "The port for this node"
      option :coordinator, type: :string, required: true, "The coordinator node to run the job on."
      option :redis_registery, type: :string, required: true, "The host of the redis server that we will register with."
      option :graph, type: :string, required: true, "The graph to load (egonets)."
      def run
        DCell.start id: options[:name], addr: "tcp://#{options[:ip]}:#{options[:port]}", registry: {adapter: 'redis', host: options[:redis_registry]}

        graph_to_load = options[:graph]
        graph = []

        start_load = Time.now.to_i
        File.open(graph_to_load).each_line do |line|
          a = line.strip.split

          vertex = {}

          vertex[:id] = "n_#{a.shift}".to_sym
          vertex[:klazz] = Elaine::Examples::TriadCensusVertex
          vertex[:outedges] = a.map { |v| "n_#{v}".to_sym}
          vertex[:value] = {type0: 0, type1: 0, type2: 0, type3: 0}

          graph << vertex
        end
        graph.each do |v|
          v[:value][:n] = graph.size
        end
        end_load = Time.now.to_i


        puts "There are #{graph.size} nodes"

        puts "Loading graph into coordinator node"
        start_remote_load = Time.now.to_i
        coordinator_node = DCell::Node[options[:coordinator]]
        coordinator_node[:coordinator].graph = graph
        end_remote_load = Time.now.to_i

        puts "Running job"
        start_job = Time.now.to_i
        coordinator_node[:coordinator].run_job
        end_job = Time.now.to_i


        n = graph.size

        total_triads_possible = ((1 / 6.0) * n * (n - 1) * (n - 2)).to_i
        total_dyads_possible = ((1 / 2) * n * (n - 1)).to_i

        out_val = { type0: 0, type1: 0, type2: 0, type3: 0 }
        vertex_values = coordinator_node[:coordinator].vertex_values
        vertex_values.each do |v|
          # puts "node #{v[:id]} reports #{v[:value][:type2]} type 2 triads"
          # puts "node #{v[:id]} reports #{v[:value][:type3]} type 3 triads"
          out_val[:type2] += v[:value][:type2]
          out_val[:type3] += v[:value][:type3]
          # if (total_dyads_possible < (v[:value][:type1_local]))
          #   puts "node #{v[:id]} reporting more type1 local involvement than possible! (#{v[:value][:type1_local]})"
          # end
          out_val[:type1] += v[:value][:type1]
          
          # out_val[:type1] += (n - (v[:value][:type2] + v[:value][:type3]))
          # out_val[:type2] += v[:type2]
          # out_val[:type3] += v[:type3]
        end

        out_val[:type0] =  total_triads_possible - (out_val[:type1] + out_val[:type2] + out_val[:type3])

        puts "="*20
        puts "Results:"
        puts out_val
        puts "="*20

        puts "*"*20
        puts "Run times:"
        puts "Local graph load: #{end_load - start_load}"
        puts "Remote graph load: #{end_remote_load - start_remote_load}"
        puts "Job: #{end_job - start_job}"
        puts "*"*20


      end
    end # class TriadCensusCLI
  end # module Examples
end # module Elaine
