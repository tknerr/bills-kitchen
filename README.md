
# Bill's Kitchen

All you (or Bill Gates would) need for cooking with Chef and Vagrant on Windows, shrink-wrapped in a portable package.

![Bill's Kitchen Screenshot](https://raw.github.com/tknerr/bills-kitchen/master/doc/bills_kitchen_screenshot.png) 

## What's inside?

### Main Tools

The main tools for cooking with Chef / Vagrant:

* [Ruby](http://rubyinstaller.org/downloads/) 1.9.3 + [DevKit](http://rubyinstaller.org/add-ons/devkit/) 4.5.2
* [Vagrant](http://vagrantup.com/) 1.3.5
* [Omnibus Chef](http://www.getchef.com/chef/install/) 11.10.4

### Plugins

These plugins are pre-installed:

 * [bundler](http://bundler.io/) is the only pre-installed gem, use project-specific `Gemfile` for everything else
 * [bindler](https://github.com/fgrehm/bindler) is the only pre-installed vagrant plugin, use project-specific `plugins.json` for everyting else
 * [knife-audit](https://github.com/jbz/knife-audit) and [knife-server](https://github.com/fnichol/knife-server) are exemplary pre-installed knife plugins. Use `W:/tools/chef/opscode/chef/embedded/bin/gem install <plugin>` to install more

### Supporting Tools

Useful additions for a better cooking experience:

* [ConEmu](https://code.google.com/p/conemu-maximus5/) - a better windows console with colours, tabs, etc...
* [SublimeText2](http://www.sublimetext.com/) - a better editor (trial version) with additional packages for [Chef](https://github.com/cabeca/SublimeChef) and [Cucumber](https://github.com/npverni/cucumber-sublime2-bundle) installed
* [PortableGit](https://code.google.com/p/msysgit/) - git client for windows (preconfigured with [kdiff3](http://kdiff3.sourceforge.net/) as diff/merge tool)
* [putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) - the SSH client for windows
* [Cygwin](http://www.cygwin.com/)-based `ssh.exe` and `rsync.exe` to make rsync-based Vagrant synced folders work on Windows

### Environmental Changes

The following changes are applied to your environment by running `W:\set-env.bat`:

* Constraining as much as possible to the `W:\` drive:
 * `%HOME%` points to `W:\home`
 * `%VAGRANT_HOME%` points to `W:\home\.vagrant.d`
 * `%PATH%` is preprended with the bin dirs of the tools in `W:\tools\`
 * **exception**: `%VBOX_USER_HOME%` points to `%USERPROFILE%`, i.e. VirtualBox VMs are still stored under `%USERPROFILE%`
* Fixing annoyances:
 * `set TERM=rxvt` to fix vagrant ssh issues
 * `set ANSICON=true` to get coloured output with Vagrant on Windows
 * `set SSL_CERT_FILE=W:\home\cacert.pem` pointing to recent CA certs avoiding Ruby SSL errors

### Aliases

Registered doskey aliases:

* run `be <command>` for `bundle exec <command>`
* run `vi <file_or_dir>` for `sublime_text <file_or_dir>` 

### Examples

These repositories are used for acceptance-testing the [common usage scenarios](https://github.com/tknerr/bills-kitchen/blob/master/spec/acceptance/usage_scenarios_spec.rb):

* A [sample-application-cookbook](https://github.com/tknerr/sample-application-cookbook) with all kinds cookbook tests: syntax check, style checks, linting, unit and integration tests
* A [sample-infrastructure-repo](https://github.com/tknerr/sample-infrastructure-repo) which defines a sample server infrastructure with environments and databages via Vagrant / Chef Solo

## Prerequisites

The only requirement for using the devpack is a recent version of [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (couldn't make that one portable).


## Installation

As a prerequisite for building bill's kitchen you need 7zip installed in `C:\Program Files\7-Zip\7z.exe`.

### Building Bill's Kitchen

To build the kitchen (make sure you don't have spaces in the path):
```
$ gem install bundler
$ bundle install
$ rake build
```

This might take a while (you can go fetch a coffee). It will download the external dependencies, install the tools and prepare everything else we need in the kitchen into the `target/build` directory. Finally it runs the `spec/integration` examples to ensure everything is properly installed.

### Running the Acceptance Tests

To run the more comprehensive `spec/acceptance` tests:
```
$ rake acceptance
```

This will use various of the tools in combination by running the main usage scenarios, e.g.:

* cloning a sample application cookbook and sample infrastructure repository
* running various commands like `bundle install`, `vagrant plugin install`, `vagrant up`
* running different kinds of cookbook tests via `knife cookbook test`, `foodcritic`, `chefspec` and `test-kitchen`

### Packaging

Finally, if all the tests pass you can create a portable zip package:
```
$ rake package
```

This will and finally package everything in the `target/build` directory into `target/bills-kitchen-<version>.7z`.

### Changing the Mount Drive Letter

By default the Ruby DevPack will be mounted to the `W:\` drive. If you need to change it you only have to update the references in these two files:

* `mount-drive.cmd`
* `unmount-drive.cmd`

## Usage

Make sure you have [VirtualBox](https://www.virtualbox.org/wiki/Downloads) installed, then:

1. unzip the `target/bills-kitchen-<version>.7z` somewhere
2. mount the kitchen to the `W:\` drive by double-clicking the `mount-drive.bat` file
3. click `W:\Launch ConEmu.lnk` to open a command prompt
4. in the command prompt run `W:\set-env.bat` to set up the environment
5. start hacking!
