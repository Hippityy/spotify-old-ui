@echo off

:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

set "RESPONSE="

mode con cols=80 lines=9
title Choose a response:

goto 'input'

: 'input'
echo [1] Disable updates on Spotify
echo [2] Re-enable updates on Spotify
echo [3] Install old UI Spotify (and turn off updates)
echo [4] Exit
echo.
echo Note: Does not work on Spotify client installed through the Microsoft Store.
echo. 
set /p response=What would you like to do? [1/2/3/4] 
if /I %response%==1 goto 'forcenoupdate'
if /I %response%==2 goto 'allowupdate'
if /I %response%==3 goto 'installoldspotify'
if /I %response%==4 goto 'end'
goto 'input'

: 'forcenoupdate'
title Updates disabled
echo y | del %localappdata%\Spotify\Update
mkdir %localappdata%\Spotify\Update
icacls %localappdata%\Spotify\Update /deny "%username%":D
icacls %localappdata%\Spotify\Update /deny "%username%":R
cls
echo Done.
echo.
pause
goto 'input'

: 'allowupdate'
title Updates re-enabled
icacls %localappdata%\Spotify\Update /reset /T
cls
echo Done.
echo.
pause
goto 'input'

: 'installoldspotify'
explorer %~dp0spotify.exe
goto 'forcenoupdate'

: 'end'
exit