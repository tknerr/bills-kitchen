
# [0.6-SNAPSHOT]
  
  * ...

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