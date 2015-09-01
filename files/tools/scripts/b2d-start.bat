@echo off

:: check if we have the .iso file (if we don't have it, the VM won't start!)
if not exist %HOME%\.boot2docker\boot2docker.iso (
  echo boot2docker.iso not found in %HOME%\.boot2docker\, downloading version 1.7.1...
  if not exist "%HOME%\.boot2docker" mkdir %HOME%\.boot2docker
  curl -L -o %HOME%\.boot2docker\boot2docker.iso https://github.com/boot2docker/boot2docker/releases/download/v1.7.1/boot2docker.iso
)

:: check if "boot2docker-vm" exists already
for /f "usebackq tokens=*" %%l in (`VBoxManage list --long vms`) do (
  if "%%l" == "Name:            boot2docker-vm" (
    echo Found existing boot2docker-vm in VirtualBox!
    goto check
  )
)

:init
echo No existing boot2docker-vm found in VirtualBox, initializing...
boot2docker init --memory=2048

:check
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

:: check for existence of BK_ROOT env var
if "%BK_ROOT%" == "" (
  echo BK_ROOT env var not set, please make sure to run `set-env.bat` before! Exiting...
  exit /b 1
)

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

:: echo the config for debugging
::boot2docker config

:: bring it up
echo Bringing up the boot2docker VM...
boot2docker up

:: mount drive inside vbox
echo Mounting the shared folder inside the VM to %BK_ROOT_CYGPATH%
boot2docker ssh -- sudo mkdir -p %BK_ROOT_CYGPATH%
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
boot2docker ssh "sudo /etc/init.d/docker status"


ENDLOCAL



:: update the DOCKER_HOST as the ip address might change
for /f "usebackq tokens=*" %%s in (`boot2docker ip`) do set b2d_ip=%%s
echo updating DOCKER_HOST env var to "tcp://%b2d_ip%:2376"...
set DOCKER_HOST=tcp://%b2d_ip%:2376

:: echo the boot2docker / docker client versions
echo boot2docker version:
boot2docker ssh "docker -v"
echo docker client version:
docker -v


:end
