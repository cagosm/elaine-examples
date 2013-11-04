require 'thor'

module Elaine
  module Examples
    class TriadCensusCoordinatorCLI < Thor
      desc "start", "Start a triad census worker"
      # bundle exec ruby triad_census_worker.rb slavenode11.worker1 192.168.0.12 8100 triad.census.coordinator slavenode20.cse.usf.edu
      option :name, type: :string, required: true, desc: "The name of this coordinator." 
      option :ip, type: :string, required: true, desc: "The ip address of this coordinator."
      option :port, type: :numeric, required: true, desc: "The port of this coordinator."
      option :redis_registry, type: :string, required: true, desc: "The host of the redis server that we will register with."
      def start
        require 'dcell'
        require 'elaine/examples/triad_census_vertex'
        
        DCell.start id: options[:name], addr: "tcp://#{options[:ip]}:#{options[:port]}", registry: {adapter: 'redis', host: options[:redis_registry]}

        Elaine::Distributed::Coordinator.supervise_as :coordinator
        sleep

      end
    end # class TriadCensusCoordinatorCLI
  end # module Examples
end # module Elaine
