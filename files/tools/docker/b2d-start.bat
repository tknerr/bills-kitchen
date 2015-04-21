@echo off

:: idempotently create the VM, bring it up
boot2docker init
boot2docker up

:: for proxies:
:: see http://stackoverflow.com/a/29303930/2388971
