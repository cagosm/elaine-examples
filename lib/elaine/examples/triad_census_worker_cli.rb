require 'thor'
require 'dcell'

require 'elaine/examples/triad_census_vertex'

module Elaine
  module Examples
    class TriadCensusWorkerCLI < Thor
      desc "run", "Start a triad census worker"
      # bundle exec ruby triad_census_worker.rb slavenode11.worker1 192.168.0.12 8100 triad.census.coordinator slavenode20.cse.usf.edu
      option :name, type: :string, required: true, "The name of this worker." 
      option :ip, type: :string, required: true, "The ip address of this worker."
      option :port, type: :numeric, required: true, "The port of this worker."
      option :coordinator, type: :string, required: true, "The name of the coordinator node."
      option :redis_registery, type: :string, required: true, "The host of the redis server that we will register with."
      def run
        DCell.start id: node_id, addr: "tcp://#{options[:ip]}:#{options[:port]}", registry: {adapter: 'redis', host: options[:redis_registry]}

        Elaine::Distributed::Worker.supervise_as :worker, coordinator_node: options[:coordinator_node]
        Elaine::Distributed::PostOffice.supervise_as :postoffice
        sleep
      end
    end # class TriadCensusWorkerCLI
  end # module Examples
end # module Elaine
