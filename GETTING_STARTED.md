
# Getting Started

Getting started with Chef and Vagrant.

## Prerequisites

Make sure that VirtualBox is installed as described in the [README](file://W:/_README.html). 

Internet connectivity is a must as we will bootstrap new VMs from scratch which requires downloading packages etc...

We assume you mounted Bill's Kitchen to the `W:\` drive by double-clicking the `mount-w-drive.bat` file and that the environment has been set up via `W:\set-env.bat`. 


## The Scenario

We are going to set up a Chef server locally on our laptop, and then set up a web server node from scratch using `knife bootstrap`. Thus the next steps are:

1. Setup a Chef Server
2. Verify the Chef Server works
3. Setup a Web Server using Chef

### Setup a Chef Server

Within our chef repository located at `W:\repo\my-chef-repo` there is a `Vagrantfile` which we will use for setting up a Chef Server VM using [knife-server](https://github.com/fnichol/knife-server). Go to that directory and run `vagrant up chef_server`. This will fire up a Vagrant VM with a bare os Ubuntu basebox:

```
W:\repo\my-chef-repo>vagrant up
[chef_server] VM already created. Booting if it's not already running...
[chef_server] Clearing any previously set forwarded ports...
[chef_server] Forwarding ports...
[chef_server] -- 22 => 22311 (adapter 1)
[chef_server] Creating shared folders metadata...
[chef_server] Clearing any previously set network interfaces...
[chef_server] Preparing network interfaces based on configuration...
[chef_server] Running any VM customizations...
[chef_server] Booting VM...
[chef_server] Waiting for VM to boot. This can take a few minutes.
[chef_server] VM booted and ready for use!
[chef_server] Configuring and enabling network interfaces...
[chef_server] Setting host name...
[chef_server] Mounting shared folders...
[chef_server] -- v-root: /vagrant
The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` v-root /vagrant
```

You can ignore the error message at the bottom. This just means that it couldn't mount the 

You can verify that the Chef Server VM is running using `vagrant status chef_server`:

```
W:\repo\my-chef-repo>vagrant status chef_server
Current VM states:

chef_server              running

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
```

Now use `knife-server` to bootstrap a new Chef Server installation on that empty Vagrant VM. When you look at the `Vagrantfile` you will notice the IP address of the `chef_server` VM we just started is `33.33.3.10`, so that is what we will use for bootstrapping the Chef Server installation:

```
W:\repo\my-chef-repo>knife server bootstrap standalone --ssh-user vagrant --ssh-password vagrant --node-name chef-server --host 33.33.3.10 --bootstrap-version 10.14.4
Bootstrapping Chef on 33.33.3.10
33.33.3.10 + setup
33.33.3.10 + apt-get update
0% [Working]
Ign http://security.ubuntu.com precise-security InRelease
10% [Connecting to us.archive.ubuntu.com (91.189.91.30)]
Get:1 http://security.ubuntu.com precise-security Release.gpg [198 B]
...
```

This might take a while... and finally end up like this: 

```
...
33.33.3.10 [Fri, 28 Sep 2012 18:05:22 +0000] INFO: Processing service[apache2] action restart (apache2::default line 219)
33.33.3.10 [Fri, 28 Sep 2012 18:05:25 +0000] INFO: service[apache2] restarted
33.33.3.10 [Fri, 28 Sep 2012 18:05:25 +0000] INFO: Chef Run complete in 26.269591 seconds
33.33.3.10 [Fri, 28 Sep 2012 18:05:25 +0000] INFO: Running report handlers
33.33.3.10 [Fri, 28 Sep 2012 18:05:25 +0000] INFO: Report handlers complete
33.33.3.10 + rm -rf /tmp/chef-solo
33.33.3.10 + printf -- '-----> Bootstraping Chef Server on chef-server is complete.\n'
33.33.3.10 -----> Bootstraping Chef Server on chef-server is complete.
WARNING: No knife configuration file found
Creating initial API user...
Created client[root]
Configuration file written to /root/.chef/knife.rb
```

What happened so far?
1. knife-server installed chef-server with all it's prerequisites (ruby, rubygems, etc...)
2. it created the admin key `cheffe.pem` and validation key `validation.pem` and copied it to `W:\repo\my-chef-repo\.chef` 
3. it set up apache with ssl so that you can access the REST API via `https://33.33.3.10`

For more details check out the [knife-server README](https://github.com/fnichol/knife-server/blob/master/README.md)


### Verify that the Chef Server works

Ok, server is running. Now let's see if we can talk to it using `knife` (yes, this is the commandline tool of the chefs). Note that the URL of the chef server (along with your client and validation certificate) are already pre-configured in `.chef\knife.rb`. For example, let's query for the clients the chef server knows about: 

```
W:\repo\my-chef-repo>knife client list
  chef-validator
  chef-webui
  cheffe
  root

W:\repo\my-chef-repo>knife client show cheffe
_rev:        1-d5e582804a1ca7a7cc91c9ef6c0932ed
admin:       true
chef_type:   client
json_class:  Chef::ApiClient
name:        cheffe
public_key:  -----BEGIN RSA PUBLIC KEY-----
             MIIBCgKCAQEA15UARmdpIp0YTqekrhtVjcsNtNcj1B4ERemPiiNSCO7bapGmK0hA
             PQ24pHwyGB7S+xTWr+DED258lwVwKLJ5kmZPl3gVsSaycCrJbg2Md6osuWwuSLuS
             RH7Rt49iMvUZI9I+6DiNRUupc7ppdx9v5LTp0tp75ec0/SRmBHiaXK/h5D/J+m43
             e8+P90oK2Mg8/yaBtfuayIpdQ2AksCjjmFNoggBhSIKb0WAwPXNGcwk+B5Ip4PHz
             81CVT6wDNDF9K9GploV0QimWehQJJlmehGruZTMaZOZGZHpguxaaRUNFAgJrCLqM
             Ff/zXWAj+9pD6s09TIwY+W63sPgiD87ZWwIDAQAB
             -----END RSA PUBLIC KEY-----
```  

Now that our chef server is running we have to upload all the cookbooks, roles, data bags and environments that we have in our chef repository. The first step is to get all the cookbooks defined in `Cheffile` from their remote resources using [librarian](https://github.com/applicationsonline/librarian):

```
W:\repo\my-chef-repo>librarian-chef clean

W:\repo\my-chef-repo>librarian-chef install

W:\repo\my-chef-repo>dir cookbooks
 Volume in drive W is ZUEHLKE
 Volume Serial Number is CE7B-106D

 Directory of W:\repo\my-chef-repo\cookbooks

11.05.2012  10:11    &lt;DIR&gt;          .
11.05.2012  10:11    &lt;DIR&gt;          ..
11.05.2012  10:11    &lt;DIR&gt;          apache2
11.05.2012  10:11    &lt;DIR&gt;          build-essential
11.05.2012  10:11    &lt;DIR&gt;          graphite
11.05.2012  10:11    &lt;DIR&gt;          munin
11.05.2012  10:11    &lt;DIR&gt;          ntp
11.05.2012  10:11    &lt;DIR&gt;          python
11.05.2012  10:11    &lt;DIR&gt;          runit
11.05.2012  10:11    &lt;DIR&gt;          vagrant-ohai
```

As you can see from the output above, `librarian-chef` has now pulled the dependencies defined in `Cheffile` to the cookbooks directory in `W:\repo\my-chef-repo\cookbooks`. Don't edit your cookbooks in here as this directory is managed by librarian! 

Ok, now let's upload everything from our chef repository to the chef server. The easiest way to do this by running `rake install` inside `my-chef-repo`:

```
W:\repo\my-chef-repo>rake install
** Updating your repository
git pull
Already up-to-date.
Updated Role webserver!
Uploading apache2                     [1.1.8]
Uploading build-essential             [1.0.0]
Uploading graphite                    [0.3.0]
Uploading munin                       [1.0.2]
Uploading ntp                         [1.1.8]
Uploading python                      [1.0.6]
Uploading runit                       [0.15.0]
Uploading vagrant-ohai                [1.0.0]
upload complete
```

Great! Our chef server now knows all our cookbooks, roles, environments etc.

You can also use the chef server webui to explore any data on the chef server. Just point your browser to http://33.33.3.10:4040/cookbooks (log in with admin/chefchef) and explore the cookbooks we have just uploaded:

![Chef Server - Explore Cookbooks](https://raw.github.com/tknerr/bills-kitchen/master/doc/chef-server_cookbooks.png) 

### Setup a Web Server using Chef

Now let's bootstrap a new web server node and configure it via the chef server. 

The first thing we have to do is to bring up a 'bare os' image, i.e. with nothing installed but the operating system. For this purpose we have the `bare_os_image` VM defined in the `Vagrantfile`:

```
W:\repo\my-chef-repo>vagrant up bare_os_image
[bare_os_image] Importing base box 'bare-os'...
[bare_os_image] No guest additions were detected on the base box for this VM! Guest
additions are required for forwarded ports, shared folders, host only
networking, and more. If SSH fails on this machine, please install
the guest additions and repackage the box to continue.

This is not an error message; everything may continue to work properly,
in which case you may ignore this message.
[bare_os_image] Matching MAC address for NAT networking...
[bare_os_image] Clearing any previously set forwarded ports...
[bare_os_image] Forwarding ports...
[bare_os_image] -- 22 => 22311 (adapter 1)
[bare_os_image] Creating shared folders metadata...
[bare_os_image] Clearing any previously set network interfaces...
[bare_os_image] Preparing network interfaces based on configuration...
[bare_os_image] Booting VM...
[bare_os_image] Waiting for VM to boot. This can take a few minutes.
[bare_os_image] VM booted and ready for use!
[bare_os_image] Configuring and enabling network interfaces...
[bare_os_image] Setting host name...
[bare_os_image] Mounting shared folders...
[bare_os_image] -- v-root: /vagrant
The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` v-root /vagrant
```

Don't bother about the warnings you see in the output above - these are due to the fact that we started a VM which is not a typical Vagrant base box (i.e. with Ruby, Chef and VBox Guest Additions) but rather a bare-naked OS. It makes still sense to use Vagrant here because we can still use it to configure the network and other VM parameters in the Vagrantfile.

Ok, now lets run `vagrant status` again to check if both VMs are running now:

```
W:\repo\my-chef-repo>vagrant status
Current VM states:

chef_server              running
bare_os_image            running

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

Ok, looks good. Now lets go ahead and bootstrap that VM using chef. That process might take a while - it will ssh into that VM and install the chef-client, then register the client at the server and finally converge the node to the desired state (i.e. "apply" webserver role as passed to the node's initial run_list). We bootstrap the new node with `role[webserver]` and `recipe[vagrant-ohai]` (the latter one fixes ohai's IP address detection when running inside Vagrant) and the [bootstrap template](https://github.com/opscode/chef/tree/0.10.10/chef/lib/chef/knife/bootstrap) for Ubuntu 12.04:

```
W:\repo\my-chef-repo>knife bootstrap 33.33.3.11 -x vagrant -P vagrant --sudo -N my-node -r 'role[webserver],recipe[vagrant-ohai] -d ubuntu12.04-gems'
Bootstrapping Chef on 33.33.3.11
...
33.33.3.11 Successfully installed chef-0.10.10
33.33.3.11 16 gems installed
33.33.3.11
33.33.3.11 [Fri, 18 May 2012 06:57:37 +0000] INFO: *** Chef 0.10.10 ***
33.33.3.11 [Fri, 18 May 2012 06:57:37 +0000] INFO: Client key /etc/chef/client.pem is not present - registering
33.33.3.11 [Fri, 18 May 2012 06:57:38 +0000] INFO: HTTP Request Returned 404 Not Found: Cannot load node my-node
33.33.3.11 [Fri, 18 May 2012 06:57:38 +0000] INFO: Setting the run_list to ["role[webserver]", "recipe[vagrant-ohai]"] from JSON
33.33.3.11 [Fri, 18 May 2012 06:57:38 +0000] INFO: Run List is [role[webserver], recipe[vagrant-ohai]]
33.33.3.11 [Fri, 18 May 2012 06:57:38 +0000] INFO: Run List expands to [apache2, apache2::mod_ssl, vagrant-ohai]
33.33.3.11 [Fri, 18 May 2012 06:57:38 +0000] INFO: Starting Chef Run for my-node
...
33.33.3.11 [Fri, 18 May 2012 06:58:04 +0000] INFO: Processing service[apache2] action restart (apache2::default line 216)
33.33.3.11 [Fri, 18 May 2012 06:58:08 +0000] INFO: service[apache2] restarted
33.33.3.11 [Fri, 18 May 2012 06:58:08 +0000] INFO: Chef Run complete in 29.984836 seconds
33.33.3.11 [Fri, 18 May 2012 06:58:08 +0000] INFO: Running report handlers
33.33.3.11 [Fri, 18 May 2012 06:58:08 +0000] INFO: Report handlers complete
```

Make sure that the node has been properly registered with chef server:

```
W:\repo\my-chef-repo>knife node list
  my-node

W:\repo\my-chef-repo>knife node show my-node
Node Name:   my-node
Environment: _default
FQDN:        bare-os-image
IP:          33.33.3.11
Run List:    role[webserver], recipe[vagrant-ohai]
Roles:       webserver
Recipes:     apache2, apache2::mod_ssl, vagrant-ohai
Platform:    ubuntu 12.04
```

## Next Steps

Now that you have the basic environment up and running, continue with the [COOKBOOK_DEVELOPMENT](file://W:/_COOKBOOK_DEVELOPMENT.html) guide...