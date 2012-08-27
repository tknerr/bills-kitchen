@echo off

:: ########################################################
:: # Setting up Environment...
:: ########################################################

set SCRIPT_DIR=%~dp0

:: for these we need the bin dirs in PATH
set VAGRANTDIR=%SCRIPT_DIR%tools\vagrant\vagrant\vagrant
set RUBYDIR=%VAGRANTDIR%\embedded
set KDIFF3DIR=%SCRIPT_DIR%tools\kdiff3
set CYGWINSSHDIR=%SCRIPT_DIR%tools\cygwin-ssh
set CYGWINRSYNCDIR=%SCRIPT_DIR%tools\cygwin-rsync
set CONSOLE2DIR=%SCRIPT_DIR%tools\console2\Console2
set SUBLIMEDIR=%SCRIPT_DIR%tools\sublimetext2
set PUTTYDIR=%SCRIPT_DIR%tools\putty

:: set devkit vars
call %RUBYDIR%\devkitvars.bat

:: use portable git, looks for %HOME%\.gitconfig 
set GITDIR=%SCRIPT_DIR%tools\portablegit
set HOME=%SCRIPT_DIR%home
:: set username/email
cmd /C %GITDIR%\cmd\git config --global --replace user.name %USERNAME%
cmd /C %GITDIR%\cmd\git config --global --replace user.email %USERNAME%@zuehlke.com
:: toggle proxy based on env var
if "%HTTP_PROXY%"=="" (
	cmd /C %GITDIR%\cmd\git config --global --unset http.proxy
) else (
	cmd /C %GITDIR%\cmd\git config --global --replace http.proxy %HTTP_PROXY%
)

:: don't let VirtualBox use %HOME% instead of %USERPROFILE%, 
:: otherwise it would become confused when W:\ is unmounted 
set VBOX_USER_HOME=%USERPROFILE%

:: fix for http://code.google.com/p/msysgit/issues/detail?id=184,
:: but use TERM=rxvt instead of TERM=msys to not break `vagrant ssh` terminal
set TERM=rxvt

:: make requires faster on Windows. If 'TRUE' the globally installed faster_require
:: in rubygems.rb (see https://github.com/rdp/faster_require/blob/master/README) 
:: is enabled, otherwise it will remain disabled 
set USE_FASTER_REQUIRE=TRUE
:: make sure we don't run into any problems after installing new gems via bundler
rmdir /S /Q %SCRIPT_DIR%home\.ruby_faster_require_cache

:: show the environment
echo VAGRANTDIR=%VAGRANTDIR%
echo RUBYDIR=%RUBYDIR%
echo VBOX_USER_HOME=%VBOX_USER_HOME%
echo VBOX_INSTALL_PATH=%VBOX_INSTALL_PATH%
echo KDIFF3DIR=%KDIFF3DIR%
echo CYGWINSSHDIR=%CYGWINSSHDIR%
echo CYGWINRSYNCDIR=%CYGWINRSYNCDIR%
echo CONSOLE2DIR=%CONSOLE2DIR%
echo SUBLIMEDIR=%SUBLIMEDIR%
echo PUTTYDIR=%PUTTYDIR%
echo GITDIR=%GITDIR%
echo HTTP_PROXY=%HTTP_PROXY%
echo USE_FASTER_REQUIRE=%USE_FASTER_REQUIRE%

:: command aliases
@doskey vi=sublime_text $*

set PATH=%VAGRANTDIR%\bin;%RUBYDIR%\bin;%GITDIR%\cmd;%KDIFF3DIR%;%CYGWINRSYNCDIR%;%CYGWINSSHDIR%;%CONSOLE2DIR%;%SUBLIMEDIR%;%PUTTYDIR%;%VBOX_INSTALL_PATH%;%PATH%