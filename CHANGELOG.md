
# 3.0-SNAPSHOT (unreleased)

 * improvements:
   * make sure the chef omnibus installer is cached during test-kitchen runs
   * make sure the chef `file_cache_path` is cached during test-kitchen runs 


# 3.0-rc6 (Sept 7, 2015)

 * tool updates:
   * update to ConEmu 20150728
   * update to Atom 1.0.9
   * update to Consul 0.5.2
   * update to Terraform 0.6.3
   * update to Packer 0.8.6
   * update to Docker 1.7.1
   * update to Vagrant 1.7.4
   * update to ChefDK 0.7.0
   * update to PortableGit 2.5.0 (aka "Git for Windows")
 * plugin updates:
   * update to vagrant-cachier 1.2.1 (with chef-zero support)
   * update to vagrant-proxyconf 1.5.1
 * bug fixes:
   * ensure that the vagrant remote docker host patch is always enabled (see [#114](https://github.com/tknerr/bills-kitchen/issues/114))
   * get the actual remote docker host ip address from the `DOCKER_HOST` env var instead of using a hard coded default (see [#130](https://github.com/tknerr/bills-kitchen/pull/130))
   * fix detection of the forwarded ssh port when multiple remote docker containers are started (see [#130](https://github.com/tknerr/bills-kitchen/pull/130))
 * improvements:
   * allow to run acceptance tests using either virtualbox or docker provider
 * patches:
   * update the ChefDK included bundler to 1.10.6 (and [temporarily patched Vagrant](https://github.com/test-kitchen/kitchen-vagrant/issues/190#ref-commit-1176eca)) so we can benefit from the [bugfix](https://github.com/bundler/bundler/issues/3799) which makes parallel downloading work again


# 3.0-rc5 (May 17, 2015)

 * tool updates:
   * update to Terraform 0.5.2
   * update to Consul 0.5.1
   * update to ChefDK 0.6.0
   * update to Docker 1.6.2
   * update to boot2docker-cli 1.6.2
   * update to Atom 0.199.0 (which [now bundles autocomplete-plus](http://blog.atom.io/2015/05/15/new-autocomplete.html))
 * plugin updates:
   * update vagrant-berkshelf to 4.0.4
   * added new vagrant plugin: vagrant-winrm 0.7.0 (useful when setting up windows boxes)
 * bug fixes:
   * fix docker volume mounts when using remote docker hosts in Vagrant (see [#107](https://github.com/tknerr/bills-kitchen/pull/107))
   * fix remote docker host support in multi-machine setups (see [#110](https://github.com/tknerr/bills-kitchen/pull/110))
   * fix build process error that occurs when `rake[recreate_dirs]` is run initially with an empty build directory (see [9ea200d](https://github.com/tknerr/bills-kitchen/commit/9ea200d75c22c405af9352e08b898fe31602ccb1), thanks @aderenbach for reporting)
 * improvements:
   * fix spelling errors in set-env.bat comments (see [#108](https://github.com/tknerr/bills-kitchen/pull/108), thanks @xBytez)

# 3.0-rc4 (May 5, 2015)

 * bug fixes:
   * fix several issues which essentially rendered the `b2d-start` script unusable (see [#104](https://github.com/tknerr/bills-kitchen/issues/104), thanks @alfert for reporting!)
   * re-packaging as the git user was not correctly reset in 3.0-rc3 (see [#103](https://github.com/tknerr/bills-kitchen/issues/103), thanks @alfert for reporting!)

# 3.0-rc3 (May 4, 2015)

 * tool updates:
   * update to ChefDK 0.5.1
   * update to Atom 0.196.0
 * new plugins and scripts:
   * add the [vagrant-proxyconf](https://github.com/tmatilai/vagrant-proxyconf) plugin for configuring the proxy inside vagrant VMs (see [#102](https://github.com/tknerr/bills-kitchen/pull/102))
   * add `proxy-on.bat` and `proxy-off.bat` convenience scripts for setting the proxy env vars (see [#102](https://github.com/tknerr/bills-kitchen/pull/102))
 * improvements:
   * init the shell for docker in the `set-env` scripts rather than in `b2d-start.bat`
   * mount the bill's kitchen root directory (`%BK_ROOT%`) under the same path into the boot2docker VM so that docker volume mounts work
   * make the `b2d-start.bat` and `b2d-stop.bat` scripts more resilient
   * add `b2d` shortcut doskey alias for `boot2docker`
   * add `GLOBAL_VAGRANT_CACHIER_DISABLED` env var to allow for disabling vagrant-cachier in the global Vagrantfile ([#98](https://github.com/tknerr/bills-kitchen/pull/98))
   * patch vagrant with remote docker host support; conditionally enable it `b2d-start` and disable it in `b2d-stop` (experimental, see [#100](https://github.com/tknerr/bills-kitchen/pull/100))
 * bug fixes:
   * make `bundle` and other gem binaries work in `git-bash` too [#97](https://github.com/tknerr/bills-kitchen/issues/97)

# 3.0-rc2 (April 20, 2015)

 * new tools:
  * added boot2docker-cli 1.6.0
  * added docker client 1.6.0
  * added `b2d-start.bat` and `b2d-stop.bat` for setting up the Docker environment (see [#95](https://github.com/tknerr/bills-kitchen/pull/95))
 * tool updates:
  * update to Terraform 0.4.2
  * update to PortableGit 1.9.5-preview20150319
  * update to ConEmu 20150416
  * update to Atom 0.192.0
  * update to ChefDK 0.5.0-rc.5
  * update to Ruby 2.1.5 (ships with ChefDK above)
  * remove the included cygwin-based ssh and rsync executables in favor or [cwRsync](https://www.itefix.net/content/cwrsync-free-edition) 5.4.1
 * bug fixes:
  * use plain HTTP for parallel downloading of bundled gems to circumvent [bundler/bundler#3545](https://github.com/bundler/bundler/issues/3545)
  * make rsync-based synced folders work: use cwRsync and patch vagrant (see [#92](https://github.com/tknerr/bills-kitchen/issues/92), thanks @djmittens for reporting)



# 3.0-rc1 (April 1, 2015)

This is considered a major release mostly because it replaces SublimeText with
Atom editor (see below). Apart from that breaking change there are quite a few
tool updates and some minor improvements.

 * tool updates:
  * update to ChefDK 0.5.0-rc.2
  * update to Terraform 0.3.7
  * update to Consul 0.5.0
  * update to ConEmu 20150305
  * update to clink 0.4.4
 * vagrant plugin updates:
  * update to vagrant-toplevel-cookbooks 0.2.4
  * update to vagrant-berkshelf 4.0.3
 * improvements:
  * cache busser gems only during test-kitchen runs and add compatibility with test-kitchen 1.4 (see [#78](https://github.com/tknerr/bills-kitchen/pull/78))
  * fix remaining hardcoded references to "C:\opscode\.." in ChefDK, allowing to use the ChefDK binaries from within `git-bash` (see [#87](https://github.com/tknerr/bills-kitchen/pull/87))
  * add `git-bash.bat` to the PATH so it is easier accessible (see [#85](https://github.com/tknerr/bills-kitchen/issues/85), thanks @paul42 for the suggestion)

**Please note:** SublimeText has been replaced by [Atom](https://atom.io/) (see [#67](https://github.com/tknerr/bills-kitchen/issues/67)):

 * remove SublimeText2 editor in favor of atom 0.188.0
 * this removes the only licensed / non open source component!
 * preinstalled some useful plugins:
  * `sublime-tabs` - sublime like tab behaviour
  * `atom-beautify` - multi-language beautifier framework (codestyle, indentation, etc.)
  * `minimap` - sublime like minimap navigation
  * `line-ending-converter` - convert between line ending styles
  * `language-chef` - chef specific syntax highlighting and snippets (see here [how to enable it](https://github.com/darron/language-chef/issues/3#issuecomment-87335835))
  * `language-batchfile` - syntax higlighting for .bat files
  * `autocomplete-plus` - for better auto-completion
  * `autocomplete-snippets` - to enable auto-completion for snippets

# 2.3 (January 23, 2015)

 * tool updates:
  * update to ChefDK 0.3.6
 * improvements:
  * mimic `chef shell-init` behaviour by setting env vars accordingly
  * user installed gems will be installed to `$HOME/.chefdk` again (see [#71](https://github.com/tknerr/bills-kitchen/pull/71))
  * update packaging to that it does not include the intermediary build directory anymore ([#63](https://github.com/tknerr/bills-kitchen/issues/63))

# 2.2 (January 18, 2015)

 * improvements:
  * cache busser gems via vagrant-cachier for faster test-kitchen runs
  * no longer downgrading the ChefDK bundler because vagrant 1.7 is now compatible with bundler 1.7.5 again
  * make `bundle install` faster and more reliable via `%BUNDLE_JOBS%` and `%BUNDLE_RETRY%`
 * bug fixes:
  * fix invalid syntax (trailing comma) in `Default (Windows).sublime-keymap` file
 * tool updates:
  * update to vagrant 1.7.2
  * update to PortableGit 1.9.5-preview20141217 (fixes [security vulnerability](https://github.com/blog/1938-vulnerability-announced-update-your-git-clients))
 * vagrant plugin updates:
  * update to vagrant-toplevel-cookbooks 0.2.3 (fixes some Vagrant 1.7 incompatibilities)
  * update to vagrant-berkshelf 4.0.2
  * update to vagrant-cachier 1.2.0
 * new tools:
  * added terraform 0.3.6
  * added packer 0.7.5
  * added consul 0.4.1

# 2.1 (November 19, 2014)

 * improvements:
  * mute the cygwin warning that comes on `vagrant ssh` (via `set CYGWIN=nodosfilewarning`)
  * removed the outdated chef-tlc-insecure keypair from `%HOME%\.ssh`
  * removed empty `W:\boxes` directory
  * using [Soda Dark](https://sublime.wbond.net/packages/Theme%20-%20Soda) theme with modified "Blackboard" color scheme in Sublime Text
  * added license information and acknowledgements
  * added putty compatible version of vagrant insecure key (`%HOME%\.vagrant.d\insecure_private_key.ppk`) for convenience
  * add `%VBOX_MSI_INSTALL_PATH%` to the PATH (in addition to `%VBOX_INSTALL_PATH%`) since the env var [has changed](https://github.com/mitchellh/vagrant/issues/3852) with VirtualBox 4.3.12
  * ChefDK specific fixes and adaptations:
    * fix path to ruby.exe in .bat files so ChefDK can live outside of `C:\opscode` (see [opscode/chef-dk#68](https://github.com/opscode/chef-dk/issues/68))
    * ensure that gems are always installed in the ChefDK embedded Ruby, not in `$HOME/.chefdk`
    * downgrade to bundler 1.6.7 for [compatibility with Vagrant 1.6.5](https://github.com/opscode/chef-dk/issues/218#issuecomment-63271238)
 * bug fixes:
  * make `vagrant ssh` terminal fully functional again (e.g. `vim` and `top` were broken) ([#64](https://github.com/tknerr/bills-kitchen/issues/64))
 * tool updates:
  * update to vagrant-cachier 1.1.0 (and remove earlier workaround for [fgrehm/vagrant-cachier#113](https://github.com/fgrehm/vagrant-cachier/issues/113))
  * update to vagrant-berkshelf 3.0.1
  * update to vagrant 1.6.5
  * update to ChefDK 0.3.5
  * update to PortableGit 1.9.4-preview20140929
  * update to ConEmu 141110

# 2.0 (July 17, 2014)

 * tool updates:
  * update to ConEmu 140707
  * update to ChefDK 0.2.0
 * Improve Sublime Text experience ([#59](https://github.com/tknerr/bills-kitchen/issues/59))
  * use [Package Control](https://sublime.wbond.net/) package manager
  * syntax highlighting for [Chef](https://sublime.wbond.net/packages/Chef) and [Cucumber](https://sublime.wbond.net/packages/Cucumber) preinstalled
  * [Terminal](https://sublime.wbond.net/packages/Terminal), [GitGutter](https://sublime.wbond.net/packages/GitGutter), [Shell Turtlestein](https://sublime.wbond.net/packages/Shell%20Turtlestein) and [Ruby Debugger](https://sublime.wbond.net/packages/Ruby%20Debugger) packages preinstalled
 * no longer shipping MONACO.TTF font (was dropped in favor of Consolas earlier)

# 2.0.rc2 (July 17, 2014)

 * extracted the [workflow acceptance tests](https://github.com/tknerr/vagrant-workflow-tests) into a separate project
 * use 32-bit binaries (SublimeText, ConEmu) so it can be used on 32-bit Windows as well
 * bugfixes:
  * re-enable vagrant-cachier in global Vagrantfile again, working around [fgrehm/vagrant-cachier#113](https://github.com/fgrehm/vagrant-cachier/issues/113)

# 2.0.rc1 (July 17, 2014)

 * tool updates:
  * add clink for command autocompletion ([#55](https://github.com/tknerr/bills-kitchen/issues/55)) (disabled)
  * remove separate Ruby and Omnibus Chef installations in favor of [Chef-DK](http://www.getchef.com/downloads/chef-dk/windows/)
  * Chef-DK embedded Ruby 2.0.0p451 (x86) [is now the primary Ruby](http://jtimberman.housepub.org/blog/2014/04/30/chefdk-and-ruby/)
  * update to DevKit 4.7.2 (x86), compatible with Chef-DK Ruby 2.x
  * update to Vagrant 1.6.3 and pre-install common plugins (no [bindler](https://github.com/fgrehm/bindler) anymore :-(, see below)
 * vagrant plugin updates:
  * install [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus) globally (v1.4.1)
  * install [vagrant-berkshelf](https://github.com/berkshelf/vagrant-berkshelf) globally (v2.0.1)
  * install [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier) globally (v0.7.2)
 * bugfixes:
  * fix setting git username ([#56](https://github.com/tknerr/bills-kitchen/issues/56))
  * start ConEmu at the root of the mounted drive now (`W:\` instead of `W:\tools\conemu\`)
  * use Consolas as the default font for ConEmu rather than Monaco (not included in Win7)
 * improvements:
  * made it easier to change the mount drive letter ([#57](https://github.com/tknerr/bills-kitchen/issues/57))
  * enable vagrant-cachier globally via `~/.vagrant.d/Vagrantfile` (disabled due to [fgrehm/vagrant-cachier#113](https://github.com/fgrehm/vagrant-cachier/issues/113))

# 1.0 (March 19, 2014)

 * set `ANSICON` env var so that Vagrant uses colored output on Windows
 * add up-to-date CA certs and set `SSL_CERT_FILE` ([#45](https://github.com/tknerr/bills-kitchen/issues/45))
 * add Vagrant's embedded dir to the `PATH` ([#46](https://github.com/tknerr/bills-kitchen/pull/46))
 * remove custom `OMNIBUS_INSTALL_URL` now that the official one supports caching (see opscode/opscode-omnitruck#33)
 * tool updates ([#43](https://github.com/tknerr/bills-kitchen/pull/43)):
  * update to Ruby 1.9.3p545
  * update to Vagrant 1.3.5
  * update to Omnibus Chef 11.10.4 (in favor of gem install)
  * update to ConEmu 140304
  * update to PortableGit 1.9.0-preview
  * update to putty 0.63
  * remove hostsedit (unused leftover)
 * gem updates ([#43](https://github.com/tknerr/bills-kitchen/pull/43)):
  * update to bundler 1.5.3
  * remove pre-installed chef gem in favor of Omnibus Chef
  * install knife-audit and knife-server to Omnibus embedded Ruby
 * add automated testing ([#4](https://github.com/tknerr/bills-kitchen/issues/4))
  * add integration tests that run during `rake build` ([#47](https://github.com/tknerr/bills-kitchen/pull/47))
  * add acceptance tests (run `rake acceptance`) ([#49](https://github.com/tknerr/bills-kitchen/pull/49))
  * disable travis-ci since there's nothing useful we could test there (we need windows) :-(
 * documentation updates:
  * bring README up-to-date ([#44](https://github.com/tknerr/bills-kitchen/issues/44))
  * remove outdated GETTING_STARTED and COOKBOOK_DEVELOPMENT guides ([#40](https://github.com/tknerr/bills-kitchen/issues/40))
  * remove `W:\docs` with outdated doc materials and shortcuts


# 1.0.0.alpha3 (Oct 05, 2013)

 * enable caching of omnibus packages [via custom install.sh](https://github.com/fgrehm/vagrant-cachier/issues/13#issuecomment-25320554)
 * remove all pre-installed vagrant-plugins in favor of [bindler](https://github.com/fgrehm/bindler)
 * remove all pre-installed gems (except chef and some knife plugins) and `W:\Gemfile` in favor of project-specific Gemfiles
 * tool updates:
  * updated Vagrant to 1.3.4


# 1.0.0.alpha2 (July 15, 2013)

 * added ~/.ssh/chef-tlc-insecure.pub key (this is just a common and insecure public/private key pair for testing)
 * tool updates:
  * updated Vagrant to 1.2.3
  * updated Sublime Text to 2.0.2
  * updated PortableGit to 1.8.3
 * Vagrant plugin updates:
  * updated vagrant-cachier to 0.2.0
  * updated vagrant-berkshelf to 1.3.3

# 1.0.0.alpha1 (unpublished)

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

# 0.10 (May 30, 2013)

 * clean up `Gemfile` and start using [chef-tlc-workflow](https://github.com/tknerr/chef-tlc-workflow) which transitively brings in the chef-related dependencies
 * updated to latest 1.9 Ruby version 1.9.3-p429
 * updated ConEmu to v130526 which fixes swallowing keystrokes (issue [#1004](https://code.google.com/p/conemu-maximus5/issues/detail?id=1004))
 * handle case when vagrant-vbguest is not in the load path (e.g. when using `bundle exec`) more gracefully
 * gem updates:
  * removed test-kitchen 0.7.0 for now while it conflicts with librarian-chef
  * updated to renamed librarian-chef 0.0.1
  * updated knife-solo to 0.3.0.pre4
  * updated mccloud to 0.0.19

# 0.9 (March 26, 2013)

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


# 0.8.1 (Dec 04, 2012)

 * use patched Ruby 1.9.3 with >50% load time improvements from [thecodeshop](https://github.com/thecodeshop/ruby/wiki/Downloads)
 * gem updates:
  * updatet test-kitchen to 0.7.0 release version

# 0.8 (Dec 02, 2012)

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


# 0.7 (Oct 08, 2012)

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


# 0.6 (Aug 29, 2012)

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

# 0.5.1 (July 16, 2012)

 * added putty to tools
 * added knife-solo gem (patched for windows)
 * better http proxy support: updated librarian gem (proxy patch), setting proxy in .gitconfig

# 0.5 (June 27, 2012)

 * check out 'bills-kitchen-0.5_branch' after clone for dependent repositories
 * fixed devkitvars not being set causing problems with compiling native gems
 * renamed chef-devpack to bill's kitchen

# 0.4 (June 08, 2012)

 * switched to 7z packaging greatly reducing filesize
 * updated Vagrantfiles to use public basebox URLs
 * removed notepad++ as we don't need two editors
 * replaced p4merge with more lightweight kdiff3
 * added support for colored shell output in Console2 via `ansicon`
 * devpack is now built from source: https://github.com/tknerr/bills-kitchen

# 0.3 (May 18, 2012)

 * added `my-baseboxes` project which builds our baseboxes using veewee
 * updated baseboxes and docs for Ubuntu 12.04 and Chef 0.10.10
 * added `Gemfile` for managing the gems we need in the DevPack
 * added git submodules for `my-chef-repo`, cookbooks in `my-cookbooks`
 * added sublime text editor with chef code completion

# 0.2 (May 11, 2012)

 * devpack is now version controlled using git and pushed to github
 * devpack zip file is now created via Rake task
 * removed VirtualBox installer and Vagrant .boxes to from zip file
 * added documentation links and OpsCode training materials
 * rewrote `README`, `GETTING_STARTED` and `GUIDE` documentation, generating HTML from Markdown
 * added `Console2` as an alternative to `cmd`
 * installed librarian gem to manage cookbook dependencies with `librarian-chef`
 * added `role[webserver]` to chef repository

# 0.1 (April 20, 2012)

initial version, distributed as a manually packaged zip file
