@echo off
setlocal enabledelayedexpansion

:: Displaying time on console
echo  Start time - %TIME%

:: making directory to store results
:: name of the directory is as"usermame_hostname"
set "username=%USERNAME%"
set "hostname=%COMPUTERNAME%"
set "directoryName=%username%_%hostname%"
mkdir "%directoryName%"

:: reading names of suspicious files from a text file
set "sourceFile=suspicious_files.txt"
set destinationDirectory="%directoryName%"

:: copying suspicious file to newly created directory
copy "%sourceFile%" "%destinationDirectory%"


:: writing all the files present in C: directory to a text file
echo Stage 1:
echo Extracting all files in C: directory
(for /r "C:\" %%A in (*) do (
    echo %%A
)) > "%directoryName%"/allfiles.txt

echo All filespaths written in allfiles.txt


:: greping all the matched filepaths who have substring from suspicious files list
echo %TIME%
echo Stage 2: %TIME%

cd "%directoryName%"

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
set "substringFile=iocs.txt"
set "outputFile=output.txt"

echo %TIME%
echo Stage 3: %TIME%

:: removing the false positives by sanitising the results

echo Sanitizing results in "%inputFile1%":


(for /f "delims=" %%A in (%inputFile1%) do (
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
    
))

echo Results saved to "%outputFile%"

:: deleting the staging files
del stage1.txt
del iocs.txt
echo Endtime- %TIME%
