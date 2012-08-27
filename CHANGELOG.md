
# [0.6-SNAPSHOT]
 
 * added `COOKBOOK_DEVELOPMENT` guide
 * added recent version of cygwin rsync.exe and ssh.exe
 * gem updates:
 	* added testing gems:
 		* test-kitchen 0.5.2 as the holistic test runner
 		* chefspec 0.7.0 for fast-running spec tests
 		* fauxhai 0.0.2 for mocking ohai attributes
 		* cuken 0.1.22.1 for cucumber acceptance tests (replacing cucumber-nagios)
 	* added mccloud 0.0.13.1 for cloud deployments
 	* updated vagrant to 1.0.3.1
 	* updated sahara to 0.0.13 (patches now merged in upstream version)
 	* updated knife-solo to latest version (now much faster using rsync.exe) 0.0.13.1
 	* added [faster_require](https://github.com/rdp/faster_require) gem for reducing startup times 
 
 * bugfixes:
   * GH-7: TERM=msys breaks `vagrant ssh` terminal
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
 * devpack is now built from source: https://github.com/tknerr/chef-devpack

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