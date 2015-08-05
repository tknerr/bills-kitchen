
$env:BK_ROOT = Split-Path $MyInvocation.MyCommand.Path

$env:SCRIPTSDIR = Join-Path $env:BK_ROOT tools\scripts
$env:DOCKERDIR = Join-Path $env:BK_ROOT tools\docker
$env:DEVKITDIR = Join-Path $env:BK_ROOT tools\devkit
$env:KDIFF3DIR = Join-Path $env:BK_ROOT tools\kdiff3
$env:CWRSYNCDIR = Join-Path $env:BK_ROOT tools\cwrsync\cwRsync_5.4.1_x86_Free
$env:CONEMUDIR = Join-Path $env:BK_ROOT tools\conemu
$env:ATOMDIR = Join-Path $env:BK_ROOT tools\atom\Atom\resources\cli
$env:APMDIR = Join-Path $env:BK_ROOT tools\atom\Atom\resources\app\apm\bin
$env:PUTTYDIR = Join-Path $env:BK_ROOT tools\putty
$env:CLINKDIR = Join-Path $env:BK_ROOT tools\clink
$env:VAGRANTDIR = Join-Path $env:BK_ROOT tools\vagrant\HashiCorp\Vagrant
$env:TERRAFORMDIR = Join-Path $env:BK_ROOT tools\terraform
$env:PACKERDIR = Join-Path $env:BK_ROOT tools\packer
$env:CONSULDIR = Join-Path $env:BK_ROOT tools\consul
$env:CHEFDKDIR = Join-Path $env:BK_ROOT tools\chefdk
$env:CHEFDKHOMEDIR = Join-Path $env:BK_ROOT home\.chefdk

## inject clink into current cmd.exe
invoke-expression ((Join-Path $env:CLINKDIR clink.bat) inject)

## set %RI_DEVKIT$ env var and add DEVKIT to the PATH
invoke-expression (Join-Path $env:DEVKITDIR devkitvars.bat)

$env:HOME = Join-Path $env:BK_ROOT home

## set ATOM_HOME to make it devpack-local
$env:ATOM_HOME = Join-Path $env:HOME .atom

## set atom as the default EDITOR
$env:EDITOR = "atom.sh --wait"

## set the home dir for boot2docker
$env:BOOT2DOCKER_DIR = Join-Path $env:HOME .boot2docker

## init the shell for boot2docker
$env:DOCKER_HOST = "tcp://192.168.59.103:2376"
$env:DOCKER_CERT_PATH = Join-Path $env:BOOT2DOCKER_DIR certs\boot2docker-vm
$env:DOCKER_TLS_VERIFY = "1"

## experimental: enable remote docker host patch in vagrant
$env:VAGRANT_DOCKER_REMOTE_HOST_PATCH = "1"

## Chef-DK embedded Ruby is now the primary one!
## see: http://jtimberman.housepub.org/blog/2014/04/30/chefdk-and-ruby/
## see: `chef shell-init powershell`
$env:GEM_ROOT = Join-Path $env:CHEFDKDIR embedded\lib\ruby\gems\2.1.0
$env:GEM_HOME = Join-Path $env:CHEFDKHOMEDIR gem\ruby\2.1.0
$env:GEM_PATH = "$env:GEM_HOME;$env:GEM_ROOT"
## that's how the PATH entries are generated for chef shell-init
$env:CHEFDK_PATH_ENTRIES = "$env:CHEFDKDIR\bin;$env:CHEFDKHOMEDIR\gem\ruby\2.1.0\bin;$env:CHEFDKDIR\embedded\bin"

## also set the newly introduced (as of ChefDK 0.7.0) CHEFDK_HOME environment
$env:CHEFDK_HOME=$env:CHEFDKHOMEDIR

if($env:GITDIR -eq $NULL) {
	$env:GITDIR = Join-Path $env:BK_ROOT tools\portablegit
	$env:Path = "$env:Path;$(Join-Path $env:GITDIR "cmd");$env:GITDIR"
}

## set git executable path
$script:git = Join-Path (Join-Path $env:GITDIR "cmd") "git"

## set git username
$env:GIT_CONF_USERNAME = invoke-expression "$git config --get user.name"
if(!$env:GIT_CONF_USERNAME) {
  $env:GIT_CONF_USERNAME = Read-Host "Your Name (will be written to $env:HOME\.gitconfig)"
  if($env:GIT_CONF_USERNAME) {
    invoke-expression "$git config --global user.name '$env:GIT_CONF_USERNAME'"
  }
}

## set git email
$env:GIT_CONF_EMAIL = invoke-expression "$git config --get user.email"
if(!$env:GIT_CONF_EMAIL) {
  $env:GIT_CONF_EMAIL = Read-Host "Your Email (will be written to $env:HOME\.gitconfig)"
  if($env:GIT_CONF_EMAIL) {
    invoke-expression "$git config --global user.email '$env:GIT_CONF_EMAIL'"
  }
}


## don't let VirtualBox use %HOME% instead of %USERPROFILE%,
## otherwise it would become confused when W:\ is unmounted
$env:VBOX_USER_HOME = $env:USERPROFILE

## set VAGRANT_HOME explicitly, defaults to %USERPROFILE%
$env:VAGRANT_HOME = Join-Path $env:HOME ".vagrant.d"

## set proper TERM to not break `vagrant ssh` terminal,
## see https://github.com/tknerr/bills-kitchen/issues/64
$env:TERM = "cygwin"

## trick vagrant to detect colored output for windows, see here:
## https://github.com/mitchellh/vagrant/blob/7ef6c5d9d7d4753a219d3ab35afae0d475430cae/lib/vagrant/util/platform.rb#L89
$env:ANSICON = "true"

## add recent root certificates to prevent SSL errors on Windos, see:
## https://gist.github.com/fnichol/867550
$env:SSL_CERT_FILE = Join-Path $env:HOME "cacert.pem"

# show the environment
Write-Host "BK_ROOT=$env:BK_ROOT"
Write-Host "HOME=$env:HOME"
Write-Host "SCRIPTSDIR=$env:SCRIPTSDIR"
Write-Host "CHEFDKDIR=$env:CHEFDKDIR"
Write-Host "RUBYDIR=$env:RUBYDIR"
Write-Host "CHEFDKHOMEDIR=$env:CHEFDKHOMEDIR"
Write-Host "GEM_ROOT=$env:GEM_ROOT"
Write-Host "GEM_HOME=$env:GEM_HOME"
Write-Host "GEM_PATH=$env:GEM_PATH"
Write-Host "DOCKERDIR=$env:DOCKERDIR"
Write-Host "BOOT2DOCKER_DIR=$env:BOOT2DOCKER_DIR"
Write-Host "DEVKITDIR=$env:DEVKITDIR"
Write-Host "VBOX_USER_HOME=$env:VBOX_USER_HOME"
Write-Host "VBOX_INSTALL_PATH=$env:VBOX_INSTALL_PATH"
Write-Host "KDIFF3DIR=$env:KDIFF3DIR"
Write-Host "CWRSYNCDIR=$env:CWRSYNCDIR"
Write-Host "CONEMUDIR=$env:CONEMUDIR"
Write-Host "ATOMDIR=$env:ATOMDIR"
Write-Host "APMDIR=$env:APMDIR"
Write-Host "PUTTYDIR=$env:PUTTYDIR"
Write-Host "CLINKDIR=$env:CLINKDIR"
Write-Host "VAGRANTDIR=$env:VAGRANTDIR"
Write-Host "VAGRANT_HOME=$env:VAGRANT_HOME"
Write-Host "TERRAFORMDIR=$env:TERRAFORMDIR"
Write-Host "PACKERDIR=$env:PACKERDIR"
Write-Host "CONSULDIR=$env:CONSULDIR"
Write-Host "GITDIR=$env:GITDIR"
Write-Host "GIT_CONF_USERNAME=$env:GIT_CONF_USERNAME"
Write-Host "GIT_CONF_EMAIL=$env:GIT_CONF_EMAIL"

set-alias vi "atom.cmd";
set-alias be "bundle exec";
set-alias b2d "boot2docker";

$env:Path = "$env:SCRIPTSDIR;$env:DOCKERDIR;$env:CHEFDK_PATH_ENTRIES;$env:CONSULDIR;$env:PACKERDIR;$env:TERRAFORMDIR;$env:VAGRANTDIR\bin;$env:KDIFF3DIR;$env:CWRSYNCDIR;$env:VAGRANTDIR\embedded\bin;$env:CONEMUDIR;$env:ATOMDIR;$env:APMDIR;$env:PUTTYDIR;$env:VBOX_INSTALL_PATH;$env:Path"
