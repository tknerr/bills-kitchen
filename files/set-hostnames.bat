@echo off

:: #############################################################
:: # Updates %SYSTEMDRIVE%/Windows/System32/drivers/etc/hosts
:: #############################################################
::
:: NOTE: this script will ask for elevated user rights
::

set SCRIPT_DIR=%~dp0
set TEMP_DIR=%TMP%\hostsedit
set ACTION=update

echo updating hostnames in %SYSTEMDRIVE%/Windows/System32/drivers/etc/hosts

::
:: XXX: subst'ed drives are not visible in elevated mode, 
:: thus we need to copy everything to %TMP% and execute it there
::
xcopy %SCRIPT_DIR%tools\hostsedit "%TEMP_DIR%" /I /Y /E
> %TEMP_DIR%\update_hosts.bat (
	@echo @echo off
	@echo %TEMP_DIR%\hostsedit %ACTION% "chef-server 	chef-server.local" 		33.33.3.10
	@echo %TEMP_DIR%\hostsedit %ACTION% "bare-os-image 	bare-os-image.local" 	33.33.3.11
)
%TEMP_DIR%\elevate %TEMP_DIR%\update_hosts.bat
rmdir "%TEMP_DIR%" /S /Q
