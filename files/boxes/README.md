
This is the place where I keep my Vagrant baseboxes as .box files. You can download them from here:

 * http://dl.dropbox.com/u/13494216/ubuntu-12.04-server-amd64-bare-os.box
 * http://dl.dropbox.com/u/13494216/ubuntu-12.04-server-amd64-vagrant.box
 * http://dl.dropbox.com/u/13494216/chef-server-on-ubuntu-12.04-server-amd64-vagrant.box

Once you downloaded the baseboxes you can import them using:
"""
vagrant box add ubuntu-12.04-server-amd64-bare-os file:///W:/boxes/ubuntu-12.04-server-amd64-bare-os.box
vagrant box add ubuntu-12.04-server-amd64-vagrant file:///W:/boxes/ubuntu-12.04-server-amd64-vagrant.box
vagrant box add chef-server-on-ubuntu-12.04-server-amd64-vagrant file:///W:/boxes/chef-server-on-ubuntu-12.04-server-amd64-vagrant.box
"""

