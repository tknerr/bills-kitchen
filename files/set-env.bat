@echo off

:: ########################################################
:: # Setting up Environment...
:: ########################################################

set SCRIPT_DIR=%~dp0

:: for these we need the bin dirs in PATH
set DEVKITDIR=%SCRIPT_DIR%tools\devkit
set KDIFF3DIR=%SCRIPT_DIR%tools\kdiff3
set CYGWINSSHDIR=%SCRIPT_DIR%tools\cygwin-ssh
set CYGWINRSYNCDIR=%SCRIPT_DIR%tools\cygwin-rsync
set CONEMUDIR=%SCRIPT_DIR%tools\conemu
set ATOMDIR=%SCRIPT_DIR%tools\atom\Atom\resources\cli
set APMDIR=%SCRIPT_DIR%tools\atom\Atom\resources\app\apm\bin
set PUTTYDIR=%SCRIPT_DIR%tools\putty
set CLINKDIR=%SCRIPT_DIR%tools\clink
set VAGRANTDIR=%SCRIPT_DIR%tools\vagrant\HashiCorp\Vagrant
set TERRAFORMDIR=%SCRIPT_DIR%tools\terraform
set PACKERDIR=%SCRIPT_DIR%tools\packer
set CONSULDIR=%SCRIPT_DIR%tools\consul
set CHEFDKDIR=%SCRIPT_DIR%tools\chefdk
set CHEFDKHOMEDIR=%SCRIPT_DIR%home\.chefdk

:: inject clink into current cmd.exe
:: call %CLINKDIR%\clink.bat inject

:: set %RI_DEVKIT$ env var and add DEVKIT to the PATH
call %DEVKITDIR%\devkitvars.bat

:: use portable git, looks for %HOME%\.gitconfig
set GITDIR=%SCRIPT_DIR%tools\portablegit
set HOME=%SCRIPT_DIR%home

:: set ATOM_HOME to make it devpack-local
set ATOM_HOME=%HOME%\.atom

:: set atom as the default EDITOR
set EDITOR=atom.sh --wait

:: Chef-DK embedded Ruby is now the primary one!
:: see: http://jtimberman.housepub.org/blog/2014/04/30/chefdk-and-ruby/
:: see: `chef shell-init powershell`
set GEM_ROOT=%CHEFDKDIR%\embedded\lib\ruby\gems\2.0.0
set GEM_HOME=%CHEFDKHOMEDIR%\gem\ruby\2.0.0
set GEM_PATH=%GEM_HOME%;%GEM_ROOT%
:: that's how the PATH entries are generated for chef shell-init
set CHEFDK_PATH_ENTRIES=%CHEFDKDIR%\bin;%CHEFDKHOMEDIR%\gem\ruby\2.0.0\bin;%CHEFDKDIR%\embedded\bin


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

:: toggle proxy based on env var
if "%HTTP_PROXY%"=="" (
  cmd /C %GITDIR%\cmd\git config --global --unset http.proxy
) else (
  cmd /C %GITDIR%\cmd\git config --global --replace http.proxy %HTTP_PROXY%
)

:: don't let VirtualBox use %HOME% instead of %USERPROFILE%,
:: otherwise it would become confused when W:\ is unmounted
set VBOX_USER_HOME=%USERPROFILE%

:: set VAGRANT_HOME explicitly, defaults to %USERPROFILE%
set VAGRANT_HOME=%HOME%\.vagrant.d

:: set proper TERM to not break `vagrant ssh` terminal,
:: see https://github.com/tknerr/bills-kitchen/issues/64
set TERM=cygwin

:: trick vagrant to detect colored output for windows, see here:
:: https://github.com/mitchellh/vagrant/blob/7ef6c5d9d7d4753a219d3ab35afae0d475430cae/lib/vagrant/util/platform.rb#L89
set ANSICON=true

:: add recent root certificates to prevent SSL errors on Windos, see:
:: https://gist.github.com/fnichol/867550
set SSL_CERT_FILE=%HOME%\cacert.pem

:: mute the cygwin warning which otherwise comes on `vagrant ssh`
set CYGWIN=nodosfilewarning

:: show the environment
echo HOME=%HOME%
echo CHEFDKDIR=%CHEFDKDIR%
echo CHEFDKHOMEDIR=%CHEFDKHOMEDIR%
echo GEM_ROOT=%GEM_ROOT%
echo GEM_HOME=%GEM_HOME%
echo GEM_PATH=%GEM_PATH%
echo DEVKITDIR=%DEVKITDIR%
echo VBOX_USER_HOME=%VBOX_USER_HOME%
echo VBOX_INSTALL_PATH=%VBOX_INSTALL_PATH%
echo VBOX_MSI_INSTALL_PATH=%VBOX_MSI_INSTALL_PATH%
echo KDIFF3DIR=%KDIFF3DIR%
echo CYGWINSSHDIR=%CYGWINSSHDIR%
echo CYGWINRSYNCDIR=%CYGWINRSYNCDIR%
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
echo HTTP_PROXY=%HTTP_PROXY%

:: command aliases
@doskey vi=atom.cmd $*
@doskey be=bundle exec $*

set PATH=%CHEFDK_PATH_ENTRIES%;%CONSULDIR%;%PACKERDIR%;%TERRAFORMDIR%;%VAGRANTDIR%\bin;%GITDIR%\cmd;%GITDIR%;%KDIFF3DIR%;%CYGWINRSYNCDIR%;%CYGWINSSHDIR%;%VAGRANTDIR%\embedded\bin;%CONEMUDIR%;%ATOMDIR%;%APMDIR%;%PUTTYDIR%;%VBOX_MSI_INSTALL_PATH%;%VBOX_INSTALL_PATH%;%PATH%
