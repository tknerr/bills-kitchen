
Bill's Kitchen
==============

All you (or Bill Gates would) need for cooking with Chef and Vagrant on Windows, shrink-wrapped in a portable package:

 * pre-configured Chef Repo with Vagrantfile to bring up a ready-to-use Chef Server 
 * DevKit 4.5.2 + Ruby 1.9.3.p385 (load time improvements >50%!) with lots of useful gems pre-installed:
 	* basic gems:
 		* [vagrant](http://vagrantup.com/) (patched to make `vagrant ssh` work on windows)
 		* [chef](http://www.opscode.com/chef/) (yeah you know what Chef is...)
    * [librarian](https://github.com/applicationsonline/librarian) (dependency management for cookbooks)
    * [berkshelf](https://github.com/RiotGames/berkshelf) (alternative for dependency management for cookbooks)
 	* testing-related:
 		* [foodcritic](https://github.com/acrmp/foodcritic) (linting for your cookbooks)
 		* [chefspec](https://github.com/acrmp/chefspec) (rspec examples for chef_run/cookbooks)
 		* [fauxhai](https://github.com/customink/fauxhai) (for mocking ohai attributes)
 		* [minitest-chef-handler](https://github.com/calavera/minitest-chef-handler/) (run smoke tests on the converged node)
 		* [cucumber-nagios](https://github.com/auxesis/cucumber-nagios) (cucumber steps for systems testing)
 		* [test-kitchen](https://github.com/opscode/test-kitchen) (the "holistic test runner" from Opscode)
 	* other:
    * [veewee](https://github.com/jedi4ever/veewee) (for building vagrant baseboxes)
 		* [sahara](https://github.com/tknerr/sahara) (lets you take and restore virtualbox snapshots)
    * [knife-solo](https://github.com/matschaffer/knife-solo) (if you prefer to work in chef-solo mode)
    * [knife-solo_data_bag](https://github.com/thbishop/knife-solo_data_bag) (knife data bag commands for chef-solo)
    * [knife-audit](https://github.com/jbz/knife-audit) (for introspecting the complete run_list)
    * [mccloud](https://github.com/jedi4ever/mccloud) (like vagrant but for the cloud not local vms)
    * [knife-server](https://github.com/fnichol/knife-server) (for bootstrap/backup/restore of chef servers)
    * [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) (keeps your vbox guestadditions in sync)
 * supporting tools such as:
 	* ConEmu
 	* SublimeText2 (with additional packages for Chef and Cucumber)
 	* PortableGit (preconfigured with kdiff3 as diff/merge tool)
 	* putty
 * walkthrough tutorial and example cookbooks

The only requirement for using the devpack is a recent version of [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (couldn't make that one portable).

Screenshot
==========

![Bill's Kitchen Screenshot](https://raw.github.com/tknerr/bills-kitchen/master/doc/bills_kitchen_screenshot.png) 


Installation
============

As a prerequisite for building bill's kitchen you need 7zip installed in `C:\Program Files\7-Zip\7z.exe`.

Build the kitchen (make sure you don't have spaces in the path):

```
gem install bundler
bundle install
rake build
```

This might take a while (you can go fetch a coffee). It will download the external dependencies and assemble the kitchen in the `target/build` directory, which is then packaged as `target/bills-kitchen-<version>.7z`


Usage
=====

Make sure you have  [VirtualBox](https://www.virtualbox.org/wiki/Downloads) installed, then:

1. unzip the `target/bills-kitchen-<version>.7z` somewhere
2. mount the kitchen to the `W:\` drive by double-clicking the `mount-w-drive.bat` file
3. click `W:\Launch ConEmu.lnk` to open a command prompt
4. in the command prompt run `W:\set-env.bat` to set up the PATH etc 
5. walk through the [GETTING_STARTED](file://W:/_GETTING_STARTED.html) tutorial to get familiar with Vagrant, Chef & Co
6. continue with the [COOKBOOK_DEVELOPMENT](file://W:/_COOKBOOK_DEVELOPMENT.html) guide and start cooking your own recipes!
