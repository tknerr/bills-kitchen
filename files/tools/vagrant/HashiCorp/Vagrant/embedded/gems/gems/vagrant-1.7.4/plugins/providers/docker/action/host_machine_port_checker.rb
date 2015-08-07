require "log4r"

module VagrantPlugins
  module DockerProvider
    module Action
      # This sets up the middleware env var to check for ports in use.
      class HostMachinePortChecker
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant::docker::hostmachineportchecker")
        end

        def call(env)
          if ENV['VAGRANT_DOCKER_REMOTE_HOST_PATCH'] != "1"
            return @app.call(env) if !env[:machine].provider.host_vm?
          end

          @machine = env[:machine]
          env[:port_collision_port_check] = method(:port_check)

          @app.call(env)
        end

        protected

        def port_check(port)
          if ENV['VAGRANT_DOCKER_REMOTE_HOST_PATCH'] == "1"
            `docker ps`.lines.any? { |l| l.include? "0.0.0.0:#{port}->22/tcp" }
          else
            host_machine = @machine.provider.host_vm
            host_machine.guest.capability(:port_open_check, port)
          end
        end
      end
    end
  end
end
