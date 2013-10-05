
$script:pwd = Split-Path $MyInvocation.MyCommand.Path

$env:RUBYDIR = Join-Path $pwd tools\ruby-1.9.3
$env:DEVKITDIR = Join-Path $pwd tools\devkit
$env:KDIFF3DIR = Join-Path $pwd tools\kdiff3
$env:CYGWINSSHDIR = Join-Path $pwd tools\cygwin-ssh
$env:CYGWINRSYNCDIR = Join-Path $pwd tools\cygwin-rsync
$env:CONEMUDIR = Join-Path $pwd tools\conemu
$env:SUBLIMEDIR = Join-Path $pwd tools\sublimetext2
$env:PUTTYDIR = Join-Path $pwd tools\putty
$env:VAGRANTDIR = Join-Path $pwd tools\vagrant\HashiCorp\Vagrant

## set %RI_DEVKIT$ env var and add DEVKIT to the PATH
invoke-expression (Join-Path $env:DEVKITDIR devkitvars.bat)

$env:HOME = Join-Path $pwd home

if($env:GITDIR -eq $NULL) {
	$env:GITDIR = Join-Path $pwd tools\portablegit
	$env:Path = "$env:Path;$(Join-Path $env:GITDIR "cmd")"
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

## toggle proxy based on env var
if($env:HTTP_PROXY -eq $NULL) {
  invoke-expression "$git config --global --unset http.proxy"
}
else {
  invoke-expression "$git config --global --replace http.proxy '$env:HTTP_PROXY'"
}
 
## don't let VirtualBox use %HOME% instead of %USERPROFILE%, 
## otherwise it would become confused when W:\ is unmounted 
$env:VBOX_USER_HOME = $env:USERPROFILE

## set VAGRANT_HOME explicitly, defaults to %USERPROFILE%
$env:VAGRANT_HOME = Join-Path $env:HOME ".vagrant.d"

## fix for http://code.google.com/p/msysgit/issues/detail?id=184,
## but use TERM=rxvt instead of TERM=msys to not break `vagrant ssh` terminal
$env:TERM = "rxvt"

## trick vagrant to detect colored output for windows, see here:
## https://github.com/mitchellh/vagrant/blob/7ef6c5d9d7d4753a219d3ab35afae0d475430cae/lib/vagrant/util/platform.rb#L89
$env:ANSICON = "true"

# show the environment
Write-Host "RUBYDIR=$env:RUBYDIR"
Write-Host "DEVKITDIR=$env:DEVKITDIR"
Write-Host "VBOX_USER_HOME=$env:VBOX_USER_HOME"
Write-Host "VBOX_INSTALL_PATH=$env:VBOX_INSTALL_PATH"
Write-Host "KDIFF3DIR=$env:KDIFF3DIR"
Write-Host "CYGWINSSHDIR=$env:CYGWINSSHDIR"
Write-Host "CYGWINRSYNCDIR=$env:CYGWINRSYNCDIR"
Write-Host "CONEMUDIR=$env:CONEMUDIR"
Write-Host "SUBLIMEDIR=$env:SUBLIMEDIR"
Write-Host "PUTTYDIR=$env:PUTTYDIR"
Write-Host "VAGRANTDIR=$env:VAGRANTDIR"
Write-Host "VAGRANT_HOME=$env:VAGRANT_HOME"
Write-Host "GITDIR=$env:GITDIR"
Write-Host "GIT_CONF_USERNAME=$env:GIT_CONF_USERNAME"
Write-Host "GIT_CONF_EMAIL=$env:GIT_CONF_EMAIL"
Write-Host "HTTP_PROXY=$env:HTTP_PROXY"

set-alias vi "sublime_text";
set-alias be "bundle exec"; 

$env:Path = "$env:VAGRANTDIR\bin;$env:RUBYDIR\bin;$env:KDIFF3DIR;$env:CYGWINRSYNCDIR;$env:CYGWINSSHDIR;$env:CONEMUDIR;$env:SUBLIMEDIR;$env:PUTTYDIR;$env:VBOX_INSTALL_PATH;$env:Path"
