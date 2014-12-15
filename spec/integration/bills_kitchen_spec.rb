
require_relative '../helpers'

describe "bills kitchen" do

  include Helpers

  describe "tools" do
    it "installs ChefDK 0.3.5" do
      run_cmd("chef -v").should match('Chef Development Kit Version: 0.3.5')
    end
    it "installs Vagrant 1.7.1" do
      run_cmd("vagrant -v").should match('1.7.1')
    end
    it "installs Terraform 0.3.5" do
      run_cmd("terraform --version").should match('0.3.5')
    end
    it "installs Packer 0.7.5" do
      run_cmd("packer version").should match('0.7.5')
    end
    it "installs Consul 0.4.1" do
      run_cmd("consul --version").should match('0.4.1')
    end
    it "installs ssh.exe" do
      run_cmd("ssh -V").should match('OpenSSH_6.0p1, OpenSSL 1.0.1c 10 May 2012')
    end
    it "installs rsync.exe" do
      run_cmd("rsync --version").should match('rsync  version 3.0.9')
    end
    it "installs Git 1.9" do
      run_cmd("git --version").should match('git version 1.9.4')
    end
    it "installs kdiff3" do
      marker_file = "#{BUILD_DIR}/merged.md"
      begin
        run_cmd("kdiff3 README.md README.md --auto -cs LineEndStyle=0 -o #{marker_file}")
        File.exist?(marker_file).should be true
      ensure
        File.delete(marker_file) if File.exist?(marker_file)
      end
    end
    it "installs clink 0.4.2" do
      run_cmd("#{BUILD_DIR}/tools/clink/clink.bat version").should match('Clink v0.4.2')
    end
  end

  describe "environment" do
    it "sets HOME to W:/home" do
      env_match "HOME=#{BUILD_DIR}/home"
    end
    it "sets VAGRANT_HOME to W:/home/.vagrant.d" do
      env_match "VAGRANT_HOME=#{BUILD_DIR}/home/.vagrant.d"
    end
    it "sets VBOX_USER_HOME to %USERPROFILE%" do
      env_match "VBOX_USER_HOME=#{ENV['USERPROFILE']}"
    end
    it "sets TERM=cygwin" do
      env_match "TERM=cygwin"
    end
    it "sets ANSICON=true" do
      env_match "ANSICON=true"
    end
    it "sets SSL_CERT_FILE to W:/home/cacert.pem" do
      env_match "SSL_CERT_FILE=#{BUILD_DIR}/home/cacert.pem"
    end
  end

  describe "aliases" do
    it "aliases `bundle exec` to `be`" do
      run_cmd("doskey /macros").should match('be=bundle exec $*')
    end
    it "aliases `sublime_text` to `vi`" do
      run_cmd("doskey /macros").should match('vi=START \"Sublime Text 2\" sublime_text $*')
    end
  end

  describe "ruby installations" do

    describe "chefdk as the primary ruby" do
      it "provides the default `ruby` command" do
        run_cmd("which ruby").should match(convert_slashes("#{CHEFDK_RUBY}/bin/ruby.EXE"))
      end
      it "provides the default `gem` command" do
        run_cmd("which gem").should match(convert_slashes("#{CHEFDK_RUBY}/bin/gem"))
      end
    end

    describe "chefdk ruby" do
      it "installs Chef 11.18.0.rc.1" do
        run_cmd("knife -v").should match('Chef: 11.18.0.rc.1')
      end
      it "uses the ChefDK embedded gemdir" do
        run_cmd("#{CHEFDK_RUBY}/bin/gem environment gemdir").should match("#{CHEFDK_RUBY}/lib/ruby/gems/2.0.0")
      end
      it "does NOT install gems into $HOME/.chefdk" do
        gem_env = run_cmd("#{CHEFDK_RUBY}/bin/gem environment")
        gem_env.should match('"update" => "--no-user-install"')
        gem_env.should match('"install" => "--no-user-install"')
        Dir["#{CHEFDK_HOME}/gem/ruby/2.0.0/"].should be_empty
      end
      it "has ChefDK verified to work via `chef verify`" do
        cmd_succeeds "chef verify"
      end
      it "has 'bundler (1.7.5)' gem installed" do
        gem_installed "bundler", "1.7.5"
      end
      it "has 'knife-audit (0.2.0)' plugin installed" do
        knife_plugin_installed "knife-audit", "0.2.0"
      end
      it "has 'knife-server (1.1.0)' plugin installed" do
        knife_plugin_installed "knife-server", "1.1.0"
      end
    end

    describe "vagrant ruby" do
      it "uses the vagrant embedded gemdir" do
        run_cmd("#{VAGRANT_RUBY}/bin/gem environment gemdir").should match("#{VAGRANT_RUBY}/lib/ruby/gems/2.0.0")
      end
      it "has 'vagrant-toplevel-cookbooks (0.2.2)' plugin installed" do
        vagrant_plugin_installed "vagrant-toplevel-cookbooks", "0.2.2"
      end
      it "has 'vagrant-omnibus (1.4.1)' plugin installed" do
        vagrant_plugin_installed "vagrant-omnibus", "1.4.1"
      end
      it "has 'vagrant-cachier (1.1.0)' plugin installed" do
        vagrant_plugin_installed "vagrant-cachier", "1.1.0"
      end
      it "has 'vagrant-berkshelf (3.0.1)' plugin installed" do
        vagrant_plugin_installed "vagrant-berkshelf", "3.0.1"
      end
    end
  end
end