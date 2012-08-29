
# Cookbook Development

This guide describes a test-driven appraoch to Chef cookbook development using [Knife](http://wiki.opscode.com/display/chef/Knife), [foodcritic](https://github.com/acrmp/foodcritic), [Chefspec](https://github.com/acrmp/chefspec) and [Fauxhai](https://github.com/customink/fauxhai/) for basic syntax checking, liniting and unit-level spec testing.

For integration-testing we set up a VM environment using [Vagrant](http://vagrantup.com), [Librarian](https://github.com/applicationsonline/librarian) and [Chef Solo](http://wiki.opscode.com/display/chef/Chef+Solo), against which we run some post-convergence smoke tests using [minitest-chef-handler](https://github.com/calavera/minitest-chef-handler/) and some cucumber/features tests using [cucumber-nagios](https://github.com/auxesis/cucumber-nagios).

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


## Converge the Node on a VM

So far we only did unit-level spec testing. The next step is to integration-test our cookbook using [Vagrant](http://vagrantup.com) and [Chef Solo](http://wiki.opscode.com/display/chef/Chef+Solo) on a VM. For this purpose we first create a `Vagrantfile` within our cookbook directory:

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

## Add a Smoke Test

Now that the node converged successfully, we can think of adding a smoke test using [minitest-chef-handler](https://github.com/calavera/minitest-chef-handler/). I'll call it smoke test because it runs on the node and at the end of *every* chef run (as part of the report handlers). For example you can check whether specific services are started, or certain files created, etc. after the chef run completed.

Due to the fact that the minitest-chef-handler test are executed on the node, they must be part of the cookbook files. So let's create a smoke test for our default recipe in `foo/files/default/tests/minitest/default_test.rb`:

	require 'minitest/spec'

	describe 'foo::default' do

	  include MiniTest::Chef::Assertions
	  include MiniTest::Chef::Context
	  include MiniTest::Chef::Resources

	  it 'should create the file "/tmp/foo"' do
	    file("/tmp/foo").must_exist
	  end

	  it 'should populate "/tmp/foo" file with the node platform' do
	    file("/tmp/foo").must_match /running on #{node['platform']}/
	  end
	end

Note that in these kinds of tests we can use `node['platform']` (or any other node/ohai attributes) without mocking them as it will be run on the converged node itself!

In order to have this test running at the end of the chef run we need to install the minitest-chef-handler as a [Report Handler](http://wiki.opscode.com/display/chef/Exception+and+Report+Handlers). Thankfully there is the [minitest-handler-cookbook](https://github.com/btm/minitest-handler-cookbook) which will do this for us. The only thing we have to do is to include the `minitest-handler` as the first recipe in our run list:

	Vagrant::Config.run do |config|

	  config.vm.box = "ubuntu-12.04-server-amd64-vagrant"
	  config.vm.box_url = "http://dl.dropbox.com/u/13494216/ubuntu-12.04-server-amd64-vagrant.box"
	  
	  config.vm.network :hostonly, "192.168.44.10"
	  config.vm.host_name = "foo-vm"
	  
	  config.vm.provision :chef_solo do |chef|
	    chef.cookbooks_path = [ ".." ]
	    chef.add_recipe "minitest-handler"
	    chef.add_recipe "foo::default"
	  end
	end

After editing the `Vagrantfile` as above you have to run `vagrant up` again: 

	W:\repo\my-cookbooks\foo>vagrant up --no-provision
	[default] VM already created. Booting if it's not already running...

Oh see, the Vagrant VM was already running. When it is up and running alreay you have to trigger the provisioning explicitly using `vagrant provision`:  

	W:\repo\my-cookbooks\foo>vagrant provision
	[default] Running provisioner: Vagrant::Provisioners::ChefSolo...
	[default] Generating chef JSON and uploading...
	[default] Running chef-solo...
	stdin: is not a tty
	[Tue, 28 Aug 2012 08:37:55 +0000] INFO: *** Chef 0.10.10 ***
	[Tue, 28 Aug 2012 08:37:56 +0000] INFO: Setting the run_list to ["recipe[minitest-handler]", "recipe[foo::default]"] from JSON
	[Tue, 28 Aug 2012 08:37:56 +0000] INFO: Run List is [recipe[minitest-handler], recipe[foo::default]]
	[Tue, 28 Aug 2012 08:37:56 +0000] INFO: Run List expands to [minitest-handler, foo::default]
	[Tue, 28 Aug 2012 08:37:56 +0000] INFO: Starting Chef Run for foo-vm
	[Tue, 28 Aug 2012 08:37:56 +0000] INFO: Running start handlers
	[Tue, 28 Aug 2012 08:37:56 +0000] INFO: Start handlers complete.
	[Tue, 28 Aug 2012 08:37:56 +0000] ERROR: Running exception handlers
	[Tue, 28 Aug 2012 08:37:56 +0000] ERROR: Exception handlers complete
	[Tue, 28 Aug 2012 08:37:56 +0000] FATAL: Stacktrace dumped to /tmp/vagrant-chef-1/chef-stacktrace.out
	[Tue, 28 Aug 2012 08:37:56 +0000] FATAL: Chef::Exceptions::CookbookNotFound: Cookbook minitest-handler not found. If you're loading minitest-handler from another cookbook, make sure you configure the dependency in your metadata
	Chef never successfully completed! Any errors should be visible in the
	output above. Please fix your recipes so that they properly complete.

Ooops. 

What went wrong here? Oh, see, we added the `minitest-handler` recipe to our `Vagrantfile` but this recipe was not found in the local `cookbooks_path` where Vagrant is looking for it. So we would need to "download" this cookbook first?

Well, this is actually a quite common situation. Imagine our foo cookbook was not so super simple and would depend on other cookbooks, e.g. apache and mysql. The situation would be exactly the same. We need to resolve cookbook dependencies!

### Enter Cookbook Dependency Management  

No, we don't have to download each cookbook we depend on by hand. Thankfully there are tools like [Librarian](https://github.com/applicationsonline/librarian) which handle cookbook dependency management for us. If you know [bundler](http://gembundler.com), then you can think of Librarian as bundler for Chef cookbooks.

For librarian we have to create a `Cheffile` which defines the cookbook dependencies:

	site 'http://community.opscode.com/api/v1'

	cookbook 'minitest-handler', '0.1.0'

This is now a very simple `Cheffile`. It will try to download the `minitest-handler` cookbook in version `0.1.0` from the [Opscode Community](http://community.opscode.com/) site as soon as you run `librarian-chef install`:

	W:\repo\my-cookbooks\foo>librarian-chef install

	W:\repo\my-cookbooks\foo>ls -la cookbooks
	total 12
	drwxr-xr-x  4 tkn Administrators    0 Aug 28 11:21 .
	drwxr-xr-x 13 tkn Administrators 4096 Aug 28 11:21 ..
	drwxr-xr-x  7 tkn Administrators 4096 Aug 28 11:21 chef_handler
	drwxr-xr-x  4 tkn Administrators 4096 Aug 28 11:21 minitest-handler

You can see that `librarian-chef install` keeps quiet if everything goes well. You should now see the `foo/cookbooks` directory with the dependencies being resolved. Note that transitive dependencies (the `minitest-handler` cookbook depends on the `chef_handler` cookbook) are resolved as well. Finally, only the `Cheffile` should be under version control, the volatile `cookbooks` and `tmp` directories that Librarian creates should be added to your `.gitignore` file. 

### Back to the Smoke Test 

Now that we have the cookbook dependencies resolved, we need to add the `foo/cookbooks` directory to the `cookbooks_path` in the `Vagrantfile`. Note that we put it as the first entry in order to make sure that the Librarian-managed cookbooks are always preferred over cookbooks with the same name one dir up. 

	Vagrant::Config.run do |config|

	  config.vm.box = "ubuntu-12.04-server-amd64-vagrant"
	  config.vm.box_url = "http://dl.dropbox.com/u/13494216/ubuntu-12.04-server-amd64-vagrant.box"
	  
	  config.vm.network :hostonly, "192.168.44.10"
	  config.vm.host_name = "foo-vm"
	  
	  config.vm.provision :chef_solo do |chef|
	    chef.cookbooks_path = [ "cookbooks", ".." ]
	    chef.add_recipe "minitest-handler"
	    chef.add_recipe "foo::default"
	  end
	end  

Upon the next `vagrant up` / `vagrant provision` cycle (actually we have to do a `vagrant reload` after changing the cookbooks_path), the node should now successfully converge again and the smoke tests passing at the end of the Chef run:

	W:\repo\my-cookbooks\foo>vagrant up
	[default] VM already created. Booting if it's not already running...

	W:\repo\my-cookbooks\foo>vagrant provision
	[default] Running provisioner: Vagrant::Provisioners::ChefSolo...
	Shared folders that Chef requires are missing on the virtual machine.
	This is usually due to configuration changing after already booting the
	machine. The fix is to run a `vagrant reload` so that the proper shared
	folders will prepared and mounted on the VM.

	W:\repo\my-cookbooks\foo>vagrant reload
	[default] Running provisioner: Vagrant::Provisioners::ChefSolo...
	[default] Generating chef JSON and uploading...
	[default] Running chef-solo...
	stdin: is not a tty
	[Tue, 28 Aug 2012 10:03:25 +0000] INFO: *** Chef 0.10.10 ***
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Setting the run_list to ["recipe[minitest-handler]", "recipe[foo::default]"] from JSON
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Run List is [recipe[minitest-handler], recipe[foo::default]]
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Run List expands to [minitest-handler, foo::default]
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Starting Chef Run for foo-vm
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Running start handlers
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Start handlers complete.
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Processing chef_gem[minitest] action nothing (minitest-handler::default line 2)
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Processing chef_gem[minitest] action install (minitest-handler::default line 2)
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Processing chef_gem[minitest-chef-handler] action nothing (minitest-handler::default line 7)
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Processing chef_gem[minitest-chef-handler] action install (minitest-handler::default line 7)
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Enabling minitest-chef-handler as a report handler
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Processing chef_gem[minitest] action nothing (minitest-handler::default line 2)
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Processing chef_gem[minitest-chef-handler] action nothing (minitest-handler::default line 7)
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Processing directory[minitest test location] action create (minitest-handler::default line 22)
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Processing ruby_block[delete tests from old cookbooks] action create (minitest-handler::default line 30)
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Cookbook foo no longer in run list, remove minitest tests
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: ruby_block[delete tests from old cookbooks] called
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Processing directory[/var/chef/minitest/minitest-handler] action create (minitest-handler::default line 50)
	[Tue, 28 Aug 2012 10:03:26 +0000] INFO: Processing cookbook_file[tests-minitest-handler-default] action create (minitest-handler::default line 53)
	[Tue, 28 Aug 2012 10:03:27 +0000] ERROR: cookbook_file[tests-minitest-handler-default] (minitest-handler::default line 53) had an error: Cookbook 'minitest-handler' (0.1.0) does not contain a file at any of these locations:
	  files/ubuntu-12.04/tests/minitest/default_test.rb
	  files/ubuntu/tests/minitest/default_test.rb
	  files/default/tests/minitest/default_test.rb
	[Tue, 28 Aug 2012 10:03:27 +0000] INFO: Processing directory[/var/chef/minitest/foo] action create (minitest-handler::default line 50)
	[Tue, 28 Aug 2012 10:03:27 +0000] INFO: directory[/var/chef/minitest/foo] created directory /var/chef/minitest/foo
	[Tue, 28 Aug 2012 10:03:27 +0000] INFO: Processing cookbook_file[tests-foo-default] action create (minitest-handler::default line 53)
	[Tue, 28 Aug 2012 10:03:27 +0000] INFO: cookbook_file[tests-foo-default] created file /var/chef/minitest/foo/default_test.rb
	[Tue, 28 Aug 2012 10:03:27 +0000] INFO: Processing file[/tmp/foo] action create (foo::default line 10)
	[Tue, 28 Aug 2012 10:03:27 +0000] INFO: Chef Run complete in 0.444127684 seconds
	[Tue, 28 Aug 2012 10:03:27 +0000] INFO: Running report handlers
	Run options: -v --seed 34593

	# Running tests:

	foo::default#test_0002_should_populate_tmp_foo_file_with_the_node_platform =
	0.00 s =
	.

	foo::default#test_0001_should_create_the_root_owned_tmp_foo_file =
	0.00 s =
	.

	Finished tests in 0.008033s, 248.9827 tests/s, 248.9827 assertions/s.

	2 tests, 2 assertions, 0 failures, 0 errors, 0 skips
	[Tue, 28 Aug 2012 10:03:27 +0000] INFO: Report handlers complete

Yay! Smoke tests are passing :-)


### More Information

 * take a look at the minitest-chef-handler tests for the [apache2](https://github.com/opscode-cookbooks/apache2/tree/master/files/default/tests/minitest) and [mysql](https://github.com/opscode-cookbooks/mysql/tree/master/files/default/tests/minitest) cookbooks for inspiration
 * there is also this [fully documented example](https://github.com/calavera/minitest-chef-handler/blob/master/examples/spec_examples/files/default/tests/minitest/example_test.rb) for spec-based minitests 
 * apart from [Librarian](https://github.com/applicationsonline/librarian) there is also [Berkshelf](https://github.com/RiotGames/berkshelf), which looks very promising, but does not run on Windows yet.
 * both Librarian and Berkshelf also support resolving dependencies from git or the local filesystem in addition to the Opscode Community site, check [the](http://berkshelf.com/) [docs](https://github.com/applicationsonline/librarian) for this. 


## Add a Cucumber Feature

Now that we have a fully converged node passing the smoke tests we may want to do something more acceptance-testy. For this purpose we will now create a cucumber feature based on [cucumber-nagios](https://github.com/auxesis/cucumber-nagios). For this we create the `foo/features/foo.feature` file and write down what we expect:

Let's start by creating the `foo/features/foo.feature` file and write down what we expect. You should not think of any available cucumber steps that you could reuse here, just write down what you'd expect from a user's point of view:

	Feature: the world-changing foo file 

	  Background:
	    Given a Vagrant VM with foo deployed is up and running

	  Scenario: check the foo file 
	    When I ssh into the Vagrant VM 
	     And look at the foo file
	    Then it should say "hey, I'm running on ubuntu!" 

Now run `cucumber` so that it generates the test steps that we need to implement:

	W:\repo\my-cookbooks\foo>cucumber
	Feature: the world-changing foo file

	  Background:                                              # features\foo.feature:3
	    Given a Vagrant VM with foo deployed is up and running # features\foo.feature:4

	  Scenario: check the foo file                             # features\foo.feature:6
	    When I ssh into the Vagrant VM                         # features\foo.feature:7
	    And look at the foo file                               # features\foo.feature:8
	    Then it should say "hey, I'm running on ubuntu!"       # features\foo.feature:9

	1 scenario (1 undefined)
	4 steps (4 undefined)
	0m1.119s

	You can implement step definitions for undefined steps with these snippets:

	Given /^a Vagrant VM with foo deployed is up and running$/ do
	  pending # express the regexp above with the code you wish you had
	end

	When /^I ssh into the Vagrant VM$/ do
	  pending # express the regexp above with the code you wish you had
	end

	When /^look at the foo file$/ do
	  pending # express the regexp above with the code you wish you had
	end

	Then /^it should say "([^"]*)"$/ do |arg1|
	  pending # express the regexp above with the code you wish you had
	end

	Then we can copy/paste the steps definitions into `foo/features/steps/foo_steps.rb` and gradually fill them with life until there are no pending steps anymore and all scenarios pass. 

We can now copy/paste the skeleton step definitions from above into `foo/features/steps/foo_steps.rb` and gradually implement them until all scenarios pass. Your implementation of the step definitions in `foo_steps` could then look like this:

	PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

	Given /^a Vagrant VM with foo deployed is up and running$/ do
	  `cd #{PROJECT_ROOT} && vagrant up --no-provision && vagrant provision`
	  raise "failed to start Vagrant VM" unless $?.exitstatus == 0
	end

	When /^I ssh into the Vagrant VM$/ do
	  ip = get_ip_from_vagrantfile
	  steps %{
	    When I ssh to "#{ip}" with the following credentials:
	         | username | password |
	         | vagrant  | vagrant  |
	  }
	end

	When /^look at the foo file$/ do
	  steps %{
	    When I run "cat /tmp/foo"
	  }
	end

	Then /^it should say "([^"]*)"$/ do |text|
	  steps %{
	    Then I should see "#{text}" in the output
	  }
	end
	 
	def get_ip_from_vagrantfile
	  require 'vagrant'
	  env = ::Vagrant::Environment.new(:cwd => PROJECT_ROOT)
	  env.primary_vm.config.vm.networks[0][1][0]
	end

Note the that the implementation of the `Given /^a Vagrant VM...$/` steps and `get_ip_from_vagrantfile` helper method is really a hack. Cuken provides some reusable [vagrant steps](https://github.com/hedgehog/cuken/blob/v0.1.22/lib/cuken/cucumber/vagrant/common.rb), but as of today they [don't support Vagrant 1.0.x](https://github.com/hedgehog/cuken/issues/10) yet, so we stay with that hack for now.

For the implementation of the other steps we could actually reuse the [ssh steps](https://github.com/auxesis/cucumber-nagios/blob/v0.9.2/lib/cucumber/nagios/steps/ssh_steps.rb#L58-82) from cucumber-nagios. In order to be able to reuse [all the cucumber-nagios steps](https://github.com/auxesis/cucumber-nagios/tree/v0.9.2/lib/cucumber/nagios/steps) we need to require them in `foo/features/support/env.rb` (note: the Webrat stuff is required for the http steps):

	# require nagios steps (see https://github.com/auxesis/cucumber-nagios/tree/v0.9.2/lib/cucumber/nagios/steps) 
	require 'cucumber/nagios/steps'

	# Suppress logs being written to ./webrat.log
	module Webrat
	  module Logging
	    def logger
	      nil
	    end
	  end
	end

	World do
	  Webrat::Session.new(Webrat::MechanizeAdapter.new)
	end

If you have all that in place and now run `cucumber` again, you should see the scenario pass:

	W:\repo\my-cookbooks\foo>cucumber
	Feature: the world-changing foo file

	  Background:                                              # features\foo.feature:3
	D:/Repos/_github/bills-kitchen/target/build/tools/vagrant/vagrant/vagrant/embedded/lib/ruby/site_ruby/1.9.1/rubygems/custom_require.rb:36:in `require': iconv will be deprecated in the future, use String#encode instead.
	    Given a Vagrant VM with foo deployed is up and running # features/steps/foo_steps.rb:5

	  Scenario: check the foo file                             # features\foo.feature:6
	    When I ssh into the Vagrant VM                         # features/steps/foo_steps.rb:10
	    And look at the foo file                               # features/steps/foo_steps.rb:19
	    Then it should say "hey, I'm running on ubuntu!"       # features/steps/foo_steps.rb:25

	1 scenario (1 passed)
	4 steps (4 passed)
	0m36.983s

Yeah! That's it. This should be enough fodder to get you started. Make sure to dive into the provided links for more information on the specific topics, or let me know if you are missing something. Happy Cooking! 

### More Information

 * the available steps in cucumber-nagios are best discovered by [browsing the source](https://github.com/auxesis/cucumber-nagios/tree/v0.9.2/lib/cucumber/nagios/steps)
 * Dan North has some nice introductions to [BDD](http://dannorth.net/introducing-bdd/) and [Cucumber](http://dannorth.net/whats-in-a-story/) 
 * [You're Cuking it Wrong](http://www.elabs.se//blog/15-you-re-cuking-it-wrong) tells you how to write good features and gives examples of really bad ones
 * the syntax of a .feature file is named Gherkin. It's structure is [best described here](http://docs.behat.org/guides/1.gherkin.html)
