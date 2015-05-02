@echo off

:: check if boot2docker is running
for /f "usebackq tokens=*" %%s in (`boot2docker status`) do (
  if %%s == poweroff (
    echo The boot2docker VM is already stopped, doing nothing
    goto end
  )
)

:: halt the VM, don't destroy it (try twice, as it often fails on 1st attempt)
echo Shutting down the boot2docker VM...
::boot2docker down
boot2docker down 2>NUL || boot2docker down

echo Removing shared folder "billskitchen"
VBoxManage sharedfolder remove "boot2docker-vm" --name "billskitchen"


:: disable experimental remote docker host patch when b2d is stopped
set VAGRANT_DOCKER_REMOTE_HOST_PATCH=0

:end
