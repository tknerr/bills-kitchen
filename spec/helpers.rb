
BUILD_DIR=File.expand_path('./target/build')
CHEFDK_RUBY = "#{BUILD_DIR}/tools/chefdk/embedded"
CHEFDK_HOME = "#{BUILD_DIR}/home/.chefdk"
VAGRANT_RUBY = "#{BUILD_DIR}/tools/vagrant/HashiCorp/Vagrant/embedded"
VAGRANT_HOME = "#{BUILD_DIR}/home/.vagrant.d"

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
  def run_cmd_no_redirect(cmd)
    `"#{BUILD_DIR}/set-env.bat" >NUL && #{cmd}`
  end
  # similar to #run_cmd, but runs quietly and returns only the exit code
  def system_cmd(cmd)
    system "\"#{BUILD_DIR}/set-env.bat\" >NUL && #{cmd} >NUL"
  end
  # runs #system_cmd and checks for success (i.e. exit status 0)
  def cmd_succeeds(cmd)
    system_cmd(cmd).should be true
  end
  # converts the path to using backslashes
  def convert_slashes(path)
    path.gsub('/', '\\').gsub('\\', '\\\\\\\\') #eek
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
  # checks if the given vagrant plugin is installed at version
  def vagrant_plugin_installed(name, version)
    run_cmd("vagrant plugin list").should match("#{name} \\(#{version}\\)")
  end
  # checks if the given atom plugin is installed at version
  def atom_plugin_installed(name, version = "")
    run_cmd_no_redirect("apm list").should match("#{name}@#{version}")
  end
end