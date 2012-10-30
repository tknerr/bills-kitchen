
$script:pwd = Split-Path $MyInvocation.MyCommand.Path

$env:VAGRANTDIR = Join-Path $pwd tools\vagrant\vagrant\vagrant
$env:RUBYDIR = Join-Path $env:VAGRANTDIR embedded
$env:KDIFF3DIR = Join-Path $pwd tools\kdiff3
$env:CYGWINSSHDIR = Join-Path $pwd tools\cygwin-ssh
$env:CYGWINRSYNCDIR = Join-Path $pwd tools\cygwin-rsync
$env:CONSOLE2DIR = Join-Path $pwd tools\console2\Console2
$env:SUBLIMEDIR = Join-Path $pwd tools\sublimetext2
$env:PUTTYDIR = Join-Path $pwd tools\putty

## set devkit vars
invoke-expression (Join-Path $env:RUBYDIR devkitvars.bat)

## use portable git, looks for %HOME%\.gitconfig 
$env:GITDIR = Join-Path $pwd tools\portablegit
$env:HOME = Join-Path $pwd home

## set git executable path
$script:git = Join-Path (Join-Path $env:GITDIR "cmd") "git"

## set git username
$username = invoke-expression "$git config --get user.name"
if($username -eq "") {
  $username = "Not Set"
}
$username = Read-Host "Enter Fullname($username)"
if($username) {
  invoke-expression "$git config --global user.name '$username'"
}

## set git email
$email = invoke-expression "$git config --get user.email"
if($email -eq "") {
  $email = "Not Set"
}
$email = Read-Host "Enter Email($email)"
if($email) {
  invoke-expression "$git config --global user.email '$email'"
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

## fix for http://code.google.com/p/msysgit/issues/detail?id=184,
## but use TERM=rxvt instead of TERM=msys to not break `vagrant ssh` terminal
$env:TERM = "rxvt"

## make requires faster on Windows. If '$TRUE' the globally installed faster_require
## in rubygems.rb (see https://github.com/rdp/faster_require/blob/master/README) 
## is enabled, otherwise it will remain disabled 
$env:USE_FASTER_REQUIRE_GLOBALLY = $FALSE

# show the environment
Write-Host "VAGRANTDIR=$env:VAGRANTDIR"
Write-Host "RUBYDIR=$env:RUBYDIR"
Write-Host "VBOX_USER_HOME=$env:VBOX_USER_HOME"
Write-Host "VBOX_INSTALL_PATH=$env:VBOX_INSTALL_PATH"
Write-Host "KDIFF3DIR=$env:KDIFF3DIR"
Write-Host "CYGWINSSHDIR=$env:CYGWINSSHDIR"
Write-Host "CYGWINRSYNCDIR=$env:CYGWINRSYNCDIR"
Write-Host "CONSOLE2DIR=$env:CONSOLE2DIR"
Write-Host "SUBLIMEDIR=$env:SUBLIMEDIR"
Write-Host "PUTTYDIR=$env:PUTTYDIR"
Write-Host "GITDIR=$env:GITDIR"
Write-Host "HTTP_PROXY=$env:HTTP_PROXY"
Write-Host "USE_FASTER_REQUIRE_GLOBALLY=$env:USE_FASTER_REQUIRE_GLOBALLY"

$env:Path = "$env:VAGRANTDI\bin;$env:RUBYDIR\bin;$env:GITDIR\cmd;$env:KDIFF3DIR;$env:CYGWINRSYNCDIR;$env:CYGWINSSHDIR;$env:CONSOLE2DIR;$env:SUBLIMEDIR;$env:PUTTYDIR;$env:VBOX_INSTALL_PATH;$env:Path"