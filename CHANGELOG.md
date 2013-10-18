
# [1.0-SNAPSHOT] - unreleased

 * set `ANSICON` env var so that Vagrant uses colored output on Windows
 * update to Chef 11.6.2
 * update to Vagrant 1.3.5

# [1.0.0.alpha3] from 10/05/2013

 * enable caching of omnibus packages [via custom install.sh](https://github.com/fgrehm/vagrant-cachier/issues/13#issuecomment-25320554)
 * remove all pre-installed vagrant-plugins in favor of [bindler](https://github.com/fgrehm/bindler)
 * remove all pre-installed gems (except chef and some knife plugins) and `W:\Gemfile` in favor of project-specific Gemfiles
 * tool updates:
  * updated Vagrant to 1.3.4


# [1.0.0.alpha2] from 07/15/2013

 * added ~/.ssh/chef-tlc-insecure.pub key (this is just a common and insecure public/private key pair for testing)
 * tool updates:
  * updated Vagrant to 1.2.3
  * updated Sublime Text to 2.0.2
  * updated PortableGit to 1.8.3
 * Vagrant plugin updates:
  * updated vagrant-cachier to 0.2.0
  * updated vagrant-berkshelf to 1.3.3 

# [1.0.0.alpha1 (unpublished)]
 
 * switch to SemVer versioning scheme for bills-kitchen, target 1.0 release soon
 * updated to **Vagrant 1.2**, **Chef 11** and **Berkshelf** (see below for details)
 * updated to Vagrant 1.2.2 with the following plugins pre-installed:
  * [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier) 0.1.0
  * [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus) 1.0.2
  * [vagrant-aws](https://github.com/tknerr/vagrant-aws/tree/fix-rsync-on-windows) 0.2.2.rsyncfix (with fix for rsync on windows)
  * [vagrant-managed-servers](https://github.com/tknerr/vagrant-managed-servers) 0.1.0
  * [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) 0.8.0
  * [vagrant-plugin-bundler](https://github.com/tknerr/vagrant-plugin-bundler) 0.1.1
  * [vagrant-berkshelf](https://github.com/riotgames/vagrant-berkshelf) 1.2.0
 * updated [chef-tlc-workflow](https://github.com/tknerr/chef-tlc-workflow) to v0.3.0: 
  * supports Vagrant 1.2
  * supports Chef 11
  * replaces librarian-chef with [Berkshelf](http://berkshelf.com) (v2.0.4)
  * replaces mccloud and knife-solo with [vagrant-aws](https://github.com/mitchellh/vagrant-aws) and [vagrant-managed-servers](https://github.com/tknerr/vagrant-managed-servers)
 * other Gem updates:
  * updated bundler to v1.3.5
  * removed cucumber-nagios due to gem conflict
  * added [test-kitchen](https://github.com/opscode/test-kitchen) v1.0.0.alpha.7
 * moved Ruby installation to `W:\tools\ruby-1.9.3`
 * added `chef-tlc-insecure-key` keypair akin to Vagrant's `insecure_private_key`

# [0.10] from 05/30/2013

 * clean up `Gemfile` and start using [chef-tlc-workflow](https://github.com/tknerr/chef-tlc-workflow) which transitively brings in the chef-related dependencies
 * updated to latest 1.9 Ruby version 1.9.3-p429
 * updated ConEmu to v130526 which fixes swallowing keystrokes (issue [#1004](https://code.google.com/p/conemu-maximus5/issues/detail?id=1004))
 * handle case when vagrant-vbguest is not in the load path (e.g. when using `bundle exec`) more gracefully
 * gem updates:
  * removed test-kitchen 0.7.0 for now while it conflicts with librarian-chef
  * updated to renamed librarian-chef 0.0.1
  * updated knife-solo to 0.3.0.pre4
  * updated mccloud to 0.0.19

# [0.9] from 26/03/2013

 * added minimal integration test on travis-ci checking for conflicts in Bill's Kitchen Gemfile
 * added `rake backup` task for creating a backup of the target/build dir (thanks @ilude)
 * GH-21: replaced Console2 + ansicon with [ConEmu](http://code.google.com/p/conemu-maximus5/)
 * GH-20: replaced Vagrant embedded Ruby + [TCS patch](https://github.com/thecodeshop/ruby/wiki/Downloads) with latest MRI Ruby (1.9.3.p392) + DevKit (4.5.2)
 * added command alias `be` for `bundle exec`
 * gem updates:
  * added [knife-audit](https://github.com/jbz/knife-audit) 0.2.0 for introspecting the complete run_list
  * added [chef-workflow](https://github.com/chef-workflow/chef-workflow) tasklib and testlib 0.2.0
  * updated knife-server to 0.3.3
  * updated knife-solo to 0.3.0.pre2 (patches now merged in upstream version)
  * updated mccloud to 0.0.18 (patches now merged in upstream version)
  * updated foodcritic to 0.7.0
  * updated berkshelf to 1.3.1
  * updated chef-workflow-tasklib to 0.2.2
  * updated chef to 10.18.2 (last 10.x version which is compatible with vagrant 1.0.x, i.e. no net-ssh conflict)


# [0.8.1] from 04/12/2012

 * use patched Ruby 1.9.3 with >50% load time improvements from [thecodeshop](https://github.com/thecodeshop/ruby/wiki/Downloads)
 * gem updates:
  * updatet test-kitchen to 0.7.0 release version 

# [0.8] from 02/12/2012

 * prompt for .gitconfig username and email the first time `set-env` is called
 * re-enable vagrant-vbguest plugin with guest addition updates disabled by default
 * add powershell set-env.ps1 variant of set-env.bat (thanks @ilude) 
 * add http redirect handling for downloads (thanks @ilude)
 * gem updates:
  * added knife-solo_data_bag 0.3.0 (knife plugin for managing data bags with chef_solo)
  * added berkshelf 1.0.4 (cookbook dependency management alternative to librarian)
  * updated librarian to upstream version 0.0.25 (with http proxy support)
  * updated chef gem to 10.16.2
  * updated veewee gem to 0.3.1 (thanks @ilude)
  * updated chefspec to 0.9.0
  * updated fauxhai to 0.0.4
  * updated test-kitchen to 0.7.0.beta.1
  * updated vagrant-vbguest to 0.5.1


# [0.7] from 08/10/2012
 
 * GH-1: set up chef server from scratch (using knife-server) rather than having it in a pre-baked basebox, updated GETTING_STARTED guide 
 * update to latest Chef release 10.14.4
 * use latest bundler version 1.2.1
 * gem updates:
  * added knife-server 0.3.0 for bootstrap/backup/restore of chef server
  * added vagrant-vbguest 0.3.5 to keep the guestadditions in sync with your virtualbox installation
  * updated vagrant to 1.0.5.1
  * updated chef to 10.14.4
  * updated chefspec to 0.8.0
  * updated fauxhai to 0.0.3
  * updated test-kitchen to 0.6.0
  * updated veewee to 0.3.0.beta2


# [0.6] from 29/08/2012
 
 * added COOKBOOK_DEVELOPMENT guide for test-driven cookbook development with foodritic, chefspec, fauxhai, vagrant, librarian, minitest-chef-handler and cucumber-nagios
 * added recent version of cygwin rsync.exe and ssh.exe
 * gem updates:
 	* added testing gems:
 		* test-kitchen 0.5.2 as the holistic test runner
 		* chefspec 0.7.0 for fast-running spec tests
 		* fauxhai 0.0.2 for mocking ohai attributes
 		* cucumber-nagios 0.9.2.1 for cucumber acceptance testing
 	* added mccloud 0.0.13.1 for cloud deployments
 	* updated vagrant to 1.0.3.1
 	* updated sahara to 0.0.13 (patches now merged in upstream version)
 	* updated knife-solo to latest version (now much faster using rsync.exe) 0.0.13.1
 	* added faster_require gem for reducing startup times 
 * bugfixes:
   * GH-7: TERM=msys breaks vagrant ssh terminal
   * GH-6: "This build of Sublime Text 2 has expired..."
   * GH-5: rake install fails due to missing gems 

# [0.5.1] from 16/07/2012
  
 * added putty to tools
 * added knife-solo gem (patched for windows)
 * better http proxy support: updated librarian gem (proxy patch), setting proxy in .gitconfig
 
# [0.5] from 27/06/2012

 * check out 'bills-kitchen-0.5_branch' after clone for dependent repositories
 * fixed devkitvars not being set causing problems with compiling native gems
 * renamed chef-devpack to bill's kitchen

# [0.4] from 08/06/2012 
 
 * switched to 7z packaging greatly reducing filesize
 * updated Vagrantfiles to use public basebox URLs
 * removed notepad++ as we don't need two editors 
 * replaced p4merge with more lightweight kdiff3
 * added support for colored shell output in Console2 via `ansicon`
 * devpack is now built from source: https://github.com/tknerr/bills-kitchen

# [0.3] from 18/05/2012

 * added `my-baseboxes` project which builds our baseboxes using veewee 
 * updated baseboxes and docs for Ubuntu 12.04 and Chef 0.10.10
 * added `Gemfile` for managing the gems we need in the DevPack
 * added git submodules for `my-chef-repo`, cookbooks in `my-cookbooks` 
 * added sublime text editor with chef code completion

# [0.2] from 11/05/2012

 * devpack is now version controlled using git and pushed to github
 * devpack zip file is now created via Rake task
 * removed VirtualBox installer and Vagrant .boxes to from zip file
 * added documentation links and OpsCode training materials
 * rewrote `README`, `GETTING_STARTED` and `GUIDE` documentation, generating HTML from Markdown
 * added `Console2` as an alternative to `cmd`
 * installed librarian gem to manage cookbook dependencies with `librarian-chef`
 * added `role[webserver]` to chef repository
 
# [0.1] from 20/04/2012

initial version, distributed as a manually packaged zip file