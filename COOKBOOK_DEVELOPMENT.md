
# (Test-Driven) Cookbook Development

## Create the Cookbook

First, choose a directory where you keep your cookbook sources and `cd` into it:

	cd /D W:\repo\my-cookbooks 

Then create a new cookbook (let's call it `foo`) in the current directory:

	knife cookbook create foo -o .

### More Information

 * description of [Knife](http://wiki.opscode.com/display/chef/Knife) in the Opscode Wiki
 * run `knife help` or `knife <subcommand> help` for interactive help 

## Create a Failing Test (or Spec)

Before we start hacking, let's think for a moment what our `foo` cookbook should actually do and write a test for it. We assume our mighty powerful cookbook would make the world a better place by creating a file named `/tmp/foo` with content `hey, i'm running on <platform goes here>!`. 

We can write an rspec example for this using [Chefspec](https://github.com/acrmp/chefspec). The first step is to create a skeleton spec:

	knife cookbook create_specs foo -o .

Now go into the cookbook directory and run the specs:

	cd foo
	rspec --color --format documentation

You should get something similar to this (if you prefer to always have colored output and the doc format consider adding these switches to a `foo/.rspec` file): 

	W:\repo\my-cookbooks\foo>rspec --color --format documentation

	foo::default
	  should do something (PENDING: Your recipe examples go here.)

	Pending:
	  foo::default should do something
		# Your recipe examples go here.
		# ./spec/default_spec.rb:5

	Finished in 0.001 seconds
	1 example, 0 failures, 1 pending

Now edit the `foo/spec/default_spec.rb` and replace the pending example with the real, failing one, e.g. like so:

	require 'faster_require'
	require 'chefspec'

	describe 'foo::default' do
	  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'foo::default' }
	  it 'should create "/tmp/foo"' do
	    chef_run.should create_file '/tmp/foo'
	  end
	end


If you run the specs again using `rspec` it should fail now:

	W:\repo\my-cookbooks\foo>rspec --color --format documentation

	foo::default
	  should create "/tmp/foo" (FAILED - 1)
	  should create file with content "/tmp/foo" and "bar!" (FAILED - 2)

	Failures:

	  1) foo::default should create "/tmp/foo"
	     Failure/Error: chef_run.should create_file '/tmp/foo'
	       No file resource named '/tmp/foo' with action :create found.
	     # ./spec/default_spec.rb:6:in `block (2 levels) in <top (required)>'

	  2) foo::default
	     Failure/Error: it { chef_run.should create_file_with_content '/tmp/foo', 'bar!' }
	       File content:
	        does not match expected:
	       bar!
	     # ./spec/default_spec.rb:8:in `block (2 levels) in <top (required)>'

	Finished in 0.049 seconds
	2 examples, 2 failures

	Failed examples:

	rspec ./spec/default_spec.rb:5 # foo::default should create "/tmp/foo"
	rspec ./spec/default_spec.rb:8 # foo::default

This is good! Now that we have a failing spec we can add the implementation in the next step.

### More Information

 * the [chefspec README](https://github.com/acrmp/chefspec/blob/master/README.md) has more examples on how to use the `file`, `directory`, `user`, `package` and `service` matchers
 * in doubt, consult the source and look how the [chefspec matchers](https://github.com/acrmp/chefspec/tree/master/lib/chefspec/matchers) are implemented
 * the [rspec documentation](https://www.relishapp.com/rspec/rspec-core/v/2-11/docs/) explains the `describe`, `context`, `before`, `let` and `it` syntax
 * how to use [implicit subjects](http://blog.davidchelimsky.net/2012/05/13/spec-smell-explicit-use-of-subject/) for cleaner rspec tests (since rspec 2.11)
 * note that the `require 'faster_require'` is optional. It comes with the [faster_require](https://github.com/rdp/faster_require) gem and drastically reduces rspec startup time. 

## Implement the Recipe

Now let's implement a default recipe that makes the specs pass, e.g. edit your `foo\recipes\default.rb` like this:

	file "/tmp/foo" do
	  action :create
	  owner "root"
	  group "root"
	  mode "0644"
	  content "hey, I'm running on #{node[:platform]}!"
	end

Now is a good point to do some basic syntax checking and linting to make sure our recipe is actually valid Ruby code and conforms to good cookbook style. Running `knife cookbook test foo` makes sure you have written valid Ruby syntax:

	W:\repo\my-cookbooks\foo>knife cookbook test foo
	WARNING: No knife configuration file found
	checking foo
	Running syntax check on foo
	Validating ruby files
	Validating templates
	Validating ruby files
	Validating templates

On the next level you can run [foodcritic](https://github.com/acrmp/foodcritic) to check for good cookbook style and common mistakes in recipes:

	W:\repo\my-cookbooks\foo>foodcritic .
	FC001: Use strings in preference to symbols to access node attributes: ./recipes/default.rb:15
	FC008: Generated cookbook metadata needs updating: metadata.rb:1
	FC008: Generated cookbook metadata needs updating: metadata.rb:2

See, we already spotted some issues in our very simple cookbook. Now it's time to check out the description of the [flagged](http://acrmp.github.com/foodcritic/#FC001) [rules](http://acrmp.github.com/foodcritic/#FC008) and fix the issues. Once you do that the foodcritic linting should pass.

Now that we have implemented the recipe, if you run the spec tests again they should be green now. Yay! :-) 

	W:\repo\my-cookbooks\foo>rspec --color --format documentation
	
	foo::default
	  should create "/tmp/foo"

	Finished in 0.03 seconds
	1 example, 0 failures

Finally note that Chefspec does not modify your system, i.e. it won't create `/tmp/foo` on your filesystem, it rather simulates a Chef run and records which resources the Chef run *would have created*.

### More Information

 * the Opscode Wiki explains the structure of [Cookbooks](http://wiki.opscode.com/display/chef/Cookbooks) and the available [Chef Resources](http://wiki.opscode.com/display/chef/Resources)
 * learn more about the [foodcritic rules](http://acrmp.github.com/foodcritic/)
 * consider adding more foodcritic rules, e.g. the ones from [Etsy](https://github.com/etsy/foodcritic-rules) and [CustomInk](https://github.com/customink-webops/foodcritic-rules)

## Mocking Ohai Data

Oh wait, our specs are not complete yet. What about the contents of our `/tmp/foo` file?

Now this is where [Fauxhai](https://github.com/customink/fauxhai/) comes in and Chefspec really starts getting useful. With Fauxhai you can mock the data that is usually collected on the node by [Ohai](http://wiki.opscode.com/display/chef/Ohai). For example, we could simulate the chef run on an ubuntu node:

	require 'faster_require'
	require 'chefspec'
	require 'fauxhai'

	describe 'foo::default' do
	  
	  context "on Ubuntu" do
	    before { Fauxhai.mock(platform: 'ubuntu') }
	    let (:chef_run) { ChefSpec::ChefRunner.new.converge 'foo::default' }
	    
	    it 'should create "/tmp/foo" telling that it\'s running on Ubuntu' do
	      chef_run.should create_file_with_content '/tmp/foo', 'hey, I\'m running on ubuntu!'
	    end
	  end

	  context "on CentOS" do
	    before { Fauxhai.mock(platform: 'centos') }
	    let (:chef_run) { ChefSpec::ChefRunner.new.converge 'foo::default' }
	    
	    it 'should create "/tmp/foo" telling that it\'s running on CentOS' do
	      chef_run.should create_file_with_content '/tmp/foo', 'hey, I\'m running on centos!'
	    end
	  end
	end

Even though you are running the specs from a Windows machine, the actual Ohai data is coming from fauxhai's pre-defined data sets for Ubuntu and CentOS. They should all pass:

	W:\repo\my-cookbooks\foo>rspec --color --format documentation

	foo::default
	  on Ubuntu
	    should create "/tmp/foo" telling that it's running on Ubuntu
	  on CentOS
	    should create "/tmp/foo" telling that it's running on CentOS

	Finished in 0.046 seconds
	2 examples, 0 failures


### More Information

 * fauxhai provides pre-baked ohai data for [specific platforms](https://github.com/customink/fauxhai/tree/master/lib/fauxhai/platforms) as a starting point
 * at any rate you can always [override the ohai attributes](https://github.com/customink/fauxhai#overriding) as you like
 * Chefspec becomes really powerful and is an efficient tool for testing various combinations of [node data, ohai data, search- and databag queries](https://github.com/acrmp/chefspec#examples-should-do-more-than-restate-static-resources)


## Integration Testing on the Node

 So far we only did unit-level spec testing. The next step is to integration-test our cookbook on a node. For this purpose we first create a `Vagrantfile` within our cookbook directory:

 	vagrant init 

 You should edit the `Vagrantfile` so that the foo cookbook can be found in the cookbook path:

	Vagrant::Config.run do |config|

	  config.vm.box = "ubuntu-12.04-server-amd64-vagrant"
	  config.vm.box_url = "http://dl.dropbox.com/u/13494216/ubuntu-12.04-server-amd64-vagrant.box"
	  
	  config.vm.network :hostonly, "192.168.44.10"
	  config.vm.host_name = "foo-vm"
	  
	  config.vm.provision :chef_solo do |chef|
	    chef.cookbooks_path = [ ".." ]
	    chef.add_recipe "foo::default"
	  end
	end

Given the file above, you should be able to do a `vagrant up` in order to bring up the VM and provision the `foo::default` recipe using [chef_solo](http://vagrantup.com/v1/docs/provisioners/chef_solo.html). Whenever you make changes to the recipe you can run `vagrant provision` to [converge the node](http://wiki.opscode.com/display/chef/Anatomy+of+a+Chef+Run) again.

The output of `vagrant up` should look similar to this:

	W:\repo\my-cookbooks\foo>vagrant up
	[default] Importing base box 'ubuntu-12.04-server-amd64-vagrant'...
	[default] Matching MAC address for NAT networking...
	[default] Clearing any previously set forwarded ports...
	[default] Forwarding ports...
	[default] -- 22 => 2222 (adapter 1)
	[default] Creating shared folders metadata...
	[default] Clearing any previously set network interfaces...
	[default] Preparing network interfaces based on configuration...
	[default] Booting VM...
	[default] Waiting for VM to boot. This can take a few minutes.
	[default] VM booted and ready for use!
	[default] Configuring and enabling network interfaces...
	[default] Setting host name...
	[default] Mounting shared folders...
	[default] -- v-root: /vagrant
	[default] -- v-csc-1: /tmp/vagrant-chef-1/chef-solo-1/cookbooks
	[default] Running provisioner: Vagrant::Provisioners::ChefSolo...
	[default] Generating chef JSON and uploading...
	[default] Running chef-solo...
	stdin: is not a tty
	[Mon, 27 Aug 2012 18:59:34 +0000] INFO: *** Chef 0.10.10 ***
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: Setting the run_list to ["recipe[foo::default]"] from JSON
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: Run List is [recipe[foo::default]]
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: Run List expands to [foo::default]
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: Starting Chef Run for foo-vm
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: Running start handlers
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: Start handlers complete.
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: Processing file[/tmp/foo] action create (foo::default line 10)
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: file[/tmp/foo] created file /tmp/foo
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: Chef Run complete in 0.083410154 seconds
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: Running report handlers
	[Mon, 27 Aug 2012 18:59:35 +0000] INFO: Report handlers complete

As you can see from the Chef log output the Chef run completed successfully.


