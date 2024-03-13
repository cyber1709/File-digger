@echo off
setlocal enabledelayedexpansion

echo Start time - %TIME%

set "username=%USERNAME%"
set "hostname=%COMPUTERNAME%"
set "directoryName=%username%_%hostname%"

mkdir "%directoryName%"

set "sourceFile=iocs.txt"
set "destinationDirectory=%directoryName%"

copy "%sourceFile%" "%destinationDirectory%"

echo Stage 1:
echo Extracting all files in C: directory
(for /r "C:\" %%A in (*) do (
    echo %%A
)) > "%destinationDirectory%\allfiles.txt"

echo All file paths written in allfiles.txt

echo %TIME%
echo Stage 2: %TIME%

cd "%destinationDirectory%"

REM Start System Info retrieval

REM Write date and time to a text file
echo Getting Date and time
echo Date: %date% > system_audit_info.txt
echo Time: %time% >> system_audit_info.txt

set num_users=0
REM Get number of all users
for /f "skip=4 delims=" %%i in ('net user ^| find /v "command completed successfully."') do set /a "num_users+=1"

REM Write number of all users to the text file
echo Number of all users: %num_users% >> system_audit_info.txt

REM Get name of logged-in user
echo Logged-in user: %USERNAME% >> system_audit_info.txt

REM Get full username
for /f "tokens=2 delims==\ " %%U in ('wmic useraccount where name="%USERNAME%" get fullname /value ^| find "="') do (
    echo Full username: %%U >> system_audit_info.txt
)

REM Get hostname of the computer
echo Hostname: %COMPUTERNAME% >> system_audit_info.txt

REM Get OS name
for /f "tokens=2 delims==" %%O in ('wmic os get Caption /value ^| find "="') do (
    echo Operating System: %%O >> system_audit_info.txt
)

REM Get OS install date
for /f "tokens=2 delims==" %%I in ('wmic os get InstallDate /value ^| find "="') do (
    set "InstallDate=%%I"
)

REM Convert install date to a more readable format (YYYYMMDD)
set "InstallDate=%InstallDate:~0,4%-%InstallDate:~4,2%-%InstallDate:~6,2% %InstallDate:~8,2%:%InstallDate:~10,2%:%InstallDate:~12,2%"
echo OS Install Date: %InstallDate% >> system_audit_info.txt

REM Check if we have administrative privileges
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo Error: Administrative privileges required. Please run this script as an administrator.
    pause
    exit /b
)

REM Query Security Policy for password complexity setting
for /F "tokens=2 delims=:" %%A in ('net accounts ^| findstr /C:"Minimum password length"') do (
    set "MinPasswordLength=%%A"
)

REM Check if password complexity is enforced (Minimum 8 characters containing alphanumeric characters)
if %MinPasswordLength% geq 8 (
    echo Password complexity: Minimum 8 characters containing alphanumeric characters. >> system_audit_info.txt
) else (
    echo Password complexity: Not enforced. >> system_audit_info.txt
)

REM Check if screen saver is enabled and write the result to system_audit_info.txt
reg query "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveActive > nul 2>&1
if %errorlevel% equ 0 (
    echo Screen saver is enabled. >> system_audit_info.txt
) else (
    echo Screen saver is not enabled. >> system_audit_info.txt
)

REM Check if internet is connected by pinging a well-known website
ping -n 1 google.com > nul 2>&1
if %errorlevel% equ 0 (
    echo Internet is connected. >> system_audit_info.txt
) else (
    echo Internet is not connected. >> system_audit_info.txt
)

REM Get public IP address
for /f "tokens=2 delims=:" %%a in ('nslookup myip.opendns.com resolver1.opendns.com ^| findstr "Address"') do (
    echo Public IP address: %%a >> ip_allocated.txt
)

REM Get local IP address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4 Address"') do (
    echo Local IP address: %%a >> ip_allocated.txt
)

echo Screen saver status checked, internet connection status, public and local IP addresses saved to system_audit_info.txt.

REM Check if we have administrative privileges
>nul 2>&1 net session
if %errorlevel% equ 0 (
    echo User privilege: Administrator >> system_audit_info.txt
) else (
    echo User privilege: Limited >> system_audit_info.txt
)

echo User privileges checked and saved to system_audit_info.txt.

REM Get MAC address
for /f "tokens=2 delims= " %%m in ('getmac /fo table /nh') do (
    echo MAC address: %%m >> mac_address_present.txt
)

REM Check if the guest account is enabled
net user guest > nul 2>&1
if %errorlevel% equ 0 (
    echo Guest account is enabled. >> system_audit_info.txt
) else (
    echo Guest account is not enabled. >> system_audit_info.txt
)

REM Check if Remote Desktop is enabled
reg query "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections > nul 2>&1
if %errorlevel% equ 0 (
    reg query "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections | findstr "REG_DWORD.*0x0" > nul 2>&1
    if %errorlevel% equ 0 (
        echo Remote Desktop is enabled. >> system_audit_info.txt
    ) else (
        echo Remote Desktop is not enabled. >> system_audit_info.txt
    )
) else (
    echo Unable to determine Remote Desktop status. >> system_audit_info.txt
)

REM Check if autoplay is enabled
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun > nul 2>&1
if %errorlevel% equ 0 (
    reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun | findstr "0x0" > nul 2>&1
    if %errorlevel% equ 0 (
        echo Autoplay is enabled. >> system_audit_info.txt
    ) else (
        echo Autoplay is not enabled. >> system_audit_info.txt
    )
) else (
    echo Unable to determine Autoplay status. >> system_audit_info.txt
)

REM Check if Windows Firewall is enabled
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v EnableFirewall > nul 2>&1
if %errorlevel% equ 0 (
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v EnableFirewall | findstr "REG_DWORD.*0x1" > nul 2>&1
    if %errorlevel% equ 0 (
        echo Windows Firewall is enabled. >> system_audit_info.txt
    ) else (
        echo Windows Firewall is disabled. >> system_audit_info.txt
    )
) else (
    echo Unable to determine Windows Firewall status. >> system_audit_info.txt
)

REM Check for installed antivirus software and display its name
echo Checking for antivirus software...
wmic /namespace:\\root\SecurityCenter2 path antivirusproduct get /value | findstr /i /c:"displayName" > nul 2>&1
if %errorlevel% equ 0 (
    echo Antivirus software is present. >> system_audit_info.txt
) else (
    echo Antivirus software is not present. >> system_audit_info.txt
)

wmic /namespace:\\root\SecurityCenter2 path antivirusproduct get displayName /value | findstr /i "displayName" > nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=2 delims==" %%a in ('wmic /namespace:\\root\SecurityCenter2 path antivirusproduct get displayName /value ^| findstr /i "displayName"') do (
        echo Antivirus software present: %%a >> antivirus_present.txt
    )
)

REM Check if Automatic Updates are enabled
reg query "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate > nul 2>&1
if %errorlevel% equ 0 (
    reg query "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate | findstr "0x0" > nul 2>&1
    if %errorlevel% equ 0 (
        echo Automatic Updates are enabled. >> system_audit_info.txt
    ) else (
        echo Automatic Updates are not enabled. >> system_audit_info.txt
    )
) else (
    echo Unable to determine Automatic Updates status. >> system_audit_info.txt
)

REM Check for USB devices ever connected
echo Checking for USB devices...
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s > usb_devices.txt

REM Get list of all third-party apps installed in the system
echo Getting list of third-party apps...
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s | findstr "DisplayName" | findstr /v "Microsoft" > third_party_apps.txt

systeminfo >> system-info.txt
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run >> registry-run-system.txt 2>NUL
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run >> registry-run-users.txt 2>NUL

reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce >> registry-runonce-system.txt 2>NUL
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce >> registry-runonce-users.txt 2>NUL

reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEX >> registry-runonce-ex.txt 2>NUL

reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" >> registry-winlogon.txt 2>NUL

reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\ >> registry-policies-explorer-system.txt 2>NUL
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\ >> registry-policies-explorer-users.txt 2>NUL

reg query "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" >> registry-current-version.txt 2>NUL
dir "%USERPROFILE%\Start Menu\Programs\Startup" >> startup1.txt 2>NUL
dir "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" >> app-roaming.txt 2>NUL
dir "%windir%\Windows\Profiles\%username%\Start Menu\Programs\Startup" >> startup2.txt 2>NUL

schtasks /query >> sch-tasks.txt 2>NUL

dir/a/s %windir%\prefetch >> prefetch.txt 2>NUL

ipconfig/all >> ipconfig-all.txt 2>NUL

ipconfig/displaydns >> ipconfig-all-dns.txt 2>NUL

type %windir%\system32\drivers\etc\hosts >> hosts.txt 2>NUL

reg query HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces /s >> registry-interfaces.txt 2>NUL

netstat -an >> netstat.txt 2>NUL

reg query HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR /s >> registry-enum.txt 2>NUL

tasklist /SVC >> tasklist.txt 2>NUL

net users >> users.txt 2>NUL

net share >> share.txt 2>NUL
net view \\%COMPUTERNAME% >> comp-name.txt 2>NUL

nbtstat -s >> nbstat-s.txt 2>NUL
nbtstat -n >> nbstat-n.txt 2>NUL
nbtstat -c >> nbstat-c.txt 2>NUL

dir/a/s %temp% >> temp.txt 2>NUL

REM End System info retrieval

set "inputFile=allfiles.txt"
set "substringFile=iocs.txt"
set "outputFile=stage1.txt"

if not exist "%inputFile%" (
    echo Input file not found.
    exit /b 1
)

if not exist "%substringFile%" (
    echo Substring file not found.
    exit /b 1
)

echo Matching Lines in "%inputFile%" containing substrings from "%substringFile%":

rem Clear the output file
echo. > "%outputFile%"

for /f "tokens=*" %%b in ('type "%substringFile%"') do (
    set "substring=%%b"
    type allfiles.txt | findstr /i /c:"!substring!" >> %outputFile%
)

set "inputFile1=stage1.txt"
set "outputFile=output.txt"

echo %TIME%
echo Stage 3: %TIME%

echo Sanitizing results in "%inputFile1%":

rem Clear the output file
echo. > "%outputFile%"

for /f "delims=" %%A in (%inputFile1%) do (
    set "filepath=%%A"
    for %%B in (!filepath!) do set "filename=%%~nxB"

    rem Compare with substrings
    set "matched="
    for /f "delims=" %%C in (%substringFile%) do (
        set "substring=%%C"
        if /i "!filename!" equ "!substring!" (
            set "matched=!filepath!"
            echo !filepath!
            echo !filepath! >> %outputFile%
        )
    )
)

echo Results saved to "%outputFile%"
del stage1.txt
del iocs.txt
echo Endtime- %TIME%

cd ..\

Deps\7z.exe a %directoryName%.zip %directoryName% -p hazy@sky >nul

rmdir /s/q %directoryName%
