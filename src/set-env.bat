@echo off

:: ########################################################
:: # Setting up Environment...
:: ########################################################

set SCRIPT_DIR=%~dp0

:: for these we need the bin dirs in PATH
set VAGRANTDIR=%SCRIPT_DIR%tools\vagrant
set RUBYDIR=%SCRIPT_DIR%tools\vagrant\embedded
set P4MERGEDIR=%SCRIPT_DIR%tools\p4merge
set NPPPDIR=%SCRIPT_DIR%tools\notepad++
set PUTTYDIR=%SCRIPT_DIR%tools\putty
set OPENSSHDIR=%SCRIPT_DIR%tools\sshwindows
set CONSOLE2DIR=%SCRIPT_DIR%tools\console2
set SUBLIMEDIR=%SCRIPT_DIR%tools\sublimetext2

:: use portable git, looks for %HOME%\.gitconfig 
set GITDIR=%SCRIPT_DIR%tools\portablegit-1.7.4-preview
set HOME=%SCRIPT_DIR%home
:: set username/email
cmd /C %GITDIR%\cmd\git config --global --replace user.name %USERNAME%
cmd /C %GITDIR%\cmd\git config --global --replace user.email %USERNAME%@zuehlke.com

:: don't let VirtualBox use %HOME% instead of %USERPROFILE%, 
:: otherwise it would become confused when W:\ is unmounted 
set VBOX_USER_HOME=%USERPROFILE%

:: show the environment
echo VAGRANTDIR=%VAGRANTDIR%
echo RUBYDIR=%RUBYDIR%
echo PUTTYDIR=%PUTTYDIR%
echo VBOX_USER_HOME=%VBOX_USER_HOME%
echo VBOX_INSTALL_PATH=%VBOX_INSTALL_PATH%
echo P4MERGEDIR=%P4MERGEDIR%
echo NPPPDIR=%NPPPDIR%
echo OPENSSHDIR=%OPENSSHDIR%
echo CONSOLE2DIR=%CONSOLE2DIR%
echo SUBLIMEDIR=%SUBLIMEDIR%

:: command aliases
@doskey vi=sublime_text $*

set PATH=%VAGRANTDIR%\bin;%RUBYDIR%\bin;%NPPPDIR%;%GITDIR%\cmd;%P4MERGEDIR%;%PUTTYDIR%;%OPENSSHDIR%;%CONSOLE2DIR%;%SUBLIMEDIR%;%VBOX_INSTALL_PATH%;%PATH%