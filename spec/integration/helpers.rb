
BUILD_DIR=File.expand_path('./target/build')
SYSTEM_RUBY = "#{BUILD_DIR}/tools/ruby-2.0.0"
OMNIBUS_RUBY = "#{BUILD_DIR}/tools/chef/opscode/chef/embedded"
VAGRANT_RUBY = "#{BUILD_DIR}/tools/vagrant/HashiCorp/Vagrant/embedded"

module Helpers
  # sets the environment via set-env.bat before running the command
  def run_cmd(cmd)
    `"#{BUILD_DIR}/set-env.bat" >NUL && #{cmd} 2>&1`
  end
  # similar to #run_cmd, but uses system and returns the exit code
  def system_cmd(cmd)
    system "#{BUILD_DIR}/set-env.bat >NUL && #{cmd}"
  end
  # converts the path to using backslashes
  def convert_slashes(path)
    path.gsub('/', '\\').gsub('\\', '\\\\\\\\') #eek
  end
  # checks if the given line is contained in the environment
  def env_match(line)
    run_cmd("set").should match(/^#{convert_slashes(line)}$/)
  end
  # checks if the given gem is installed at version
  def gem_installed(name, version, gem_cmd = "#{SYSTEM_RUBY}/bin/gem")
    run_cmd("#{gem_cmd} list").should match("#{name} \\(#{version}\\)")
  end  
  # checks if the given gem is installed at version
  def knife_plugin_installed(name, version)
    gem_installed name, version, "#{OMNIBUS_RUBY}/bin/gem"
  end
  # checks if the given gem is installed at version
  def vagrant_plugin_installed(name, version)
    run_cmd("vagrant plugin list").should match("#{name} \\(#{version}\\)")
  end
end