
@echo off

:: indicate that a proxy should be used
set BK_USE_PROXY=1

:: set the proxy on the host system
set HTTP_PROXY=http://10.12.1.230:8083
set HTTPS_PROXY=https://10.12.1.230:8083
set NO_PROXY=localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16

:: reuse the host proxy in vagrant VMs
set VAGRANT_HTTP_PROXY=%HTTP_PROXY%
set VAGRANT_HTTPS_PROXY=%HTTPS_PROXY%
set VAGRANT_NO_PROXY=%NO_PROXY%
