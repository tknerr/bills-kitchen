@echo off

:: check if boot2docker is running
for /f "usebackq tokens=*" %%s in (`boot2docker status`) do (
  if %%s == running (
    echo The boot2docker VM is already running, doing nothing
    goto end
  )
)

SETLOCAL

:: make sure we are stopped
echo Making sure the boot2docker VM is stopped...
boot2docker halt

:: get the BK_ROOT as windows path
set BK_ROOT=%SCRIPT_DIR%
:: replace backward with forward slashes
set BK_ROOT_FWD_SLASH=%BK_ROOT:\=/%
:: convert drive letter to cygwin style (try c, d, e, w)
set BK_ROOT_DRIVE=%BK_ROOT_FWD_SLASH:C:/=/c/%
set BK_ROOT_DRIVE=%BK_ROOT_DRIVE:D:/=/d/%
set BK_ROOT_DRIVE=%BK_ROOT_DRIVE:E:/=/e/%
set BK_ROOT_DRIVE=%BK_ROOT_DRIVE:W:/=/w/%
:: okay, here we go
set BK_ROOT_CYGPATH=%BK_ROOT_DRIVE%


:: add the drive while the VM is still down
echo Adding shared folder "billskitchen" for hostpath %BK_ROOT%
VBoxManage sharedfolder add "boot2docker-vm" --name "billskitchen" --hostpath %BK_ROOT%

:: idempotently create the VM, bring it up
echo Bringing up the boot2docker VM...
boot2docker init
boot2docker up

:: mount drive inside vbox
echo Mounting the shared folder inside the VM to %BK_ROOT_CYGPATH%
boot2docker ssh -- sudo mount -t vboxsf billskitchen %BK_ROOT_CYGPATH%

:: set / unset proxy in boot2docker VM
:: for more on proxies, see http://stackoverflow.com/a/29303930/2388971
if "%BK_USE_PROXY%" == "1" (
  echo setting proxy in the boot2docker VM...
  boot2docker ssh "echo 'export HTTP_PROXY=%HTTP_PROXY%; export HTTPS_PROXY=%HTTPS_PROXY%; export NO_PROXY=%NO_PROXY%;' | sudo tee /var/lib/boot2docker/profile"
) else (
  echo making sure no proxy is set in the boot2docker VM...
  boot2docker ssh "sudo rm -rf /var/lib/boot2docker/profile"
)
boot2docker ssh "sudo /etc/init.d/docker restart > /dev/null"


ENDLOCAL


:: experimental: enable remote docker host patch in vagrant when b2d is started
set VAGRANT_DOCKER_REMOTE_HOST_PATCH=1

:end
