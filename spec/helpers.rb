
BUILD_DIR=File.expand_path('./target/build')
LOGFILE = "#{BUILD_DIR}/acceptance.log"
CHEFDK_RUBY = "#{BUILD_DIR}/tools/chefdk/embedded"
VAGRANT_RUBY = "#{BUILD_DIR}/tools/vagrant/HashiCorp/Vagrant/embedded"

# enable :should syntax for rspec 3
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

module Helpers
  # sets the environment via set-env.bat before running the command
  # and returns whatever the cmd writes (captures both stdout and stderr)
  def run_cmd(cmd)
    `"#{BUILD_DIR}/set-env.bat" >NUL && #{cmd} 2>&1`
  end
  # similar to #run_cmd, but uses system and returns the exit code
  # (both stdout and stderr are redirected to acceptance.log)
  def system_cmd(cmd)
    system "echo \"--> Running command: '#{cmd}':\" >>#{LOGFILE}"
    unless (status = system "#{BUILD_DIR}/set-env.bat >NUL && #{cmd} >>#{LOGFILE} 2>&1")
      puts "Command failed: '#{cmd}'\n  --> see #{LOGFILE} for details"
    end
    status
  end
  # converts the path to using backslashes
  def convert_slashes(path)
    path.gsub('/', '\\').gsub('\\', '\\\\\\\\') #eek
  end
  # runs #system_cmd and checks for success (i.e. exit status 0)
  def cmd_succeeds(cmd)
    system_cmd(cmd).should be true
  end
  # checks if the given line is contained in the environment
  def env_match(line)
    run_cmd("set").should match(/^#{convert_slashes(line)}$/)
  end
  # checks if the given gem is installed at version in the CHEFDK_RUBY
  def gem_installed(name, version)
    run_cmd("#{CHEFDK_RUBY}/bin/gem list").should match("#{name} \\(#{version}\\)")
  end
  # checks if the given gem is installed at version
  def knife_plugin_installed(name, version)
    gem_installed name, version
  end
  # checks if the given gem is installed at version
  def vagrant_plugin_installed(name, version)
    run_cmd("vagrant plugin list").should match("#{name} \\(#{version}\\)")
  end
  # returns true if the box with the given name exists
  def local_box_available?(box)
    File.exist? "#{BUILD_DIR}/boxes/#{box}.box"
  end
  # returns true if the box is already imported into vagrant
  def box_imported?(box)
    run_cmd("vagrant box list").include?(box)
  end
  # returns true if the specs are run as part of a bills kitchen release build
  def release_build?
    release_version != nil
  end
  # returns the release major version env var `BK_RELEASE_VERSION`
  def release_version
    ENV['BK_RELEASE_VERSION']
  end
end