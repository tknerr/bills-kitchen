@echo off

:: ########################################################
:: # Setting up Environment...
:: ########################################################

set BK_ROOT=%~dp0

:: for these we need the bin dirs in PATH
set SCRIPTSDIR=%BK_ROOT%tools\scripts
set DOCKERDIR=%BK_ROOT%tools\docker
set DEVKITDIR=%BK_ROOT%tools\devkit
set KDIFF3DIR=%BK_ROOT%tools\kdiff3
set CWRSYNCDIR=%BK_ROOT%tools\cwrsync\cwRsync_5.4.1_x86_Free
set CONEMUDIR=%BK_ROOT%tools\conemu
set ATOMDIR=%BK_ROOT%tools\atom\Atom\resources\cli
set APMDIR=%BK_ROOT%tools\atom\Atom\resources\app\apm\bin
set PUTTYDIR=%BK_ROOT%tools\putty
set CLINKDIR=%BK_ROOT%tools\clink
set VAGRANTDIR=%BK_ROOT%tools\vagrant\HashiCorp\Vagrant
set TERRAFORMDIR=%BK_ROOT%tools\terraform
set PACKERDIR=%BK_ROOT%tools\packer
set CONSULDIR=%BK_ROOT%tools\consul
set CHEFDKDIR=%BK_ROOT%tools\chefdk
set CHEFDKHOMEDIR=%BK_ROOT%home\.chefdk

:: inject clink into current cmd.exe
:: call %CLINKDIR%\clink.bat inject

:: set %RI_DEVKIT$ env var and add DEVKIT to the PATH
call %DEVKITDIR%\devkitvars.bat

:: use portable git, looks for %HOME%\.gitconfig
set GITDIR=%BK_ROOT%tools\portablegit
set HOME=%BK_ROOT%home

:: set ATOM_HOME to make it devpack-local
set ATOM_HOME=%HOME%\.atom

:: set atom as the default EDITOR
set EDITOR=atom.sh --wait

:: set the home dir for boot2docker
set BOOT2DOCKER_DIR=%HOME%\.boot2docker

:: init the shell for boot2docker
set DOCKER_HOST=tcp://192.168.59.103:2376
set DOCKER_CERT_PATH=%BOOT2DOCKER_DIR%\certs\boot2docker-vm
set DOCKER_TLS_VERIFY=1

:: experimental: enable remote docker host patch in vagrant
set VAGRANT_DOCKER_REMOTE_HOST_PATCH=1

:: Chef-DK embedded Ruby is now the primary one!
:: see: http://jtimberman.housepub.org/blog/2014/04/30/chefdk-and-ruby/
:: see: `chef shell-init powershell`
set GEM_ROOT=%CHEFDKDIR%\embedded\lib\ruby\gems\2.1.0
set GEM_HOME=%CHEFDKHOMEDIR%\gem\ruby\2.1.0
set GEM_PATH=%GEM_HOME%;%GEM_ROOT%
:: that's how the PATH entries are generated for chef shell-init
set CHEFDK_PATH_ENTRIES=%CHEFDKDIR%\bin;%CHEFDKHOMEDIR%\gem\ruby\2.1.0\bin;%CHEFDKDIR%\embedded\bin

:: also set the newly introduced (as of ChefDK 0.7.0) CHEFDK_HOME environment
set CHEFDK_HOME=%CHEFDKHOMEDIR%


:: prompt for .gitconfig username/email
FOR /F "usebackq tokens=*" %%a IN (`cmd /C %GITDIR%\cmd\git config --get user.name`) DO SET GIT_CONF_USERNAME=%%a
if "%GIT_CONF_USERNAME%"=="" (
  set /p GIT_CONF_USERNAME="Your Name (will be written to %HOME%\.gitconfig):"
)
FOR /F "usebackq tokens=*" %%a IN (`cmd /C %GITDIR%\cmd\git config --get user.email`) DO SET GIT_CONF_EMAIL=%%a
if "%GIT_CONF_EMAIL%"=="" (
  set /p GIT_CONF_EMAIL="Your Email (will be written to %HOME%\.gitconfig):"
)
:: write to .gitconfig
cmd /C %GITDIR%\cmd\git config --global --replace user.name "%GIT_CONF_USERNAME%"
cmd /C %GITDIR%\cmd\git config --global --replace user.email "%GIT_CONF_EMAIL%"


:: don't let VirtualBox use %HOME% instead of %USERPROFILE%,
:: otherwise it would become confused when W:\ is unmounted
set VBOX_USER_HOME=%USERPROFILE%

:: set VAGRANT_HOME explicitly, defaults to %USERPROFILE%
set VAGRANT_HOME=%HOME%\.vagrant.d

:: set proper TERM to not break `vagrant ssh` terminal,
:: see https://github.com/tknerr/bills-kitchen/issues/64
set TERM=cygwin

:: trick vagrant to detect colored output for Windows, see here:
:: https://github.com/mitchellh/vagrant/blob/7ef6c5d9d7d4753a219d3ab35afae0d475430cae/lib/vagrant/util/platform.rb#L89
set ANSICON=true

:: add recent root certificates to prevent SSL errors on Windows, see:
:: https://gist.github.com/fnichol/867550
set SSL_CERT_FILE=%HOME%\cacert.pem

:: mute the cygwin warning which otherwise comes on `vagrant ssh`
set CYGWIN=nodosfilewarning

:: show the environment
echo BK_ROOT=%BK_ROOT%
echo HOME=%HOME%
echo SCRIPTSDIR=%SCRIPTSDIR%
echo CHEFDKDIR=%CHEFDKDIR%
echo CHEFDKHOMEDIR=%CHEFDKHOMEDIR%
echo GEM_ROOT=%GEM_ROOT%
echo GEM_HOME=%GEM_HOME%
echo GEM_PATH=%GEM_PATH%
echo DOCKERDIR=%DOCKERDIR%
echo BOOT2DOCKER_DIR=%BOOT2DOCKER_DIR%
echo DEVKITDIR=%DEVKITDIR%
echo VBOX_USER_HOME=%VBOX_USER_HOME%
echo VBOX_INSTALL_PATH=%VBOX_INSTALL_PATH%
echo VBOX_MSI_INSTALL_PATH=%VBOX_MSI_INSTALL_PATH%
echo KDIFF3DIR=%KDIFF3DIR%
echo CWRSYNCDIR=%CWRSYNCDIR%
echo CONEMUDIR=%CONEMUDIR%
echo ATOMDIR=%ATOMDIR%
echo APMDIR=%APMDIR%
echo PUTTYDIR=%PUTTYDIR%
echo CLINKDIR=%CLINKDIR%
echo VAGRANTDIR=%VAGRANTDIR%
echo TERRAFORMDIR=%TERRAFORMDIR%
echo PACKERDIR=%PACKERDIR%
echo CONSULDIR=%CONSULDIR%
echo VAGRANT_HOME=%VAGRANT_HOME%
echo GITDIR=%GITDIR%
echo GIT_CONF_USERNAME=%GIT_CONF_USERNAME%
echo GIT_CONF_EMAIL=%GIT_CONF_EMAIL%

:: command aliases
@doskey vi=atom.cmd $*
@doskey be=bundle exec $*
@doskey b2d=boot2docker $*

set PATH=%SCRIPTSDIR%;%DOCKERDIR%;%CHEFDK_PATH_ENTRIES%;%CONSULDIR%;%PACKERDIR%;%TERRAFORMDIR%;%VAGRANTDIR%\bin;%GITDIR%\cmd;%GITDIR%;%KDIFF3DIR%;%CWRSYNCDIR%;%VAGRANTDIR%\embedded\bin;%CONEMUDIR%;%ATOMDIR%;%APMDIR%;%PUTTYDIR%;%VBOX_MSI_INSTALL_PATH%;%VBOX_INSTALL_PATH%;%PATH%
