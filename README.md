
Description
===========

All you need for cooking with Chef and Vagrant on Windows in a portable package, including:

 * pre-configured Chef Repo with Vagrantfile to bring up a ready-to-use Chef Server 
 * devkit enhanced Ruby 1.9.3 with the following gems pre-installed:
 	* vagrant (patched to make `vagrant ssh` work on windows)
 	* chef
 	* librarian
 	* veewee
 	* sahara (patched to work on windows)
 	* foodcritic
 	* cucumber-nagios
 * supporting tools such as:
 	* Console2 (with ansicon)
 	* SublimeText2 (with additional packages for Chef and Cucumber)
 	* PortableGit (preconfigured with kdiff3 as diff/merge tool)
 * walkthrough tutorial and example cookbooks

The only requirement for using the devpack is a recent version of [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (couldn't make that one portable).


Installation
============

As a prerequisite for building the chef-devpack you need 7zip installed in `C:\Program Files\7-Zip\7z.exe`. 

Build the chef-devpack:

```
gem install bundler
bundle install
rake build
```

This might take a while (go fetch a coffee). It will download the external dependencies and assemble the devpack in the `target/build` directory, which is then packaged as `target/chef-devpack-<version>.7z`

								
Usage
=====

Make sure you have  [VirtualBox](https://www.virtualbox.org/wiki/Downloads) installed, then:

1. unzip the `target/chef-devpack-<version>.7z` somewhere
2. mount the devpack to the `W:\` drive by double-clicking the `mount-w-drive.bat` file
3. click `W:\Launch Console.lnk` to open a command prompt
4. in the command prompt run `W:\set-env.bat` to set up the PATH etc 
5. walk through the [W:\_GETTING_STARTED.html](file://W:/_GETTING_STARTED.html) tutorial and start cooking!

