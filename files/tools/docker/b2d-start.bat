@echo off

:: idempotently create the VM, bring it up
boot2docker init
boot2docker up

:: for proxies:
:: see http://stackoverflow.com/a/29303930/2388971

:: init the shell
set DOCKER_HOST=tcp://192.168.59.103:2376
set DOCKER_CERT_PATH=%BOOT2DOCKER_DIR%\certs\boot2docker-vm
set DOCKER_TLS_VERIFY=1
