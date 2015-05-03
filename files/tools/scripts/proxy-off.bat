
@echo off

:: remove the indicator
set BK_USE_PROXY=

:: unset the proxy on the host system
set HTTP_PROXY=
set HTTPS_PROXY=
set NO_PROXY=

:: unset reusing the host proxy in vagrant VMs
set VAGRANT_HTTP_PROXY=
set VAGRANT_HTTPS_PROXY=
set VAGRANT_NO_PROXY=
