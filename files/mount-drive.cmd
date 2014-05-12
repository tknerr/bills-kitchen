
:: get path to this script
set SCRIPT_DIR=%~dp0
:: ugh, need to remove trailing '\'
set MOUNT_PATH=%SCRIPT_DIR:~0,-1%

subst w: "%MOUNT_PATH%" 