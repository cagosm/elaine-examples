require 'thor'
require 'dcell'

require 'elaine/examples/triad_census_vertex'

module Elaine
  module Examples
    class TriadCensusCoordinatorCLI < Thor
      desc "run", "Start a triad census worker"
      # bundle exec ruby triad_census_worker.rb slavenode11.worker1 192.168.0.12 8100 triad.census.coordinator slavenode20.cse.usf.edu
      option :name, type: :string, required: true, "The name of this coordinator." 
      option :ip, type: :string, required: true, "The ip address of this coordinator."
      option :port, type: :numeric, required: true, "The port of this coordinator."
      option :redis_registery, type: :string, required: true, "The host of the redis server that we will register with."
      def run

        DCell.start id: options[:name], addr: "tcp://#{options[:ip]}:#{options[:port]}", registry: {adapter: 'redis', host: options[:redis_registry]}

        Elaine::Distributed::Coordinator.supervise_as :coordinator
        sleep

      end
    end # class TriadCensusCoordinatorCLI
  end # module Examples
end # module Elaine
