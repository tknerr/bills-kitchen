
require_relative '../integration/helpers'

describe "usage scenarios" do

  include Helpers

  REPO_DIR = "#{BUILD_DIR}/repo"
  APP_COOKBOOK_DIR = "#{REPO_DIR}/sample-application-cookbook"
  INFRA_REPO_DIR = "#{REPO_DIR}/sample-infrastructure-repo"
  BASEBOX = "opscode_ubuntu-13.04_provisionerless"


  def local_box_available?(box)
    File.exist? "#{BUILD_DIR}/boxes/#{box}.box"
  end

  def box_imported?(box)
    run_cmd("vagrant box list").include?(box)
  end



  before(:all) do
    # import basebox if exists to prevent download
    if local_box_available?(BASEBOX) && !box_imported?(BASEBOX)
      cmd_succeeds("vagrant box add #{BASEBOX} file://#{BUILD_DIR}/boxes/#{BASEBOX}.box")
    end
    # remove repos
    require 'fileutils'
    FileUtils.rm_rf APP_COOKBOOK_DIR
    FileUtils.rm_rf INFRA_REPO_DIR
  end

  describe "managing base boxes" do
    it "imports a local basebox (if exists)" do
      # TODO: keep this?
    end
  end

  describe "developing application cookbooks" do
    it "clones an application cookbook via `git clone`" do
      cmd_succeeds("cd #{REPO_DIR} && git clone https://github.com/tknerr/sample-application-cookbook.git")
    end
    it "installs gem dependencies via `bundle exec`" do
      cmd_succeeds("cd #{APP_COOKBOOK_DIR} && bundle install")
    end
    it "runs the unit tests via `rake test`" do
      cmd_succeeds("cd #{APP_COOKBOOK_DIR} && rake test")
    end
    it "runs the integration tests via `rake integration`" do
      cmd_succeeds("cd #{APP_COOKBOOK_DIR} && rake integration")
    end
  end

  describe "managing infrastructure" do
    it "clones an infrastructure repo via `git clone`" do
      cmd_succeeds("cd #{REPO_DIR} && git clone https://github.com/tknerr/sample-infrastructure-repo.git")
    end
    it "installs vagrant plugin dependencies via `vagrant plugin bundle`" do
      cmd_succeeds("cd #{INFRA_REPO_DIR} && vagrant plugin bundle")
    end
    it "brings up a VM via `vagrant up`" do
      cmd_succeeds("cd #{INFRA_REPO_DIR} && vagrant up app_v2")
    end
    it "can talk to that VM via `vagrant ssh`" do
      run_cmd("cd #{INFRA_REPO_DIR} && vagrant ssh app_v2 -c 'pwd'").should match("/home/vagrant")
    end
    it "can provision a VM via `vagrant provision`" do
      cmd_succeeds("cd #{INFRA_REPO_DIR} && vagrant provision app_v2")
    end
    it "can destroy a VM via `vagrant destroy`" do
      cmd_succeeds("cd #{INFRA_REPO_DIR} && vagrant destroy -f app_v2")
    end
  end
end