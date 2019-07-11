@echo off
setlocal
rem Reference: https://github.com/Microsoft/vscode/issues/56326

rem Dependency binary configuration
set WGET_PATH=E:\Programs\wget
set SEVENZA_PATH=E:\Programs\7-Zip Extra

rem Path configuration, ARCHIVE_PATH can be blank
set VSCODE_PATH=C:\Programs\Visual Studio Code
set VSCODE_TMP_PATH=C:\Programs\Visual Studio Code Backup
set ARCHIVE_PATH=E:\Data\System\Software\Visual Studio Code

set TMP_PATH=%TMP%\vscode_update_tmp

rem Move VSCODE_PATH
echo Moving Visual Studio Code to temporary location...
move "%VSCODE_PATH%" "%VSCODE_TMP_PATH%"
if errorlevel 1 (
	echo [ERROR] Failed to move Visual Studio Code
	exit /b 1
)

rem Download
echo [INFO] Downloading Visual Studio Code...
set DOWNLOAD_DIR_PATH=%TMP_PATH%\download
mkdir "%DOWNLOAD_DIR_PATH%"
"%WGET_PATH%\wget.exe" "https://go.microsoft.com/fwlink/?Linkid=850641" -q --content-disposition -P "%DOWNLOAD_DIR_PATH%"
if errorlevel 1 (
	echo [ERROR] Failed to download Visual Studio Code
	move "%VSCODE_TMP_PATH%" "%VSCODE_PATH%"
	rmdir /s /q "%TMP_PATH%"
	exit /b 1
)
for /f "tokens=* USEBACKQ" %%f IN (`dir /b "%DOWNLOAD_DIR_PATH%"`) do (
	set FILENAME=%%f
)
if not defined FILENAME (
	echo [ERROR] Cannot find downloaded file
	move "%VSCODE_TMP_PATH%" "%VSCODE_PATH%"
	rmdir /s /q "%TMP_PATH%"
	exit /b 1
)
echo [INFO] Downloaded %FILENAME%
if "%FILENAME:~-4%" neq ".zip" (
	echo [ERROR] Incorrect file extension '%FILENAME:~-4%'
	move "%VSCODE_TMP_PATH%" "%VSCODE_PATH%"
	rmdir /s /q "%TMP_PATH%"
	exit /b 1
)

rem Copy to archive
if defined ARCHIVE_PATH (
	if not exist "%ARCHIVE_PATH%\%FILENAME%" (
		echo [INFO] Copying downloaded file to archive folder...
		copy /-y /b /v "%DOWNLOAD_DIR_PATH%\%FILENAME%" "%ARCHIVE_PATH%\%FILENAME%"
	) else (
		echo [DEBUG] Same filename already exists in archive folder
	)
)

rem Unzip
echo [INFO] Unzipping downloaded file...
set UNZIP_DIR_PATH=%TMP_PATH%\unzip
"%SEVENZA_PATH%\7za.exe" x "%DOWNLOAD_DIR_PATH%\%FILENAME%" "-o%UNZIP_DIR_PATH%" -bsp0 -bso0
if errorlevel 1 (
	echo [ERROR] Failed unzip downloaded file...
	move "%VSCODE_TMP_PATH%" "%VSCODE_PATH%"
	rmdir /s /q "%TMP_PATH%"
	exit /b 1
)

rem Move data folder
echo [INFO] Moving data folder...
move "%VSCODE_TMP_PATH%\data" "%UNZIP_DIR_PATH%\data"
if errorlevel 1 (
	echo [ERROR] Failed to move data folder
	rmdir /s /q "%TMP_PATH%"
	exit /b 1
)

rem Move to final location
echo [INFO] Moving new version to destination
move "%UNZIP_DIR_PATH%" "%VSCODE_PATH%"

rem Cleanup
echo [DEBUG] Cleaning up
rmdir /s /q "%VSCODE_TMP_PATH%"
rmdir /s /q "%TMP_PATH%"
if exist "%VSCODE_TMP_PATH%" (
	echo Trying to remove "%VSCODE_TMP_PATH%" again...
	ping 127.0.0.1 -n 2 > nul
	rmdir /s /q "%VSCODE_TMP_PATH%"
)
if exist "%VSCODE_TMP_PATH%" (
	echo Trying to remove "%VSCODE_TMP_PATH%" again...
	ping 127.0.0.1 -n 2 > nul
	rmdir /s /q "%VSCODE_TMP_PATH%"
)
if exist "%VSCODE_TMP_PATH%" (
	echo Trying to remove "%VSCODE_TMP_PATH%" again...
	ping 127.0.0.1 -n 2 > nul
	rmdir /s /q "%VSCODE_TMP_PATH%"
)
if exist "%VSCODE_TMP_PATH%" echo Failed to remove directory "%VSCODE_TMP_PATH%"

rem Complete
echo [INFO] %~0 ended
exit /b 0
