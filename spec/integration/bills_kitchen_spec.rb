
require_relative '../helpers'

describe "bills kitchen" do

  include Helpers

  describe "tools" do
    it "installs Ruby 2.0.0p451" do
      run_cmd("ruby -v").should match('1.9.3p545')
    end
    it "installs RubyGems 2.0.14" do
      run_cmd("gem -v").should match("1.8.28")
    end
    it "installs Chef 11.10.4" do
      run_cmd("knife -v").should match('Chef: 11.10.4')
    end
    it "installs Vagrant 1.3.5" do
      run_cmd("vagrant -v").should match('1.3.5')
    end
    it "installs ssh.exe" do
      run_cmd("ssh -V").should match('OpenSSH_6.0p1, OpenSSL 1.0.1c 10 May 2012')
    end
    it "installs rsync.exe" do
      run_cmd("rsync --version").should match('rsync  version 3.0.9')
    end
    it "installs Git 1.9" do
      run_cmd("git --version").should match('git version 1.9.0')
    end
    it "installs kdiff3" do
      marker_file = "#{BUILD_DIR}/merged.md"
      begin
        run_cmd("kdiff3 README.md README.md --auto -o #{marker_file}")
        File.exist?(marker_file).should be_true
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
    it "sets TERM=rxvt" do
      env_match "TERM=rxvt"
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
      run_cmd("doskey /macros").should match('vi=sublime_text $*')
    end
  end

  describe "ruby installations" do

    describe "system ruby" do
      it "provides the default `ruby` command" do
        run_cmd("which ruby").should match(convert_slashes("#{SYSTEM_RUBY}/bin/ruby.EXE"))
      end
      it "provides the default `gem` command" do
        run_cmd("which gem").should match(convert_slashes("#{SYSTEM_RUBY}/bin/gem"))
      end
      it "uses the system ruby gemdir" do
        run_cmd("#{SYSTEM_RUBY}/bin/gem environment gemdir").should match("#{SYSTEM_RUBY}/lib/ruby/gems/1.9.1")
      end
      it "has 'bundler (1.5.3)' gem installed" do
        gem_installed "bundler", "1.5.3"
      end
    end

    describe "omnibus ruby" do
      it "uses the omnibus embedded gemdir" do
        run_cmd("#{OMNIBUS_RUBY}/bin/gem environment gemdir").should match("#{OMNIBUS_RUBY}/lib/ruby/gems/1.9.1")  
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
        run_cmd("#{VAGRANT_RUBY}/bin/gem environment gemdir").should match("#{VAGRANT_RUBY}/lib/ruby/gems/1.9.1")  
      end
      it "has 'bindler (0.1.3)' plugin installed" do
        vagrant_plugin_installed "bindler", "0.1.3"
      end
    end
  end
end