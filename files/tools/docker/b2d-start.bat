@echo off

:: idempotently create the VM, bring it up
boot2docker init
boot2docker up

:: for proxies:
:: see http://stackoverflow.com/a/29303930/2388971

:: init the shell
for /f "tokens=2" %%i in ('boot2docker shellinit') do set %%i
